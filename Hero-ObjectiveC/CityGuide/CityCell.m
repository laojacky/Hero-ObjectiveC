//
//  CityCell.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "CityCell.h"
#import "City.h"

static BOOL useShortDescription = YES;

@interface CityCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) City *city;

@end

@implementation CityCell

- (void)setCity:(City *)city {
    _city = city;
}

@end
