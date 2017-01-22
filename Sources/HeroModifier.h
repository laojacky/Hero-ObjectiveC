//
//  HeroModifier.h
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeroModifier : NSObject

+ (HeroModifier *)modifierFromName:(NSString *)name parameters:(NSArray <NSString *>*)parameters;

@end
