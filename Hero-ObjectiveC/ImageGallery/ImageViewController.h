//
//  ImageViewController.h
//  Hero-ObjectiveC
//
//  Created by luca.li on 2017/2/9.
//  Copyright © 2017年 luca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (nonatomic, strong) NSIndexPath *selectedIndex;
@property (nonatomic, strong) UICollectionView *collectionView;

@end
