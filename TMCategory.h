//
//  TMCategory.h
//  cutter
//
//  Created by mac on 16/3/12.
//  Copyright © 2016年 e360. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark-
#pragma mark NSObject
@interface NSObject (Utils_Category);
@property(nonatomic, readonly) NSMutableDictionary *prototype;
-(id)duplicate;
@end


#pragma mark-
#pragma mark NSNull
@interface NSNull (Utils_Category)
-(long long)longLongValue;
-(NSInteger)integerValue;
-(double)doubleValue;
-(float)floatValue;
-(BOOL)boolValue;
-(int)intValue;
@end


#pragma mark-
#pragma mark NSDate
@interface NSDate (Utils_Category)
@property(nonatomic,readonly) NSDateComponents *components;
-(id)toString:(NSString*)format;
@end


#pragma mark-
#pragma mark NSString
@interface NSString (Utils_Category)
+(id)temporaryAppend:(NSString *)path;
+(id)resourceAppend:(NSString *)path;
+(id)documentAppend:(NSString *)path;
+(id)libraryAppend:(NSString *)path;
+(id)uuid;
//
-(id)toDate:(NSString*)format;
-(id)base64Encoded;
-(id)base64Decoded;
-(id)md5;
@end


#pragma mark-
#pragma mark UIDevice
UIKIT_EXTERN NSString *const UIDeviceNetWorkDidChangeNotification;
typedef NS_ENUM(NSInteger, UIDeviceNetwork) {
    UIDeviceNetworkNone,
    UIDeviceNetworkWiFi,
    UIDeviceNetworkWWAN
};
@interface UIDevice (Utils_Category)
@property(nonatomic, readonly) UIDeviceNetwork network;
@end


#pragma mark-
#pragma mark UIColor
@interface UIColor (Utils_Category)
@property(assign, nonatomic) NSInteger hex;
+(UIColor*)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha;
+(UIColor*)colorWithHex:(NSInteger)hex;
@end


#pragma mark-
#pragma mark UIView
@interface UIView (Utils_Category)
@property(assign, nonatomic) IBInspectable CGFloat corner;
@property(assign, nonatomic) IBInspectable CGFloat borderWidth;
@property(strong, nonatomic) IBInspectable UIColor *borderColor;
-(void)setCorner:(UIRectCorner)corners radii:(CGFloat)radii;
-(UIImage*)snapshot;
@end


#pragma mark-
#pragma mark UIImage
@interface UIImage (Utils_Category)
-(UIImage*)insert:(CGSize)size;
@end


#pragma mark-
#pragma mark UIImageView
@interface UIImageView (TMLoader)
@property(copy, nonatomic) NSString *src;
@property(strong, nonatomic) IBInspectable UIColor *blend;
-(void)load:(NSString*)file base:(NSString*)base;
@end
