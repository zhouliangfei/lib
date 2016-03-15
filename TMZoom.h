//
//  TMZoom.h
//  cutter
//
//  Created by mac on 16/1/20.
//  Copyright © 2016年 e360. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TMZoom : UIScrollView <UIScrollViewDelegate>
@property(strong, nonatomic) UIImageView *imageView;
@property(strong, nonatomic) UIView *contentView;
@end