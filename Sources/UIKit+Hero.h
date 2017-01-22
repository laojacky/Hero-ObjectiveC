//
//  UIKit+Hero.h
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeroModifier.h"

@interface UIView (Hero)

@property (nonatomic, copy) IBInspectable NSString *heroID;
@property (nonatomic, strong) IBInspectable HeroModifier *heroModifiers;
@property (nonatomic, copy) IBInspectable NSString *heroModifierString;

- (UIView *)slowSnapshotView;

@end
