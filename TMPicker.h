//
//  TMPicker.h
//  cutter
//
//  Created by mac on 16/1/14.
//  Copyright © 2016年 e360. All rights reserved.
//
#import <UIKit/UIKit.h>


typedef void (^pickerEvent)(UIImage *image);


@interface TMPicker : NSObject<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
+(void)picker:(UIViewController*)controller view:(UIView*)view type:(NSInteger)type onPicker:(pickerEvent)onPicker;
@end