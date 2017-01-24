//
//  HeroDefaultAnimator.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/24.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "HeroDefaultAnimator.h"
#import "HeroDefaultAnimatorViewContext.h"

@interface HeroDefaultAnimator ()

@property (nonatomic, copy) NSMutableArray <NSMutableArray *> *viewContexts;    //@[ @[view, HeroDefaultAnimatorViewContext] ]

@end

@implementation HeroDefaultAnimator

- (HeroContext *)context {
    return [Hero shared].context;
}

- (void)seekToTime:(NSTimeInterval)timePassed {
    for (NSArray *pair in self.viewContexts) {
        HeroDefaultAnimatorViewContext *viewContext = pair[1];
    }
}

@end
