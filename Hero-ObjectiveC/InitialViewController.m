//
//  InitialViewController.m
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/1/22.
//  Copyright © 2017年 luca. All rights reserved.
//

#import "InitialViewController.h"
#import "UIKit+HeroExamples.h"

@interface InitialViewController ()

@property (strong, nonatomic) NSArray *storyboards;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _storyboards = @[
                     @[],
                     @[@"Basic", @"MusicPlayer", @"Menu"],
                     @[@"CityGuide", @"ImageViewer", @"ListToGrid", @"ImageGallery"],
                     @[@"LiveInjection", @"Debug", @"LabelMorph"]
                     ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.item < [_storyboards[indexPath.section] count]) {
        NSString *storyboardName = _storyboards[indexPath.section][indexPath.row];
        UIViewController *viewController = [self.view viewControllerForStoryboardName:storyboardName];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}
@end
