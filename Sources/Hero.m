//
//  Hero.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "Hero.h"
#import "HeroContext.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

typedef void(^HeroCompletionCallback)();

@interface Hero ()

@property (nonatomic, strong) HeroContext *context;
@property (nonatomic, assign) BOOL presenting;  //default is true in swift, but NO in here
@property (nonatomic, assign) CGFloat progress;

// this is the container supplied by UIKit
@property (nonatomic, strong) UIView *transitionContainer;

// a UIViewControllerContextTransitioning object provided by UIKit,
// might be nil when transitioning. This happens when calling heroReplaceViewController
@property (nonatomic, weak) id <UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, assign) HeroCompletionCallback completionCallback;

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, copy) NSMutableArray <id <HeroProgressUpdateObserver>>* progressUpdateObservers;

@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) NSTimeInterval beginTime;

@property (nonatomic, assign) BOOL finishing;
@property (nonatomic, assign) BOOL inContainerController;

@property (nonatomic, strong) UIView *toView;
@property (nonatomic, strong) UIView *fromView;

@property (nonatomic, copy) NSMutableArray <id <HeroPreprocessor>> *processors;
@property (nonatomic, copy) NSMutableArray <id <HeroAnimator>> *animators;
@property (nonatomic, copy) NSMutableArray <HeroPlugin *> *plugins;
@property (nonatomic, copy) NSMutableArray <HeroPlugin *> *enablePlugins;

@end

@implementation Hero

+ (instancetype)shared {
    static Hero *hero = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hero = [[Hero alloc] init];
    });
    
    return hero;
}

- (instancetype)init {
    if (self = [super init]) {
        //Nothing special
        self.processors = [NSMutableArray array];
        self.animators = [NSMutableArray array];
        self.plugins = [NSMutableArray array];
        self.enablePlugins = [NSMutableArray array];
    }
    return self;
}

- (BOOL)interactive {
    return self.displayLink = nil;
}

- (BOOL)transitioning {
    return self.transitionContainer != nil;
}

- (void)setProgress:(CGFloat)progress {
    if (self.transitioning && self.progress != progress) {
        [self.transitionContext updateInteractiveTransition:progress];
        NSArray *progressUpdateObservers = self.progressUpdateObservers;
        if (progressUpdateObservers) {
            for (id<HeroProgressUpdateObserver>observer in progressUpdateObservers) {
                [observer heroDidUpdateProgress:progress];
            }
        }
        
        NSTimeInterval timePassed = self.progress * self.totalDuration;
        if (self.interactive) {
            for (id<HeroAnimator>animator in self.animators) {
                [animator seekToTime:timePassed];
            }
        } else {
            for (HeroPlugin *plugin in self.plugins) {
                if (plugin.requrePerFrameCallback) {
                    [plugin seekToTime:timePassed];
                }
            }
        }
    }
}

- (void)setBeginTime:(NSTimeInterval)beginTime {
    _beginTime = beginTime;
    if (self.displayLink == nil) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayUpdate:)];
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    } else {
        [self.displayLink setPaused:YES];
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink = nil;
    }
}

- (UIView *)toView {
    return self.toViewController.view;
}

- (UIView *)fromView {
    return self.fromViewController.view;
}

#pragma mark - private

- (void)displayUpdate:(CADisplayLink *)link {
    if (self.transitioning && self.duration > 0) {
        NSTimeInterval beginTime = self.beginTime;
        NSTimeInterval timePassed = CACurrentMediaTime() - beginTime;
        
        if (timePassed > self.duration) {
            self.progress = self.finishing ? 1 : 0;
            self.beginTime = 0;
            [self complete:self.finishing];
        } else {
            NSTimeInterval completed = timePassed / self.totalDuration;
            if (self.finishing) {
                completed = 1 - completed;
            }
            completed = MAX(0, MIN(1, completed));
            self.progress = completed;
        }
    }
}

- (void)completeAfter:(NSTimeInterval)after finishing:(BOOL)finishing {
    NSTimeInterval timePassed = (finishing ? self.progress : 1 - self.progress) * self.totalDuration;
    self.finishing = finishing;
    self.duration = after + timePassed;
    self.beginTime = CACurrentMediaTime() - timePassed;
}

- (void)complete:(BOOL)finished {
    for (id <HeroAnimator> animator in self.animators) {
        [animator clean];
    }
    [self.context unhideAll];
    
    // move fromView & toView back from animatingViewContainer
    [self.transitionContainer addSubview:finished ? self.toView : self.fromView];
    
    if (self.presenting != finished && !self.inContainerController) {
        // bug: http://openradar.appspot.com/radar?id=5320103646199808
        [[UIApplication sharedApplication].keyWindow addSubview:self.toView];
    }
    
    [self.container removeFromSuperview];
    [self.transitionContainer setUserInteractionEnabled:YES];
    
    // use temp variables to remember these values
    // because we have to reset everything before calling
    // any delegate or completion block
    id <UIViewControllerContextTransitioning> tContext = self.transitionContext;
    HeroCompletionCallback completion = self.completionCallback;
    UIViewController *fvc = self.fromViewController;
    UIViewController *tvc = self.toViewController;
    
    self.progressUpdateObservers = nil;
    self.transitionContainer = nil;
    self.transitionContext = nil;
    self.fromViewController = nil;
    self.toViewController = nil;
    self.completionCallback = nil;
    self.container = nil;
    self.plugins = nil;
    self.animators = nil;
    self.context = nil;
    self.beginTime = 0;
    self.inContainerController = NO;
    self.forceNotInteractive = NO;
    self.progress = 0;
    self.totalDuration = 0;
    
    
    if (fvc && tvc) {
        [self closureProcessForHeroDelegate:fvc closure:^(id<HeroViewControllerDelegate> delegate) {
            [delegate heroDidEndAnimatingTo:tvc];
            [delegate heroDidEndTransition];
        }];
        
        [self closureProcessForHeroDelegate:tvc closure:^(id<HeroViewControllerDelegate> delegate) {
            [delegate heroDidEndAnimatingFrom:fvc];
            [delegate heroDidEndTransition];
        }];
    }
    
    if (finished) {
        [tContext finishInteractiveTransition];
    } else {
        [tContext cancelInteractiveTransition];
    }
    [tContext completeTransition:finished];
    completion();
}
@end

// delegate helper
@implementation Hero (Delegate)

- (void)closureProcessForHeroDelegate:(UIViewController *)vc closure:(void(^)(id<HeroViewControllerDelegate> delegate))closure {
    
    id <HeroViewControllerDelegate>delegate = (id <HeroViewControllerDelegate>)vc;
    if ([delegate conformsToProtocol:@protocol(HeroViewControllerDelegate)]) {
        closure(delegate);
    }
    
    UINavigationController *navigationController = (UINavigationController *)vc;
    delegate = (id <HeroViewControllerDelegate>)navigationController.topViewController;
    if (navigationController && [delegate conformsToProtocol:@protocol(HeroViewControllerDelegate)]) {
        closure(delegate);
    }
    
    UITabBarController *tabBarController = (UITabBarController *)vc;
    delegate = (id <HeroViewControllerDelegate>)tabBarController.viewControllers[tabBarController.selectedIndex];
    if ([delegate conformsToProtocol:@protocol(HeroViewControllerDelegate)]) {
        closure(delegate);
    }
}

@end

// plugin support
@implementation Hero (PluginSupport)

- (BOOL)isEnabledPlugin:(HeroPlugin *)plugin {
    for (HeroPlugin *pluginInList in _enablePlugins) {
        if (pluginInList == plugin) {
            return YES;
        }
    }
    return nil;
}

- (void)enablePlugin:(HeroPlugin *)plugin {
    [self disablePlugin:plugin];
    [_enablePlugins addObject:plugin];
}

- (void)disablePlugin:(HeroPlugin *)plugin {
    for (HeroPlugin *pluginInList in _enablePlugins) {
        if (pluginInList == plugin) {
            [_enablePlugins removeObject:plugin];
            break;
        }
    }
}

@end






/*****************************
 * UIKit protocol extensions *
 *****************************/

@implementation Hero (AnimatedTransitioning)

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    self.fromViewController = self.fromViewController ? self.fromViewController : [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.toViewController = self.toViewController ? self.toViewController : [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    self.transitionContainer = [transitionContext containerView];
    [self start];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.375;   // doesn't matter, real duration will be calculated later
}

@end


@implementation Hero (TransitioningDelegate)

- (id<UIViewControllerInteractiveTransitioning>)interactiveTransitioning {
    return self.forceNotInteractive ? nil : (id<UIViewControllerInteractiveTransitioning>)self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.presenting = YES;
    self.fromViewController = self.fromViewController ? self.fromViewController : presenting;
    self.toViewController = self.toViewController ? self.toViewController : presenting;
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.presenting = NO;
    self.fromViewController = self.fromViewController ? self.fromViewController : dismissed;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransitioning;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interactiveTransitioning;
}
@end


@implementation Hero (InteractiveTransitioning)

- (BOOL)wantsInteractiveStart {
    return YES;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [self animateTransition:transitionContext];
}

@end


@implementation Hero (NavigationControllerDelegate)

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    self.presenting = (operation == UINavigationControllerOperationPush);
    self.fromViewController = self.fromViewController ? self.fromViewController : fromVC;
    self.toViewController = self.toViewController ? self.toViewController : toVC;
    self.inContainerController = YES;
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return self.interactiveTransitioning;
}

@end


@implementation Hero (TabBarControllerDelegate)

- (id<UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    return self.interactiveTransitioning;
}

- (id<UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController animationControllerForTransitionFromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    self.presenting = YES;
    self.fromViewController = self.fromViewController ? self.fromViewController : fromVC;
    self.toViewController = self.toViewController ? self.toViewController : toVC;
    self.inContainerController = YES;
    return self;
}
@end
