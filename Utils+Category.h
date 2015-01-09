//
//  NSObject+Category.h
//  lib
//
//  Created by mac on 14-5-4.
//  Copyright (c) 2014年 tinymedia.cn All rights reserved.
//
#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

//富文本
NSAttributedString* parseAttribute(NSString *markup);

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
NSString* NSStringFromColor(UIColor* color);
@interface NSString (Utils_Category)
-(id)dateFromFormatter:(NSString*)format;
-(NSString*)base64Encoded;
-(NSString*)base64Decoded;
@end

//NSDateFormatter********************************
@interface NSDateFormatter(Utils_Category)
+(NSDateFormatter*)shareInstance;
@end

//NSDate****************************************
@interface NSDate (Utils_Category)
-(id)stringFromFormatter:(NSString*)format;
@end

//UIColor****************************************
NSNumber* NSNumberFromColor(UIColor* color);
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
@property(nonatomic,retain) NSString *check;
@end

//UIImage****************************************
@interface UIImage(Utils_Category)
+(id)imageWithResource:(NSString*)path;
+(id)imageWithMaterial:(NSString*)path;
-(UIImage*)imageWithTintColor:(UIColor*)tintColor;
@end

//UIView****************************************
@interface UIView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent;
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent background:(UIColor*)background;
-(id)roundingCorners:(UIRectCorner)corners size:(CGFloat)size;
-(id)convertImage;
@end

//UIControl****************************************
@interface UIControl(Utils_Category)
-(void)removeAllTarget;
@end

//UIImageView****************************************
@interface UIImageView(Utils_Category)
@property(nonatomic,retain) NSURL *URL;
-(void)setURL:(NSURL*)URL preview:(UIImage*)preview onComplete:(void (^)(id target))onComplete;
+(id)viewWithSource:(NSString*)source;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent material:(NSString*)material;
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
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal target:(id)target event:(SEL)event;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active target:(id)target event:(SEL)event;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event;
@end

//UICollectionView****************************************
@interface UICollectionView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent layout:(UICollectionViewLayout*)layout;
@end

//UIActivityIndicatorView*************************
@interface UIActivityIndicatorView(Utils_Category)
+(void)display;
+(void)hidden;
@end

//UIAlertView************************************
@interface UIAlertView(Utils_Category)<UIAlertViewDelegate>
+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message onClick:(void (^)(UIAlertView *alertView, NSInteger index))onClick cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message;
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
+(id)request:(NSURL*)url post:(id)post cache:(NSString*)cache priority:(NSLoaderCachePolicy)priority progress:(void (^)(NSLoader *target))progress complete:(void (^)(NSLoader *target))complete;
-(void)request:(NSURL*)url post:(id)post cache:(NSString*)cache priority:(NSLoaderCachePolicy)priority progress:(void (^)(NSLoader *target))progress complete:(void (^)(NSLoader *target))complete;
@property(nonatomic,readonly) unsigned long long bytesLoaded;
@property(nonatomic,readonly) unsigned long long bytesTotal;
@property(nonatomic,readonly) NSURLConnection *connection;
@property(nonatomic,readonly) NSError *error;
@property(nonatomic,readonly) NSData *data;
@property(nonatomic,readonly) NSURL *URL;
-(void)cancel;
@end

//***************************************************************************************************
@interface Utils : NSObject
//路径
+(NSString*)pathForResource:(NSString*)path;
+(NSString*)pathForTemporary:(NSString*)path;
+(NSString*)pathForDocument:(NSString*)path;
+(NSString*)pathForMaterial:(NSString*)path;
+(NSString*)pathForCaches:(NSString*)path;
+(NSString*)hashPath:(NSString*)path;
//顶层
+(id)uuid;
+(id)iosVersion;
+(id)appVersion;
+(id)duplicate:(id)target;
//参数
+(id)parameter;
+(void)setParameter:(id)parameter;
//跳转
+(UIWindow*)keyWindow;
+(UINavigationController*)rootController;
+(id)gotoWithName:(NSString*)name animated:(UITransitionStyle)animated;
+(id)back;
+(id)openWithName:(NSString*)name;
+(id)close;
@end
