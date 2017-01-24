//
//  HeroDefaultAnimatorViewContext.h
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/24.
//  Copyright © 2017年 luca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class HeroDefaultAnimator;
@class HeroTargetState;

@interface HeroDefaultAnimatorViewContext : NSObject

- (instancetype)initWithAnimator:(HeroDefaultAnimator *)animator snapshot:(UIView *)snapshot targetState:(HeroTargetState *)targetState appearing:(BOOL)appearing;
@end
