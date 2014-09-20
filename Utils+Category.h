//
//  NSObject+Category.h
//  lib
//
//  Created by mac on 14-5-4.
//  Copyright (c) 2014年 383541328@qq.com. All rights reserved.
//
#import <UIKit/UIKit.h>

//NSGlobal****************************************
@interface NSGlobal : NSObject;
+(void)setValue:(id)value forKey:(NSString*)forKey;
+(id)valueForKey:(NSString*)forKey;
@end

//NSJson****************************************
@interface NSJson : NSObject
+(id)parse:(NSString*)object;
+(NSString*)stringify:(id)object;
@end

//NSNull****************************************
@interface NSNull (Utils_Category)
-(double)doubleValue;
-(float)floatValue;
-(int)intValue;
-(NSInteger)integerValue;
-(long long)longLongValue;
-(BOOL)boolValue;
@end

//NSObject****************************************
@interface NSObject (Utils_Category)
@property(nonatomic,retain) id source;
@property(nonatomic,retain) id value;
@end

//NSString****************************************
NSString* MD5(NSString* string);
NSString* NSDocuments(void);
NSString* NSStringFromColor(UIColor* color);
@interface NSString (Utils_Category)
-(id)dateFromFormatter:(NSString*)format;
@end

//NSDate****************************************
@interface NSDate (Utils_Category)
-(id)stringFromFormatter:(NSString*)format;
@end

//UIColor****************************************
UIColor* UIColorFromString(NSString *string);
@interface UIColor(Utils_Category)
@property(nonatomic,readonly) UIImage *image;
+(UIColor*)colorWithHex:(uint)value;
@end

//UIDevice****************************************
typedef NS_ENUM(NSInteger, UIDeviceNetwork) {
    UIDeviceNetworkNone,
    UIDeviceNetworkWiFi,
    UIDeviceNetworkWWAN
};
typedef NS_ENUM(NSInteger, UIDeviceIdiom) {
    UIDeviceIdiomNULL,
    UIDeviceIdiomIpad,
    UIDeviceIdiomIphone,
    UIDeviceIdiomIphone5
};

UIKIT_EXTERN NSString *const UIDeviceNetWorkDidChangeNotification;
@interface UIDevice(Utils_Category)
@property(nonatomic,readonly) UIDeviceNetwork network;
@property(nonatomic,readonly) UIDeviceIdiom idiom;
@end

//UIImage****************************************
@interface UIImage(Utils_Category)
+(id)imageWithDocument:(NSString*)path;
+(id)imageWithResource:(NSString*)path;
+(id)imageWithTemporary:(NSString*)path;
@end

//UIView****************************************
@interface UIView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent;
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent background:(UIColor*)background;
-(id)convertImage;
@end

//UIControl****************************************
@interface UIControl(Utils_Category)
-(void)removeAllTarget;
@end

//UIImageView****************************************
@interface UIImageView(Utils_Category)
@property(nonatomic,retain) NSURL *URL;
-(void)setURL:(NSURL*)URL onComplete:(void (^)(id target))onComplete;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent document:(NSString*)document;
@end

//UILabel****************************************
@interface UILabel(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align;
@end

//UITextField****************************************
@interface UITextField(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align;
@end

//UITextView****************************************
@interface UITextView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align;
@end
 
//UIButton****************************************
@interface UIButton(Utils_Category)
-(void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent target:(id)target event:(SEL)event;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source target:(id)target event:(SEL)event;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event;
@end

//UICollectionView****************************************
@interface UICollectionView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent layout:(UICollectionViewLayout*)layout;
@end

//UIViewController****************************************
typedef NS_ENUM(NSInteger, UITransitionStyle) {
    UITransitionStyleNULL,
    UITransitionStyleDissolve,
    UITransitionStyleCoverVertical,
    UITransitionStyleCoverHorizontal
};
@interface UIViewController (Utils_Category)
@property(nonatomic,assign) UITransitionStyle transitionStyle;
@end

//***************************************************************************************************
enum{
    NSLoaderCachePolicyNULL,
    NSLoaderCachePolicyLoadData,
    NSLoaderCachePolicyLocalData
};
typedef NSInteger NSLoaderCachePolicy;

@interface NSLoader : NSObject
+(id)request:(NSURL*)url post:(id)post priority:(NSLoaderCachePolicy)priority complete:(void (^)(NSLoader *target))complete;
-(void)request:(NSURL*)url post:(id)post priority:(NSLoaderCachePolicy)priority complete:(void (^)(NSLoader *target))complete;
@property(nonatomic,readonly) NSURLConnection *connection;
@property(nonatomic,readonly) NSData *data;
@property(nonatomic,readonly) NSURL *URL;
-(void)clear;
@end

//***************************************************************************************************
@interface Utils : NSObject
//路径
+(NSString*)pathForDocument:(NSString*)path;
+(NSString*)pathForResource:(NSString*)path;
+(NSString*)pathForTemporary:(NSString*)path;
//顶层
+(id)uuid;
+(id)iosVersion;
+(id)appVersion;
+(id)duplicate:(id)target;
//参数
+(id)parameter;
+(void)setParameter:(id)parameter;
//跳转
+(UINavigationController*)rootViewController;
+(id)gotoWithName:(NSString*)name animated:(UITransitionStyle)animated;
+(id)back;
+(id)openWithName:(NSString*)name;
+(id)close;
@end
