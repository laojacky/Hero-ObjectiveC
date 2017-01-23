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

// @[   @{@"modifier1" : modifier1},
//      @{@"modifier2" : modifier2} ]
@property (nonatomic, copy) NSMutableArray <NSMutableDictionary*> *custom;

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
    __block id modifier = nil;
    [self.custom enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj objectForKey:key]) {
            modifier = [obj objectForKey:key];
        }
    }];
    
    return modifier;
}

- (void)setCustomItemOfKey:(NSString *)key value:(id)value {
    if (!self.custom) {
        self.custom = [NSMutableArray array];
    }
    
    __block BOOL contain = NO;
    __block NSInteger index = 0;
    [self.custom enumerateObjectsUsingBlock:^(NSMutableDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj objectForKey:key]) {
            contain = YES;
            index = idx;
            *stop = YES;
        }
    }];
    
    if (contain) {
        [self.custom removeObjectAtIndex:index];
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:value forKey:key];
    [self.custom addObject:dict];
}

@end


@implementation HeroTargetState (ExpressibleByArrayLiteral)

- (instancetype)initWithArrayLiteralElements:(NSArray <HeroModifier *> *)elements {
    [self appendContentsOfModifiers:elements];
}

@end
