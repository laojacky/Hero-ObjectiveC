//
//  HeroContext.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "HeroContext.h"
#import "UIKit+Hero.h"
#import "HeroTargetState.h"
#import <CoreGraphics/CoreGraphics.h>


@interface HeroContext ()

// Using multi-dimension array to represents map
@property (nonatomic, copy) NSMutableArray <NSArray *> *heroIDToSourceView;         //@[@[string, view], ...]
@property (nonatomic, copy) NSMutableArray <NSArray *> *heroIDToDestinationView;    //@[@[string, view], ...]
@property (nonatomic, copy) NSMutableArray <NSArray *> *snapshotViews;              //@[@[view, view], ...]
@property (nonatomic, copy) NSMutableArray <NSArray *> *viewAlphas;                 //@[@[string, number], ...]
@property (nonatomic, copy) NSMutableArray <NSArray *> *targetStates;               //@[@[view, HeroTargetState], ...]

@end

@implementation HeroContext

- (NSMutableArray<NSArray *> *)targetStates {
    if (!_targetStates) {
        _targetStates = [NSMutableArray array];
    }
    return _targetStates;
}

- (instancetype)initWithContainer:(UIView *)container fromView:(UIView *)fromView toView:(UIView *)toView {
    if ([self init]) {
        self.fromViews = [HeroContext processViewTreeWithView:fromView container:container idMap:self.heroIDToSourceView stateMap:self.targetStates];
        self.toViews = [HeroContext processViewTreeWithView:toView container:container idMap:self.heroIDToSourceView stateMap:self.targetStates];
        self.container = container;
    }
    return self;
}

- (UIView *)sourceViewForHeroID:(NSString *)heroID {
    __block UIView *view = nil;
    [self.heroIDToSourceView enumerateObjectsUsingBlock:^(NSArray *pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pair[0] isEqualToString:heroID]) {
            view = pair[1];
            *stop = YES;
        }
    }];
    return view;
}

- (UIView *)destinationViewForHeroID:(NSString *)heroID {
    __block UIView *view = nil;
    [self.heroIDToDestinationView enumerateObjectsUsingBlock:^(NSArray *pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([pair[0] isEqualToString:heroID]) {
            view = pair[1];
            *stop = YES;
        }
    }];
    return view;
}

- (UIView *)pairedViewForView:(UIView *)view {
    if (view.heroID) {
        if ([self sourceViewForHeroID:view.heroID]) {
            return [self destinationViewForHeroID:view.heroID];
        } else if ([self destinationViewForHeroID:view.heroID]) {
            return [self sourceViewForHeroID:view.heroID];
        }
    }
    return nil;
}

- (UIView *)snapshotViewForView:(UIView *)view {
    __block UIView *snapshot = nil;
    [self.snapshotViews enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if(pair[0] == view) {
            snapshot = pair[1];
        }
    }];
    
    if (snapshot) {
        return snapshot;
    }
    
    [self unhideView:view];
    
    // capture a snapshot without alpha & cornerRadius
    CGFloat oldCornerRadius = view.layer.cornerRadius;
    CGFloat oldAlpha = view.alpha;
    view.layer.cornerRadius = 0;
    view.alpha = 1;
    snapshot = nil;
    
    if ([view isKindOfClass:[UIStackView class]]) {
        UIStackView *stackView = (UIStackView *)view;
        snapshot = [stackView slowSnapshotView];
    } else if ([view isKindOfClass:[UIImageView class]] && [view.subviews count] == 0) {
        UIImageView *imageView = (UIImageView *)view;
        UIImageView *contentView = [[UIImageView alloc] initWithImage:imageView.image];
        contentView.frame = imageView.bounds;
        contentView.contentMode = imageView.contentMode;
        contentView.tintColor = imageView.tintColor;
        contentView.backgroundColor = imageView.backgroundColor;
        UIView *snapshotView = [[UIView alloc] init];
        [snapshotView addSubview:contentView];
        snapshot = snapshotView;
    } else if ([view isKindOfClass:[UINavigationBar class]] && ((UINavigationBar *)view).isTranslucent) {
        UINavigationBar *barView = (UINavigationBar *)view;
        UINavigationBar *newBarView = [[UINavigationBar alloc] initWithFrame:view.frame];
        
        newBarView.barStyle = barView.barStyle;
        newBarView.tintColor = barView.tintColor;
        newBarView.barTintColor = barView.barTintColor;
        newBarView.clipsToBounds = NO;
        
        // take a snapshot without the background
        barView.layer.sublayers[0].opacity = 0;
        UIView *realSnapshot = [barView snapshotViewAfterScreenUpdates:YES];
        barView.layer.sublayers[0].opacity = 1;
        
        [newBarView addSubview:realSnapshot];
        snapshot = newBarView;
    } else {
        snapshot = [view snapshotViewAfterScreenUpdates:YES];
    }
    view.layer.cornerRadius = oldCornerRadius;
    view.alpha = oldAlpha;
    
    if (![view isKindOfClass:[UINavigationBar class]]) {
        // the Snapshot's contentView must have hold the cornerRadius value,
        // since the snapshot might not have maskToBounds set
        UIView *contentView = snapshot.subviews[0];
        contentView.layer.cornerRadius = view.layer.cornerRadius;
        contentView.layer.masksToBounds = YES;
    }
    
    snapshot.layer.cornerRadius = view.layer.cornerRadius;
    
    __block BOOL contain = NO;
    [self.targetStates enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pair[0] == view) {
            snapshot.layer.zPosition = ((HeroTargetState *)pair[1]).zPosition;
            contain = YES;
            *stop = YES;
        }
    }];
    if (!contain) {
        snapshot.layer.zPosition = view.layer.zPosition;
    }
    
    snapshot.layer.opacity = view.layer.opacity;
    snapshot.layer.opaque = view.layer.isOpaque;
    snapshot.layer.anchorPoint = view.layer.anchorPoint;
    snapshot.layer.masksToBounds = view.layer.masksToBounds;
    snapshot.layer.borderColor = view.layer.borderColor;
    snapshot.layer.borderWidth = view.layer.borderWidth;
    snapshot.layer.transform = view.layer.transform;
    snapshot.layer.shadowRadius = view.layer.shadowRadius;
    snapshot.layer.shadowOpacity = view.layer.shadowOpacity;
    snapshot.layer.shadowColor = view.layer.shadowColor;
    snapshot.layer.shadowOffset = view.layer.shadowOffset;
    
    snapshot.frame = [self.container convertRect:view.bounds fromView:view];
    snapshot.heroID = view.heroID;
    
    [self hideView:view];
    
    [self.container addSubview:snapshot];
    contain = NO;
    [self.snapshotViews enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pair[0] == view) {
            contain = YES;
            *stop = YES;
        }
    }];
    if (!contain) {
        [self.snapshotViews addObject:@[view, snapshot]];
    }
    
    return snapshot;
}

#pragma mark - Internal

- (void)hideView:(UIView *)view {
    __block BOOL contain = NO;
    [self.viewAlphas enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pair[0] == view) {
            contain = YES;
            *stop = YES;
        }
    }];
    
    if (!contain) {
        [self.viewAlphas addObject:@[view, @(view.alpha)]];
        view.alpha = 0;
    }
}

- (void)unhideView:(UIView *)view {
    __block CGFloat oldAlpha = 0;
    __block BOOL contain = NO;
    __block NSInteger index = 0;
    [self.viewAlphas enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pair[0] == view) {
            oldAlpha = [pair[1] floatValue];
            index = idx;
            *stop = YES;
        }
    }];
    
    if (contain) {
        view.alpha = oldAlpha;
        [self.viewAlphas removeObjectAtIndex:index];
    }
}

- (void)unhideAll {
    [self.viewAlphas enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = pair[0];
        CGFloat oldAlpha = [pair[1] floatValue];
        view.alpha = oldAlpha;
    }];
    [self.viewAlphas removeAllObjects];
}

+ (NSMutableArray <UIView *>*)processViewTreeWithView:(UIView *)view
                                            container:(UIView *)container
                                                idMap:(NSMutableArray *)idMap
                                             stateMap:(NSMutableArray *)stateMap {
    NSMutableArray <UIView *> *rtn = [NSMutableArray array];
    if (!CGRectEqualToRect(CGRectIntersection([container convertRect:view.bounds fromView:view], container.bounds), CGRectNull)) {
        rtn = [@[view] mutableCopy];
        if (view.heroID) {
            [idMap addObject:@[view.heroID, view]];
        }
        if (view.heroModifiers && [view.heroModifiers count]) {
            [stateMap addObject:@[view, [[HeroTargetState alloc] initWithModifiers:view.heroModifiers]]];
        }
    } else {
        rtn = [@[] mutableCopy];
    }
    
    for (UIView *sv in view.subviews) {
        [rtn addObjectsFromArray:[self processViewTreeWithView:sv container:container idMap:idMap stateMap:stateMap]];
    }
    
    return rtn;
}
@end


@implementation HeroContext (TargetState)

- (HeroTargetState *)stateOfView:(UIView *)view {
    __block BOOL contain = NO;
    __block NSInteger index = 0;
    [self.targetStates enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pair[0] == view) {
            index = idx;
            contain = YES;
            *stop = YES;
        }
    }];
    
    if (contain) {
        return [self.targetStates objectAtIndex:index][1];
    }
    return nil;
}

- (void)setState:(HeroTargetState *)state toView:(UIView *)view {
    __block BOOL contain = NO;
    __block NSInteger index = 0;
    [self.targetStates enumerateObjectsUsingBlock:^(NSArray * _Nonnull pair, NSUInteger idx, BOOL * _Nonnull stop) {
        if (pair[0] == view && pair[1] == state) {
            index = idx;
            contain = YES;
            *stop = YES;
        }
    }];
    
    if ((contain || state == nil) && [self.targetStates count]) {
        [self.targetStates removeObjectAtIndex:index];
    }
    
    if (state) {
        [self.targetStates addObject:@[view, state]];
    }
}

@end
