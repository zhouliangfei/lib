//
//  Utils+Category.h
//  
//
//  Created by 周良飞 on 15/5/5.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import "MBProgressHUD.h"
#import "TMCategory.h"
#import "TMRefresh.h"
#import "TMRequest.h"
#import "TMLoader.h"
#import "TMGlobal.h"
#import "TMPicker.h"
#import "TMZoom.h"
#import "TMJSON.h"


#pragma mark-
#pragma mark blockEvent
typedef void (^blockEvent)(id target, id result);

#pragma mark-
#pragma mark TMUtils
@interface TMUtils : NSObject
+(UIAlertController*)showMessage:(NSString*)message title:(NSString*)title buttons:(NSArray*)buttons handler:(void (^)(UIAlertAction *action))handler;
@end

#pragma mark-
#pragma mark TMAlert
@interface TMAlert : UIView
@property(nonatomic, strong) UIImageView *imageView;
//
+(void)showAtView:(UIView*)view image:(NSString*)image;
+(void)hiddenAtView:(UIView*)view;
@end