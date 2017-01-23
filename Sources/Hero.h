//
//  Hero.h
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HeroTypes.h"

@class HeroContext;
@class HeroPlugin;

@interface Hero : NSObject

@property (nonatomic, weak, readonly) UIViewController *toViewController;
@property (nonatomic, weak, readonly) UIViewController *fromViewController;
@property (nonatomic, strong, readonly) HeroContext *context;
@property (nonatomic, assign, readonly) BOOL presenting;

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, assign) BOOL transitioning;
// container we created to hold all animating views, will be a subview of the
// transitionContainer when transitioning
@property (nonatomic, strong, readonly) UIView *container;

@property (nonatomic, assign) BOOL forceNotInteractive;

+ (instancetype)shared;

@end

@interface Hero (InteractiveTransition)
/**
 Update the progress for the interactive transition.
 - Parameters:
 - progress: the current progress, must be between 0...1
 */
- (void)updateProgress:(CGFloat)progress;

/**
 Finish the interactive transition.
 Will stop the interactive transition and animate from the
 current state to the **end** state
 */
- (void)end;

/**
 Cancel the interactive transition.
 Will stop the interactive transition and animate from the
 current state to the **begining** state
 */
- (void)cancel;

/**
 Override modifiers during an interactive animation.
 
 For example:
 
 Hero.shared.apply([.position(x:50, y:50)], to:view)
 
 will set the view's position to 50, 50
 - Parameters:
 - modifiers: the modifiers to override
 - view: the view to override to
 */
- (void)applyModifiers:(NSArray *)modifiers toView:(UIView *)view;

@end


@interface Hero (Observe)

- (void)observeForProgressUpdateWithObserver:(id<HeroProgressUpdateObserver>)observer;

@end

@interface Hero (Transition)

- (void)start;

- (void)transitionFrom:(UIViewController *)from to:(UIViewController *)to inView:(UIView *)view completion:(void(^)())completion;

- (void)completeAfter:(NSTimeInterval)after finishing:(BOOL)finishing;

- (void)complete:(BOOL)finished;

@end


@interface Hero (DelegateHelper)

- (void)closureProcessForHeroDelegate:(UIViewController *)vc closure:(void(^)(id<HeroViewControllerDelegate> delegate))closure;

@end


@interface Hero (PluginSupport)

+ (BOOL)isEnabledPlugin:(Class)plugin;

+ (void)enablePlugin:(Class)plugin;

+ (void)disablePlugin:(Class)plugin;

@end


@interface Hero (AnimatedTransitioning) <UIViewControllerAnimatedTransitioning>

@end


@interface Hero (TransitioningDelegate) <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign, readonly) id <UIViewControllerInteractiveTransitioning> interactiveTransitioning;

@end


@interface Hero (InteractiveTransitioning) <UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign, readonly) BOOL wantsInteractiveStart;

@end


@interface Hero (NavigationControllerDelegate) <UINavigationControllerDelegate>

@end


@interface Hero (TabBarControllerDelegate) <UITabBarControllerDelegate>

@end
