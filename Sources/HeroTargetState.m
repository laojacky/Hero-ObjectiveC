//
//  HeroTargetState.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "HeroTargetState.h"
#import "HeroModifier.h"

@interface HeroTargetState ()

@property (nonatomic, copy) NSMutableDictionary *custom;

@end

@implementation HeroTargetState

- (instancetype)initWithModifiers:(NSArray *)modifiers {
    if (self = [super init]) {
        [self appendContentsOfModifiers:modifiers];
    }
    return self;
}

- (void)appendContentsOfModifiers:(NSArray <HeroModifier *> *)modifiers {
    for (HeroModifier *modifier in modifiers) {
        modifier.apply(self);
    }
}

- (id)customItemOfKey:(NSString *)key {
    return self.custom[key];
}

- (void)setCustomItemOfKey:(NSString *)key value:(id)value {
    if (!self.custom) {
        self.custom = [NSMutableDictionary dictionary];
    }
    [self.custom setValue:value forKey:key];
}

@end


@implementation HeroTargetState (ExpressibleByArrayLiteral)

- (instancetype)initWithArrayLiteralElements:(NSArray <HeroModifier *> *)elements {
    [self appendContentsOfModifiers:elements];
}

@end
