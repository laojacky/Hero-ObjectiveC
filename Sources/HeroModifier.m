//
//  HeroModifier.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "HeroModifier.h"
#import "HeroTargetState.h"

@interface HeroModifier ()

@end

@implementation HeroModifier

- (instancetype)initWithApplyFunction:(HeroModifierApplyBlock)applyFunction {
    if (self = [super init]) {
        self.apply = applyFunction;
    }
    
    return self;
}

@end

@implementation HeroModifier (BasicModifiers)

- (HeroModifier *)position:(CGPoint)position {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.position = position;
    }];
}

- (HeroModifier *)size:(CGSize)size {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.size = size;
    }];
}

@end

@implementation HeroModifier (TransformModifiers)

- (HeroModifier *)transform:(CATransform3D)t {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.transform = t;
    }];
}

- (HeroModifier *)perspective:(CGFloat)perspective {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        CATransform3D transform = targetState.transform;
        transform.m34 = 1.0 / -perspective;
        targetState.transform = transform;
    }];
}

- (HeroModifier *)scaleX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.transform = CATransform3DScale(targetState.transform, x, y, z);
        
    }];
}

- (HeroModifier *)scaleXY:(CGFloat)xy {
    return [self scaleX:xy Y:xy Z:1.0];
}

- (HeroModifier *)translateX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.transform = CATransform3DTranslate(targetState.transform, x, y, z);
    }];
}

- (HeroModifier *)rotateX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.transform = CATransform3DRotate(targetState.transform, x, 1, 0, 0);
        targetState.transform = CATransform3DRotate(targetState.transform, y, 0, 1, 0);
        targetState.transform = CATransform3DRotate(targetState.transform, z, 0, 0, 1);
    }];
}

- (HeroModifier *)rotateZ:(CGFloat)z {
    return [self rotateX:0 Y:0 Z:z];
}

@end


@implementation HeroModifier (TimingMidifiers)

- (HeroModifier *)duration:(NSTimeInterval)duration {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.duration = duration;
    }];
}

- (HeroModifier *)delay:(NSTimeInterval)delay {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.delay = delay;
    }];
}

- (HeroModifier *)timingFunction:(CAMediaTimingFunction*)timingFunction {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.timingFunction = timingFunction;
    }];
}

- (HeroModifier *)spring:(CGFloat)stiffness damping:(CGFloat)damping NS_AVAILABLE_IOS(9_0) {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        //Use two dimension array as tuple
        targetState.spring = @[@(stiffness), @(damping)];
    }];
}

@end


@implementation HeroModifier (OtherModifiers)

- (HeroModifier *)ignoreSubviewModifiers {
    return [self ignoreSubviewModifiers:NO];
}

- (HeroModifier *)arc {
    return [self arc:1];
}

- (HeroModifier *)cascade {
    return [self cascadeWithDelta:0.02 direction:CascadeDirectionTopToBottom delayMatchedViews:NO];
}

- (HeroModifier *)zPosition:(CGFloat)zPosition {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.zPosition = zPosition;
    }];
}

- (HeroModifier *)zPositionIfMatched:(CGFloat)zPositionIfMatched {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.zPositionIfMatched = zPositionIfMatched;
    }];
}

- (HeroModifier *)ignoreSubviewModifiers:(BOOL)recursive {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.ignoreSubviewModifiers = recursive;
    }];
}

- (HeroModifier *)source:(NSString *)heroID {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.source = heroID;
    }];
}

- (HeroModifier *)arc:(CGFloat)intensity {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        targetState.arc = intensity;
    }];
}

- (HeroModifier *)cascadeWithDelta:(NSTimeInterval)delta direction:(CascadeDirection *)direction delayMatchedViews:(BOOL)delayMatchedViews {
    return [[HeroModifier alloc] initWithApplyFunction:^(HeroTargetState *targetState) {
        //Use three dimension array as tuple
        targetState.cascade = @[@(delta), direction, @(delayMatchedViews)];
    }];
}

@end


@implementation HeroModifier (HeroModifierString)

- (HeroModifier *)modifierFromName:(NSString *)name parameters:(NSArray <NSString *>*)parameters {
    HeroModifier *modifier;
    if ([name isEqualToString:@"fade"]) {
        modifier = [[HeroModifier alloc] initWithApplyFunction:fade];
    }
    
    if ([name isEqualToString:@"position"]) {
        modifier = [self position:CGPointMake([parameters[0] floatValue] ? [parameters[0] floatValue] : 0, [parameters[1] floatValue] ? [parameters[1] floatValue] : 0)];
    }
    
    if ([name isEqualToString:@"size"]) {
        modifier = [self size:CGSizeMake([parameters[0] floatValue] ? [parameters[0] floatValue] : 0, [parameters[1] floatValue] ? [parameters[1] floatValue] : 0)];
    }
    
    if ([name isEqualToString:@"scale"]) {
        if ([parameters count] == 1) {
            modifier = [self scaleXY:[parameters[0] floatValue] ? [parameters[0] floatValue] : 1];
        } else {
            modifier = [self scaleX:[parameters[0] floatValue] ? [parameters[0] floatValue] : 1
                                  Y:[parameters[1] floatValue] ? [parameters[1] floatValue] : 1
                                  Z:[parameters[2] floatValue] ? [parameters[2] floatValue] : 1];
        }
    }
    
    if ([name isEqualToString:@"rotate"]) {
        if ([parameters count] == 1) {
            modifier = [self rotateZ:[parameters[0] floatValue] ? [parameters[0] floatValue] : 0];
        } else {
            modifier = [self rotateX:[parameters[0] floatValue] ? [parameters[0] floatValue] : 0
                                  Y:[parameters[1] floatValue] ? [parameters[1] floatValue] : 0
                                  Z:[parameters[2] floatValue] ? [parameters[2] floatValue] : 0];
        }
    }
    
    if ([name isEqualToString:@"translate"]) {
        modifier = [self translateX:[parameters[0] floatValue] ? [parameters[0] floatValue] : 0
                              Y:[parameters[1] floatValue] ? [parameters[1] floatValue] : 0
                              Z:[parameters[2] floatValue] ? [parameters[2] floatValue] : 0];
    }
    
    if ([name isEqualToString:@"duration"]) {
        NSTimeInterval duration = [parameters[0] doubleValue];
        if (duration) {
            modifier = [self duration:duration];
        }
    }
    
    if ([name isEqualToString:@"delay"]) {
        NSTimeInterval delay = [parameters[0] doubleValue];
        if (delay) {
            modifier = [self delay:delay];
        }
    }
    
    if ([name isEqualToString:@"spring"]) {
        modifier = [self spring:[parameters[0] floatValue] ? [parameters[0] floatValue] : 250 damping:[parameters[1] floatValue] ? [parameters[1] floatValue] : 30];
    }
    
    if ([name isEqualToString:@"timingFunction"]) {
        CGFloat c1 = [parameters[0] floatValue];
        CGFloat c2 = [parameters[1] floatValue];
        CGFloat c3 = [parameters[2] floatValue];
        CGFloat c4 = [parameters[3] floatValue];
        if (c1 && c2 && c3 && c4) {
            modifier = [self timingFunction:[CAMediaTimingFunction functionWithControlPoints:c1 :c2 :c3 :c4]];
        } else if ([parameters[0] isKindOfClass:[NSString class]]) {
            NSString *functionName = parameters[0];
            if (functionName &&  [CAMediaTimingFunction functionWithName:functionName]) {
                modifier = [self timingFunction:[CAMediaTimingFunction functionWithName:functionName]];
            }
        }
    }
    
    if ([name isEqualToString:@"arc"]) {
        modifier = [self arc:[parameters[0] floatValue] ? [parameters[0] floatValue] : 1];
    }
    
    if ([name isEqualToString:@"cascade"]) {
        CascadeDirection *cascadeDirection = CascadeDirectionTopToBottom;
        if ([parameters[1] isKindOfClass:[NSString class]) {
            cascadeDirection = [[CascadePreprocessor alloc] initWithString:parameters[1]];
        }
        modifier = [self cascadeWithDelta:[parameters[0] floatValue] ? [parameters[0] floatValue] : 0.02 direction:cascadeDirection delayMatchedViews:[parameters[2] boolValue] ? [parameters[2] boolValue] : NO];
    }
    
    if ([name isEqualToString:@"source"]) {
        NSString *heroID = parameters[0];
        if (heroID) {
            modifier = [self source:heroID];
        }
    }
    
    if ([name isEqualToString:@"ignoreSubviewModifiers"]) {
        modifier = [self ignoreSubviewModifiers:[parameters[0] boolValue] ? [parameters[0] boolValue] : NO];
    }
    
    if ([name isEqualToString:@"zPosition"]) {
        modifier = [self zPosition:[parameters[0] floatValue]];
    }
    
    if ([name isEqualToString:@"zPositionIfMatched"]) {
        modifier = [self zPositionIfMatched:[parameters[0] floatValue]];
    }
    
    return modifier;
}

@end
