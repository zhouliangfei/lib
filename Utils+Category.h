//
//  NSObject+Category.h
//  Board2D
//
//  Created by mac on 14-5-4.
//  Copyright (c) 2014年 e360. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef Utils_Category_h
#define Utils_Category_h
#define CGAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]
//CGPoint*****************************************
CGFloat CGPointAngle(CGPoint a,CGPoint b);
CGFloat CGPointDistance(CGPoint a,CGPoint b);
CGFloat CGPointCross(CGPoint a,CGPoint b,CGPoint c);
BOOL CGPointIntersect(CGPoint a,CGPoint b,CGPoint c,CGPoint d, CGPoint *o);
#endif

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
@property(nonatomic,copy) NSString *check;
@end

//UIImage****************************************
@interface UIImage(Utils_Category)
+(id)imageWithSource:(NSString*)path;
+(id)imageWithLibrary:(NSString*)path;
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
@property(nonatomic,retain) NSString *URL;
-(void)setURL:(NSString*)URLString onComplete:(void (^)(id target))onComplete;
//
+(id)viewWithSource:(NSString*)source;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source;
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent library:(NSString*)library;
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
    NSURLLoaderCachePolicyNULL,
    NSURLLoaderCachePolicyLoadData,
    NSURLLoaderCachePolicyLocalData
};
typedef NSInteger NSURLLoaderCachePolicy;
//
@interface NSURLRequest(Utils_Category)
+(NSURLRequest*)requestWithURL:(NSURL*)URL post:(id)post;
@end
//
@interface NSURLLoader : NSOperation<NSStreamDelegate>{
    BOOL finished;
    NSURLLoaderCachePolicy priority;
    //
    NSData *bitData;
    NSError *loadError;
    NSString *fileName;
    NSOutputStream *writeStream;
}
+(NSOperationQueue*)queue;
+(NSURLLoader*)load:(NSURLRequest*)urlRequest priority:(NSURLLoaderCachePolicy)priority open:(void (^)(NSURLLoader *target))open progress:(void (^)(NSURLLoader *target))progress complete:(void (^)(NSURLLoader *target,NSError *error))complete;
//
-(NSURLLoader*)initWithPriority:(NSURLLoaderCachePolicy)urlPriority;
-(void)load:(NSURLRequest*)urlRequest;
-(void)close;
//
@property(nonatomic,retain) id identifier;
@property(nonatomic,retain) NSURLRequest *request;
@property(nonatomic,copy) void (^onOpen)(NSURLLoader *target);
@property(nonatomic,copy) void (^onProgress)(NSURLLoader *target);
@property(nonatomic,copy) void (^onComplete)(NSURLLoader *target ,NSError *error);
@property(nonatomic,readonly) unsigned long long bytesLoaded;
@property(nonatomic,readonly) unsigned long long bytesTotal;
@property(nonatomic,readonly) NSURLConnection *connection;
@property(nonatomic,readonly) NSData *data;
@end

//***************************************************************************************************
@interface Utils : NSObject
//路径
+(NSString*)pathForResource:(NSString*)path;
+(NSString*)pathForTemporary:(NSString*)path;
+(NSString*)pathForDocument:(NSString*)path;
+(NSString*)pathForLibrary:(NSString*)path;
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
