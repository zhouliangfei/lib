//
//  TMRefresh.h
//  cutter
//
//  Created by mac on 15/5/23.
//  Copyright © 2015年 e360. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_OPTIONS(NSUInteger, TMRefreshType) {
    TMRefreshTypeHeader,
    TMRefreshTypeFooter
};


typedef NS_OPTIONS(NSUInteger, TMRefreshState) {
    TMRefreshStateNormal,
    TMRefreshStatePulling,
    TMRefreshStateRefreshing
};


@interface TMRefresh : UIControl
@property(nonatomic, assign) BOOL finish;
@property(nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
- (instancetype)initWithType:(TMRefreshType)type;
- (void)setTitle:(NSString *)title forState:(TMRefreshState)state;
- (void)beginRefreshing;
- (void)endRefreshing;
@end


@interface UIScrollView (TMRefresh)
@property(nonatomic, readonly) TMRefresh *headerView;
@property(nonatomic, readonly) TMRefresh *footerView;
@end
