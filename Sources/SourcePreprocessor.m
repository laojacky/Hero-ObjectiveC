//
//  SourcePreprocessor.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/24.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "SourcePreprocessor.h"

@implementation SourcePreprocessor

- (void)processFromViews:(NSArray *)fromviews toViews:(NSArray *)toviews {
    for (UIView *fv in fromviews) {
        NSString *heroID = [self.context stateOfView:fv].source;
        UIView *tv = [self.context destinationViewForHeroID:heroID];
        if (heroID && tv) {
            [self prepareForView:fv targetView:tv];
        }
    }
    
    for (UIView *tv in toviews) {
        NSString *heroID = [self.context stateOfView:tv].source;
        UIView *fv = [self.context destinationViewForHeroID:heroID];
        if (heroID && fv) {
            [self prepareForView:tv targetView:fv];
        }
    }
}

@end

@implementation SourcePreprocessor (Prepare)

- (void)prepareForView:(UIView *)view targetView:(UIView *)targetView {
    CGPoint targetPos = [self.context.container convertPoint:targetView.layer.position toView:targetView.superview];
    
    HeroTargetState *state = [self.context stateOfView:view];
    
    // remove incompatible options
    //state.transform = nil;
    //state.size = nil;

    state.position = targetPos;
    if (!CGSizeEqualToSize(view.bounds.size, targetView.bounds.size)) {
        state.size = targetView.bounds.size;
    }
    
    if (view.layer.cornerRadius != targetView.layer.cornerRadius) {
        state.cornerRadius = targetView.layer.cornerRadius;
    }
    
    if (!CATransform3DEqualToTransform(view.layer.transform, targetView.layer.transform)) {
        state.transform = targetView.layer.transform;
    }
    
    [self.context setState:state toView:view];
}

@end
