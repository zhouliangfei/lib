//
//  UICoverFlowLayout.h
//  Topkea
//
//  Created by 周良飞 on 15/5/5.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface TMCoverFlow : UICollectionViewLayout
@property (nonatomic) IBInspectable CGSize itemSize;
@property (nonatomic) IBInspectable CGFloat expand;
@property (nonatomic) IBInspectable CGFloat degree;
@property (nonatomic) IBInspectable CGFloat space;
@property (nonatomic) IBInspectable CGFloat scale;
@end