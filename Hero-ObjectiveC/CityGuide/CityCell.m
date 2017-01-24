//
//  CityCell.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "CityCell.h"
#import "City.h"
#import "UIKit+Hero.h"

static BOOL useShortDescription = YES;

@interface CityCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (strong, nonatomic) City *city;

@end

@implementation CityCell

- (void)setCity:(City *)city {
    
    if (!city) {
        return;
    }
    _city = city;
    NSString *name = city.name;
    
    self.heroID = name;
    self.heroModifiers = @[[HeroModifier modifierFromName:@"zPositionIfMatched" parameters:@[@(3)]]];
    
    self.nameLabel.text = name;
    self.imageView.image = city.image;
    self.descriptionLabel.text = useShortDescription ? city.shortDescription : city.description;
}

@end
