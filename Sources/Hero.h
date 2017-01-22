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
#import "HeroPlugin.h"

@interface Hero : NSObject

@property (nonatomic, assign) BOOL interactive;
@property (nonatomic, assign) BOOL transitioning;
// container we created to hold all animating views, will be a subview of the
// transitionContainer when transitioning
@property (nonatomic, strong) UIView *container;

@property (nonatomic, weak) UIViewController *toViewController;
@property (nonatomic, weak) UIViewController *fromViewController;

@property (nonatomic, assign) BOOL forceNotInteractive;

+ (instancetype)shared;

@end


@interface Hero (Delegate)

- (void)closureProcessForHeroDelegate:(UIViewController *)vc closure:(void(^)(id<HeroViewControllerDelegate> delegate))closure;

@end


@interface Hero (PluginSupport)

- (BOOL)isEnabledPlugin:(HeroPlugin *)plugin;

- (void)enablePlugin:(HeroPlugin *)plugin;

- (void)disablePlugin:(HeroPlugin *)plugin;

@end


@interface Hero (AnimatedTransitioning) <UIViewControllerAnimatedTransitioning>

@end


@interface Hero (TransitioningDelegate) <UIViewControllerTransitioningDelegate>

@property (nonatomic, assign) id <UIViewControllerInteractiveTransitioning> interactiveTransitioning;

@end


@interface Hero (InteractiveTransitioning) <UIViewControllerInteractiveTransitioning>

@property (nonatomic, assign, readonly) BOOL wantsInteractiveStart;

@end


@interface Hero (NavigationControllerDelegate) <UINavigationControllerDelegate>

@end


@interface Hero (TabBarControllerDelegate) <UITabBarControllerDelegate>

@end
