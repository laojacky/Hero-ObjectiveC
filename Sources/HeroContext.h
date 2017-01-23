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

@property (nonatomic, strong) UIView *container;

- (instancetype)initWithContainer:(UIView *)container fromView:(UIView *)fromView toView:(UIView *)toView;

- (UIView *)sourceViewForHeroID:(NSString *)heroID;

- (UIView *)destinationViewForHeroID:(NSString *)heroID;

- (UIView *)pairedViewForView:(UIView *)view;

- (UIView *)snapshotViewForView:(UIView *)view;

- (void)hideView:(UIView *)view;

- (void)unhideView:(UIView *)view;

- (void)unhideAll;

+ (NSMutableArray <UIView *>*)processViewTreeWithView:(UIView *)view container:(UIView *)container idMap:(NSMutableArray *)idMap stateMap:(NSMutableArray *)stateMap;

@end
