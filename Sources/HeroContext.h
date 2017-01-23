//
//  HeroContext.h
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HeroContext : NSObject

@property (nonatomic, copy) NSMutableArray *fromViews;
@property (nonatomic, copy) NSMutableArray *toViews;

- (instancetype)initWithContainer:(UIView *)container fromView:(UIView *)fromView toView:(UIView *)toView;
- (void)hideView:(UIView *)view;

@end
