//
//  TMPicker.m
//  cutter
//
//  Created by mac on 16/1/14.
//  Copyright © 2016年 e360. All rights reserved.
//

#import "TMPicker.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface TMPicker ()
@property(nonatomic, strong) UIImagePickerController *imagePicker;
@property(nonatomic, strong) UIImage *pickerImage;
@property(nonatomic, copy) pickerEvent onPicker;
@end

@implementation TMPicker
+(TMPicker*)shareInstance{
    static TMPicker *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[TMPicker alloc] init];
    });
    return instance;
}
+(void)picker:(UIViewController*)controller view:(UIView*)view type:(NSInteger)type onPicker:(pickerEvent)onPicker{
    [[TMPicker shareInstance] pickerAtController:controller view:view type:type];
    [[TMPicker shareInstance] setOnPicker:onPicker];
}
-(void)pickerAtController:(UIViewController*)controller view:(UIView*)view type:(NSInteger)type{
    [self setPickerImage:nil];
    if ([UIImagePickerController isSourceTypeAvailable:type]) {
        if (self.imagePicker == nil && controller) {
            [self setImagePicker:[[UIImagePickerController alloc] init]];
            [self.imagePicker setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            [self.imagePicker setSourceType:type];
            [self.imagePicker setDelegate:self];
            //
            [controller presentViewController:self.imagePicker animated:YES completion:nil];
        }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
        [self setPickerImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        if(self.pickerImage.imageOrientation != UIImageOrientationUp){
            UIGraphicsBeginImageContext(self.pickerImage.size);
            [self.pickerImage drawInRect:(CGRect){.origin=CGPointZero,.size=self.pickerImage.size}];
            [self setPickerImage:UIGraphicsGetImageFromCurrentImageContext()];
            UIGraphicsEndImageContext();
        }
        if (self.onPicker != nil) {
            self.onPicker(self.pickerImage);
        }
    }
    [self imagePickerControllerDidCancel:picker];
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController*)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self setImagePicker:nil];
    [self setPickerImage:nil];
}
@end
