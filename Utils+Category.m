//
//  NSObject+Category.m
//  lib
//
//  Created by mac on 14-5-4.
//  Copyright (c) 2014年 tinymedia.cn All rights reserved.
//
#ifndef Utils_Category_m
#define Utils_Category_m
#define COLOR_RGBFORMAT                       @"0x%02X%02X%02X"
#define UTILS_PARAMETER                       @"Utils::Parameter"
#define OBJC_UIDEVICE_CHECK                   "objc::UIDevice::Check"
#define OBJC_NSOBJECT_VALUE                   "objc::NSObject::Value"
#define OBJC_NSOBJECT_SOURCE                  "objc::NSObject::Source"
#define OBJC_UIIMAGEVIEW_URL                  "objc::UIImageView::URL"
#define OBJC_UIALERTVIEW_CLICK                "objc::UIAlertView::Click"
#define OBJC_UIVIEWCONTROLLER_TRANSITIONSTYLE "objc::UIViewController::TransitionStyle"
#endif

#import "Utils+Category.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>


//NSGlobal****************************************
@implementation NSGlobal;
+(NSMutableDictionary*)shareGlobal{
    static NSMutableDictionary *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSMutableDictionary alloc] init];
    });
    return instance;
}
+(void)setValue:(id)value forKey:(NSString*)forKey{
    [[self shareGlobal] setValue:value forKey:forKey];
}
+(id)valueForKey:(NSString*)forKey{
    return [[self shareGlobal] valueForKey:forKey];
}
@end

//NSJson****************************************
@implementation NSJson
+(id)parse:(NSString*)object{
    if ([object isKindOfClass:[NSString class]]){
        NSData *data = [object dataUsingEncoding: NSUTF8StringEncoding];
        if (data) {
            NSError *error = nil;
            id temp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (nil == error && [NSJSONSerialization isValidJSONObject:temp]){
                return temp;
            }
        }
    }
    return nil;
}
+(NSString*)stringify:(id)object{
    if ([NSJSONSerialization isValidJSONObject:object]){
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (nil==error){
            return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return nil;
}
@end

//NSNull****************************************
@implementation NSNull (Utils_Category)
-(double)doubleValue{
    return 0.f;
}
-(float)floatValue{
    return 0.f;
}
-(int)intValue{
    return 0;
}
-(NSInteger)integerValue{
    return 0;
}
-(long long)longLongValue{
    return 0.f;
}
-(BOOL)boolValue{
    return NO;
}
@end

//NSObject****************************************
@implementation NSObject (Utils_Category)
@dynamic source;
@dynamic value;
-(void)setSource:(id)source{
    objc_setAssociatedObject(self, OBJC_NSOBJECT_SOURCE, source, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)source{
    return objc_getAssociatedObject(self, OBJC_NSOBJECT_SOURCE);
}
-(void)setValue:(id)value{
    objc_setAssociatedObject(self, OBJC_NSOBJECT_VALUE, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(id)value{
    return objc_getAssociatedObject(self, OBJC_NSOBJECT_VALUE);
}
@end

//NSString****************************************
NSString* MD5(NSString* string){
    if (string && [string isKindOfClass:[NSString class]]) {
        const char *cStr = [string UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
        
        NSMutableString *temp = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for(uint i=0; i<CC_MD5_DIGEST_LENGTH; i++){
            [temp appendFormat:@"%02x",result[i]];
        }
        return [temp lowercaseString];
    }
    return nil;
}
NSString* NSDocuments(void){
    return [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
}
NSString* NSStringFromColor(UIColor* color){
    if (color && [color isKindOfClass:[UIColor class]]) {
        const CGFloat *c = CGColorGetComponents(color.CGColor);
        int rc = 255.0 * c[0];
        int gc = 255.0 * c[1];
        int bc = 255.0 * c[2];
        return [NSString stringWithFormat:COLOR_RGBFORMAT,rc,gc,bc];
    }
    return nil;
}
@implementation NSString (Utils_Category)
-(id)dateFromFormatter:(NSString*)format{
    if (format && [format isKindOfClass:[NSString class]]) {
        NSDateFormatter *formatter=[[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:format];
        return [formatter dateFromString:self];
    }
    return nil;
}
@end

//NSDate****************************************
@implementation NSDate (Utils_Category)
-(id)stringFromFormatter:(NSString*)format{
    if (format && [format isKindOfClass:[NSString class]]) {
        NSDateFormatter *formatter=[[[NSDateFormatter alloc] init] autorelease];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:format];
        return [formatter stringFromDate:self];
    }
    return nil;
}
@end

//UIColor****************************************
UIColor* UIColorFromString(NSString *string){
    if (string && [string isKindOfClass:[NSString class]]) {
        unsigned color;
        [[NSScanner scannerWithString:string] scanHexInt:&color];
        return [UIColor colorWithHex:color];
    }
    return nil;
}
@implementation UIColor(Utils_Category)
@dynamic image;
+(UIColor*)colorWithHex:(uint)value{
    float rc = (value & 0xFF0000) >> 16;
    float gc = (value & 0xFF00) >> 8;
    float bc = (value & 0xFF);
    return [UIColor colorWithRed:rc/255.0 green:gc/255.0 blue:bc/255.0 alpha:1.0];
}
-(id)image{
    CGRect rect=CGRectMake(0.0, 0.0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), self.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    UIImage *colorImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImg;
}
@end

//UIDevice****************************************
NSString *const UIDeviceNetWorkDidChangeNotification = @"UIDeviceNetWorkDidChangeNotification";
@implementation UIDevice(Utils_Category)
@dynamic network,check;
//
static UIDeviceNetwork network;
static SCNetworkReachabilityRef reachability=NULL;
static void detectNetworkCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info){
	UIDevice *device = (UIDevice*)info;
    [device netWorkDidChange:flags];
}
+(id)alloc{
    UIDevice *currentDevice=[UIDevice allocWithZone:NSDefaultMallocZone()];
    if (currentDevice) {
        network=UIDeviceNetworkNone;
        reachability=SCNetworkReachabilityCreateWithName(NULL, "0.0.0.0");
        if(reachability) {
            SCNetworkReachabilityContext context={0, (void*)currentDevice, NULL, NULL, NULL};
            SCNetworkReachabilitySetCallback(reachability, detectNetworkCallback, &context);
            SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            //抓取状态
            SCNetworkReachabilityFlags flags=0;
            BOOL retrieveFlags=SCNetworkReachabilityGetFlags(reachability, &flags);
            if(retrieveFlags){
                [currentDevice netWorkDidChange:flags];
            }
        }
    }
    return currentDevice;
}
-(void)setCheck:(NSString *)check{
    objc_setAssociatedObject(self, OBJC_UIDEVICE_CHECK, check, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //抓取状态
    SCNetworkReachabilityFlags flags=0;
    BOOL retrieveFlags=SCNetworkReachabilityGetFlags(reachability, &flags);
    if(retrieveFlags){
        [self netWorkDidChange:flags];
    }
}
-(NSString *)check{
    return objc_getAssociatedObject(self, OBJC_UIDEVICE_CHECK);
}
-(UIDeviceIdiom)idiom{
    static UIDeviceIdiom type=UIDeviceIdiomNULL;
    if (type==UIDeviceIdiomNULL) {
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone){
            if ([[UIScreen mainScreen] bounds].size.height==568) {
                type=UIDeviceIdiomIphone5;
            }else{
                type=UIDeviceIdiomIphone;
            }
        } else{
            type=UIDeviceIdiomIpad;
        }
    }
    return type;
}
-(UIDeviceNetwork)network{
    return network;
}
-(void)netWorkDidChange:(SCNetworkReachabilityFlags)flags{
    UIDeviceNetwork temp = UIDeviceNetworkNone;
    if(flags & kSCNetworkReachabilityFlagsReachable){
        if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
            temp = UIDeviceNetworkWiFi;
        }
        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)){
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
                temp = UIDeviceNetworkWiFi;
            }
        }
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
            temp = UIDeviceNetworkWWAN;
        }
    }
    if (temp!=UIDeviceNetworkNone && self.check) {
        SCNetworkReachabilityRef reachability=SCNetworkReachabilityCreateWithName(NULL, [self.check UTF8String]);
        if(reachability){
            //抓取状态
            BOOL retrieveFlags=SCNetworkReachabilityGetFlags(reachability, &flags);
            CFRelease(reachability);
            if (NO==retrieveFlags || flags==0) {
                temp=UIDeviceNetworkNone;
            }
        }else{
            temp=UIDeviceNetworkNone;
        }
    }
    if (temp!=network) {
        network=temp;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceNetWorkDidChangeNotification object:[NSNumber numberWithInteger:network]];
    }
}
@end

//UIImage****************************************
@implementation UIImage(Utils_Category)
+(id)imageWithDocument:(NSString*)path{
    return [UIImage imageWithContentsOfFile:[Utils pathForDocument:path]];
}
+(id)imageWithResource:(NSString*)path{
    return [UIImage imageWithContentsOfFile:[Utils pathForResource:path]];
}
+(id)imageWithTemporary:(NSString*)path{
    return [UIImage imageWithContentsOfFile:[Utils pathForTemporary:path]];
}
@end

//UIView****************************************
@implementation UIView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UIView *temp=[[self.class alloc] initWithFrame:frame];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent background:(UIColor*)background{
    UIView *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setBackgroundColor:background];
    return temp;
}
-(id)roundingCorners:(UIRectCorner)corners size:(CGFloat)size{
    UIBezierPath *maskPath=[UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(size, size)];
    CAShapeLayer *maskLayer=[[CAShapeLayer alloc] init];
    [maskLayer setPath:maskPath.CGPath];
    [maskLayer setFrame:self.bounds];
    [self.layer setMask:maskLayer];
    [maskLayer release];
    return self;
}
-(id)convertImage{
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tempImage;
}
@end

//UIControl****************************************
@implementation UIControl(Utils_Category)
-(void)removeAllTarget{
    for (id target in [self allTargets]) {
        [self removeTarget:target action:NULL forControlEvents:UIControlEventAllEvents];
    }
}
@end

//UIImageView****************************************
@implementation UIImageView(Utils_Category)
@dynamic URL;
+(id)viewWithSource:(NSString*)source{
    UIImage *image=[UIImage imageWithResource:source];
    UIImageView *temp=[[self.class alloc] initWithImage:image];
    [temp setContentMode:UIViewContentModeScaleAspectFit];
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UIImageView *temp=[[self.class alloc] initWithFrame:frame];
    [temp setContentMode:UIViewContentModeScaleAspectFit];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source{
    UIImageView *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageWithResource:source]];
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent document:(NSString*)document{
    UIImageView *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageWithDocument:document]];
    return temp;
}
//移魂大法重写dealloc
//+load是在一个类最开始加载时调用
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod=class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        Method newMethod=class_getInstanceMethod([self class], @selector(__dealloc__));
        method_exchangeImplementations(oriMethod, newMethod);
    });
}
-(void)__dealloc__{
    [self.loader cancel];
    [self setImage:nil];
    [self __dealloc__];
}
-(NSLoader*)loader{
    const void *loaderKey="loader_key";
    NSLoader *temp=objc_getAssociatedObject(self, loaderKey);
    if (nil==temp) {
        temp=[[NSLoader alloc] init];
        objc_setAssociatedObject(self, loaderKey, temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [temp release];
    }
    return temp;
}
//从网络加载
-(void)setURL:(NSURL*)URL{
    [self setURL:URL preview:nil onComplete:nil];
}
-(NSURL*)URL{
    return objc_getAssociatedObject(self, OBJC_UIIMAGEVIEW_URL);
}
-(void)setURL:(NSURL*)URL preview:(UIImage*)preview onComplete:(void (^)(id target))onComplete{
    objc_setAssociatedObject(self, OBJC_UIIMAGEVIEW_URL, URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self performSelectorOnMainThread:@selector(setImage:) withObject:preview waitUntilDone:YES];
    //
    __block UIImageView *blockSelf=self;
    [self.loader request:URL post:nil cache:nil priority:NSLoaderCachePolicyLocalData progress:nil complete:^(NSLoader *target) {
        [blockSelf performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:target.data] waitUntilDone:YES];
        if (onComplete) {
            onComplete(blockSelf);
        }
    }];
}
@end

//UILabel****************************************
@implementation UILabel(Utils_Category)
+(instancetype)alloc{
    UILabel *temp=[self.class allocWithZone:NSDefaultMallocZone()];
    if (temp) {
        [temp setBackgroundColor:[UIColor clearColor]];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    return [self viewWithFrame:frame parent:parent text:text font:nil color:nil align:NSTextAlignmentLeft];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UILabel *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setTextAlignment:align];
    if (color) {
        [temp setTextColor:color];
    }
    if (font) {
        [temp setFont:font];
    }
    if (text) {
        [temp setText:text];
    }
    return temp;
}
@end

//UITextField****************************************
@implementation UITextField(Utils_Category)
+(instancetype)alloc{
    UITextField *temp=[self.class allocWithZone:NSDefaultMallocZone()];
    if (temp) {
        [temp setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [temp setAutocorrectionType:UITextAutocorrectionTypeNo];
        [temp setSpellCheckingType:UITextSpellCheckingTypeNo];
        [temp setBackgroundColor:[UIColor clearColor]];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    return [self viewWithFrame:frame parent:parent text:text font:nil color:nil align:NSTextAlignmentLeft];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UITextField *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setTextAlignment:align];
    if (color) {
        [temp setTextColor:color];
    }
    if (font) {
        [temp setFont:font];
    }
    if (text) {
        [temp setText:text];
    }
    return temp;
}
@end

//UITextView****************************************
@implementation UITextView(Utils_Category)
+(instancetype)alloc{
    UITextView *temp=[self.class allocWithZone:NSDefaultMallocZone()];
    if (temp) {
        [temp setBackgroundColor:[UIColor clearColor]];
        [temp setEditable:NO];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    return [self viewWithFrame:frame parent:parent text:text font:nil color:nil align:NSTextAlignmentLeft];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UITextView *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setTextAlignment:align];
    if (color) {
        [temp setTextColor:color];
    }
    if (font) {
        [temp setFont:font];
    }
    if (text) {
        [temp setText:text];
    }
    return temp;
}
@end

//UIButton****************************************
@implementation UIButton(Utils_Category)
-(void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state{
    [self setBackgroundImage:color.image forState:state];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent target:(id)target event:(SEL)event{
    return [self viewWithFrame:frame parent:parent normal:nil active:nil text:nil font:nil color:nil target:target event:event];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal target:(id)target event:(SEL)event{
    return [self viewWithFrame:frame parent:parent normal:normal active:nil text:nil font:nil color:nil target:target event:event];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active target:(id)target event:(SEL)event{
    return [self viewWithFrame:frame parent:parent normal:normal active:active text:nil font:nil color:nil target:target event:event];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event{
    return [self viewWithFrame:frame parent:parent normal:nil active:nil text:text font:font color:color target:target event:event];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent normal:(NSString*)normal active:(NSString*)active text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event{
    UIButton *temp=[self.class viewWithFrame:frame parent:parent];
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    if (active) {
        [temp setImage:[UIImage imageWithResource:active] forState:UIControlStateHighlighted];
        [temp setImage:[UIImage imageWithResource:active] forState:UIControlStateSelected];
    }
    if (normal) {
        [temp setImage:[UIImage imageWithResource:normal] forState:UIControlStateNormal];
    }
    if (color) {
        [temp setTitleColor:color forState:UIControlStateNormal];
    }
    if (text) {
        [temp setTitle:text forState:UIControlStateNormal];
    }
    if (font) {
        [temp.titleLabel setFont:font];
    }
    return temp;
}
@end


//UIPickerView****************************************
@implementation UIPickerView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent{
    //高=216
    UIPickerView *temp = [[self.class alloc] initWithFrame:frame];
    [temp setShowsSelectionIndicator:YES];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
@end

//UITableView****************************************
@implementation UITableView(Utils_Category)
+(instancetype)alloc{
    UITableView *temp=[self.class allocWithZone:NSDefaultMallocZone()];
    if ([temp respondsToSelector:@selector(setSeparatorInset:)]) {
        [temp setSeparatorInset:UIEdgeInsetsZero];
    }
    return temp;
}
@end

//UICollectionView****************************************
@implementation UICollectionView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent{
    return [self.class viewWithFrame:frame parent:parent layout:nil];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent background:(UIColor *)background{
    UICollectionView *temp=[self.class viewWithFrame:frame parent:parent layout:nil];
    [temp setBackgroundColor:background];
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent layout:(UICollectionViewLayout*)layout{
    if (layout==nil) {
        layout=[[[UICollectionViewFlowLayout alloc] init] autorelease];
        [(UICollectionViewFlowLayout*)layout setMinimumInteritemSpacing:0];
        [(UICollectionViewFlowLayout*)layout setMinimumLineSpacing:0];
    }
    UICollectionView *temp=[[self.class alloc] initWithFrame:frame collectionViewLayout:layout];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
@end

//UIActivityIndicatorView*************************
@implementation UIActivityIndicatorView(Utils_Category)
static NSInteger referenceCount;
+(id)shareInstance{
    static UIActivityIndicatorView *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
        [instance setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [instance setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.4]];
        [[instance layer] setCornerRadius:5.0];
        referenceCount=0;
    });
    return instance;
}
+(void)display{
    [[self shareInstance] performSelectorOnMainThread:@selector(display) withObject:nil waitUntilDone:YES];
}
+(void)hidden{
    [[self shareInstance] performSelectorOnMainThread:@selector(hidden) withObject:nil waitUntilDone:YES];
}
//
-(void)display{
    referenceCount++;
    UIView *root=[Utils keyWindow];
    if (root) {
        [self setCenter:root.center];
        [root addSubview:self];
        [self startAnimating];
        [self setHidden:NO];
    }
}
-(void)hidden{
    referenceCount--;
    if (referenceCount==0 && self.superview) {
        [self removeFromSuperview];
        [self setHidden:YES];
        [self stopAnimating];
    }
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return !self.hidden;
}
@end

//UIAlertView****************************************
@implementation UIAlertView(Utils_Category)
+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message onClick:(void (^)(UIAlertView *alertView, NSInteger index))onClick cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
    //
    id arg;
    va_list argList;
    va_start(argList,otherButtonTitles);
    while ((arg=va_arg(argList,id))){
        [alertView addButtonWithTitle:arg];
    }
    va_end(argList);
    //
    [alertView setDelegate:alertView];
    [alertView setOnClick:onClick];
    [alertView show];
    return [alertView autorelease];
}
+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView performSelector:@selector(autoClose) withObject:nil afterDelay:1.5];
    [alertView show];
    return [alertView autorelease];
}
-(void)setOnClick:(void (^)(UIAlertView *alertView, NSInteger index))onClick{
    objc_setAssociatedObject(self, OBJC_UIALERTVIEW_CLICK, onClick, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void (^)(UIAlertView *alertView, NSInteger index))onClick{
    return objc_getAssociatedObject(self, OBJC_UIALERTVIEW_CLICK);
}
-(void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super dealloc];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (self.onClick) {
        self.onClick(self,buttonIndex);
    }
}
-(void)autoClose{
    [self dismissWithClickedButtonIndex:0 animated:YES];
}
@end

//UIViewController****************************************
@implementation UIViewController (Utils_Category)
@dynamic transitionStyle;
-(void)setTransitionStyle:(UITransitionStyle)value{
    objc_setAssociatedObject(self, OBJC_UIVIEWCONTROLLER_TRANSITIONSTYLE, [NSNumber numberWithInteger:value], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UITransitionStyle)transitionStyle{
    return [objc_getAssociatedObject(self, OBJC_UIVIEWCONTROLLER_TRANSITIONSTYLE) integerValue];
}
@end

//***************************************************************************************************
@interface NSLoader()<NSStreamDelegate>{
    BOOL isFinish;
    NSLoaderCachePolicy tmpPriority;
}
@property(atomic,copy) void (^tmpOnProgress)(NSLoader *target);
@property(atomic,copy) void (^tmpOnComplete)(NSLoader *target);
@property(atomic,retain) NSURLConnection *tmpConnection;
@property(atomic,retain) NSOutputStream *tmpStream;
@property(atomic,retain) NSString *tmpCache;
@property(atomic,retain) NSError *tmpError;
@property(atomic,retain) NSData *tmpData;
@property(atomic,retain) NSURL *tmpURL;
@end
//
@implementation NSLoader
@synthesize tmpOnProgress,tmpOnComplete,tmpConnection,tmpStream,tmpCache,tmpError,tmpData,tmpURL;
@synthesize bytesLoaded,bytesTotal;
@dynamic connection,error,data,URL;
+(id)request:(NSURL*)url post:(id)post cache:(NSString*)cache priority:(NSLoaderCachePolicy)priority progress:(void (^)(NSLoader *target))progress complete:(void (^)(NSLoader *target))complete{
    NSLoader *temp = [[NSLoader alloc] init];
    [temp request:url post:post cache:cache priority:priority progress:progress complete:complete];
    return [temp autorelease];
}
-(void)request:(NSURL*)url post:(id)post cache:(NSString*)cache priority:(NSLoaderCachePolicy)priority progress:(void (^)(NSLoader *target))progress complete:(void (^)(NSLoader *target))complete{
    [self cancel];
    if (url) {
        [self setTmpOnProgress:progress];
        [self setTmpOnComplete:complete];
        [self setTmpURL:url];
        tmpPriority=priority;
        isFinish=NO;
        //
        if (cache) {
            [self setTmpCache:[Utils hashPath:cache]];
        }else{
            [self setTmpCache:[Utils hashPath:url.absoluteString]];
        }
        //
        BOOL hasCache=NO;
        NSString *filePath=[Utils pathForDocument:tmpCache];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            bytesLoaded=[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
            bytesTotal=bytesLoaded;
            hasCache=YES;
        }
        if ((hasCache && NSLoaderCachePolicyLocalData==priority) || UIDeviceNetworkNone==[[UIDevice currentDevice] network]) {
            isFinish=YES;
            if (tmpOnComplete) {
                tmpOnComplete(self);
            }
        }else{
            NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
            //取已下载的数据大小
            NSString *tempPath=[Utils pathForTemporary:tmpCache];
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
                bytesLoaded=[[[NSFileManager defaultManager] attributesOfItemAtPath:tempPath error:nil] fileSize];
                [request addValue:[NSString stringWithFormat:@"bytes=%llu-", bytesLoaded] forHTTPHeaderField:@"Range"];
            }
            if (post) {
                if ([post isKindOfClass:[NSDictionary class]]) {
                    //post数据
                    NSString *boundary = @"64F4845541AEA084";
                    NSMutableData *body = [NSMutableData data];
                    for(NSString *key in [post allKeys]){
                        id value = [post objectForKey:key];
                        if (value) {
                            if([value isKindOfClass:[NSData class]]){
                                NSString *temp = [NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, key];
                                [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                                [body appendData:[NSData dataWithData:value]];
                            }else{
                                NSString *temp = [NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@", boundary, key, value];
                                [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                            }
                        }
                    }
                    NSString *temp = [NSString stringWithFormat:@"\r\n--%@--",boundary];
                    [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                    //
                    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
                    [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[body length]] forHTTPHeaderField:@"Content-Length"];
                    [request setHTTPBody:body];
                }
                if ([post isKindOfClass:[NSString class]]) {
                    NSData *body=[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                    //
                    [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded;"] forHTTPHeaderField:@"Content-Type"];
                    [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[body length]] forHTTPHeaderField:@"Content-Length"];
                    [request setHTTPBody:body];
                }
                if ([post isKindOfClass:[NSData class]]) {
                    [request setValue:[NSString stringWithFormat:@"application/octet-stream;"] forHTTPHeaderField:@"Content-Type"];
                    [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[post length]] forHTTPHeaderField:@"Content-Length"];
                    [request setHTTPBody:post];
                }
                [request setHTTPMethod:@"POST"];
            }
            //
            [self openStream:request savePath:[Utils pathForTemporary:tmpCache]];
            if (nil==tmpOnProgress && nil==tmpOnComplete) {
                //模拟同步
                do{
                    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                }while(!isFinish);
            }
        }
    }else{
        if (tmpOnComplete) {
            tmpOnComplete(self);
        }
    }
}
//
-(NSURLConnection*)connection{
    return tmpConnection;
}
-(NSError *)error{
    return tmpError;
}
-(NSURL*)URL{
    return tmpURL;
}
-(NSData*)data{
    if (nil==self.error) {
        if (tmpData) {
            return tmpData;
        }
        NSString *filePath=[Utils pathForDocument:tmpCache];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return [NSMutableData dataWithContentsOfFile:filePath];
        }
    }
    return nil;
}
//
-(void)cancel{
    isFinish=YES;
    bytesTotal=0;
    bytesLoaded=0;
    tmpPriority=NSLoaderCachePolicyNULL;
    //
    [self closeStream];
    [self setTmpURL:nil];
    [self setTmpData:nil];
    [self setTmpError:nil];
    [self setTmpCache:nil];
    [self setTmpOnComplete:nil];
    [self setTmpOnProgress:nil];
}
-(void)openStream:(NSURLRequest*)request savePath:(NSString*)savePath{
    [self closeStream];
    if (nil==tmpConnection) {
        [self setTmpConnection:[NSURLConnection connectionWithRequest:request delegate:self]];
    }
    if (nil==tmpStream) {
        [self setTmpStream:[NSOutputStream outputStreamToFileAtPath:savePath append:YES]];
        if (tmpStream) {
            [tmpStream open];
        }
    }
}
-(void)closeStream{
    if (tmpConnection) {
        [tmpConnection cancel];
        [self setTmpConnection:nil];
    }
    if (tmpStream) {
        [tmpStream close];
        [self setTmpStream:nil];
    }
}
//
-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ([self connection]==connection) {
        //清除错误文件
        NSString *tempPath=[Utils pathForTemporary:tmpCache];
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        }
        //完成
        isFinish=YES;
        [self closeStream];
        [self setTmpData:nil];
        [self setTmpError:error];
        if (tmpOnComplete) {
            tmpOnComplete(self);
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    if ([self connection]==connection) {
        NSHTTPURLResponse *httpResponse=(NSHTTPURLResponse *)response;
        if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
            bytesTotal=[[[httpResponse allHeaderFields] objectForKey:@"Content-Length"] longLongValue];
        }
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if ([self connection]==connection && tmpStream) {
        const uint8_t *dataBytes=[data bytes];
        NSInteger dataLength=[data length];
        NSInteger bytesWrittenSoFar=0;
        NSInteger bytesWritten=0;
        do {
            bytesWritten=[tmpStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength-bytesWrittenSoFar];
            assert(bytesWritten!=0);
            if (bytesWritten==-1) {
                break;
            } else {
                bytesWrittenSoFar+=bytesWritten;
            }
        }while(bytesWrittenSoFar!=dataLength);
        //进度
        bytesLoaded+=bytesWrittenSoFar;
        if (tmpOnProgress) {
            tmpOnProgress(self);
        }
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if ([self connection]==connection) {
        NSString *tempPath=[Utils pathForTemporary:tmpCache];
        if (NSLoaderCachePolicyNULL!=tmpPriority) {
            NSString *filePath=[Utils pathForDocument:tmpCache];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
                [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:filePath error:nil];
            }
        }else{
            if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
                [self setTmpData:[NSData dataWithContentsOfFile:tempPath]];
                [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
            }
        }
        //完成
        isFinish=YES;
        [self closeStream];
        if (tmpOnComplete) {
            tmpOnComplete(self);
        }
    }
}
@end

//***************************************************************************************************
@interface UIRootController : UINavigationController
@end
@implementation UIRootController
-(BOOL)shouldAutorotate{
    return [self.topViewController shouldAutorotate];
}
-(NSUInteger)supportedInterfaceOrientations{
    return [self.topViewController supportedInterfaceOrientations];
}
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}
@end
//
//
@implementation Utils
//路径
+(NSString*)pathForDocument:(NSString*)path{
    return [NSDocuments() stringByAppendingPathComponent:path];
}
+(NSString*)pathForResource:(NSString*)path{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
}
+(NSString*)pathForTemporary:(NSString*)path{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:path];
}
+(NSString*)hashPath:(NSString*)path{
    NSString *extension=[path pathExtension];
    if ([extension isEqualToString:@""]) {
        return MD5(path);
    }
    return [MD5(path) stringByAppendingPathExtension:extension];
}
//跳转
+(id)gotoWithName:(NSString*)name animated:(UITransitionStyle)animated{
    NSArray *viewControllers = [[Utils rootController] viewControllers];
    for (UIViewController *viewController in viewControllers) {
        if ([name isEqualToString:NSStringFromClass(viewController.class)]) {
            return [Utils popViewController:viewController animated:animated];
        }
    }
    Class class = NSClassFromString(name);
    if (class) {
        UIViewController *viewController=[[[class alloc] initWithNibName:nil bundle:nil] autorelease];
        return [Utils pushViewController:viewController animated:animated];
    }
    return nil;
}
+(id)back{
    NSArray *viewControllers = [[Utils rootController] viewControllers];
    if (viewControllers.count > 1) {
        UIViewController *preController = [viewControllers objectAtIndex:viewControllers.count-2];
        UIViewController *viewController = [viewControllers objectAtIndex:viewControllers.count-1];
        return [Utils popViewController:preController animated:viewController.transitionStyle];
    }
    return nil;
}
+(id)openWithName:(NSString*)name{
    Class class = NSClassFromString(name);
    if (class) {
        UIViewController *parentController = [[Utils rootController] visibleViewController];
        if (parentController) {
            UIViewController *viewController = [[[class alloc] initWithNibName:nil bundle:nil] autorelease];
            [parentController addChildViewController:viewController];
            [parentController.view addSubview:viewController.view];
            return viewController;
        }
    }
    return nil;
}
+(id)close{
    UIViewController *parentController = [[Utils rootController] visibleViewController];
    if (parentController) {
        UIViewController *viewController = [[parentController childViewControllers] lastObject];
        if (viewController) {
            [viewController removeFromParentViewController];
            [viewController.view removeFromSuperview];
            return viewController;
        }
    }
    return nil;
}
//
+(id)uuid{
    CFUUIDRef cfid=CFUUIDCreate(nil);
    CFStringRef cfidstring=CFUUIDCreateString(nil, cfid);
    CFRelease(cfid);
    NSString *uuid=(NSString *)CFStringCreateCopy(NULL,cfidstring);
    CFRelease(cfidstring);
    return [uuid autorelease];
}
+(id)iosVersion{
    return [[UIDevice currentDevice] systemVersion];
}
+(id)appVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}
+(id)duplicate:(id)target{
    NSData *temp=[NSKeyedArchiver archivedDataWithRootObject:target];
    return [NSKeyedUnarchiver unarchiveObjectWithData:temp];
}
//
+(id)parameter{
    return [[Utils parameterInstance] objectForKey:UTILS_PARAMETER];
}
+(void)setParameter:(id)parameter{
    [[Utils parameterInstance] setValue:parameter forKey:UTILS_PARAMETER];
}
+(id)parameterInstance{
    static NSMutableDictionary *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSMutableDictionary alloc] init];
    });
    return instance;
}
//
+(UIWindow*)keyWindow{
    static UIWindow *keyWindow=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyWindow=[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [keyWindow setBackgroundColor:[UIColor blackColor]];
        [keyWindow makeKeyAndVisible];
        NSLog(@"%@",NSDocuments());
    });
    return keyWindow;
}
+(UINavigationController*)rootController{
    if (nil==[[Utils keyWindow] rootViewController]) {
        UIRootController *rootViewController = [[UIRootController alloc] init];
        [[Utils keyWindow] setRootViewController:rootViewController];
        [rootViewController setNavigationBarHidden:YES];
        [rootViewController release];
    }
    return (UINavigationController*)[[Utils keyWindow] rootViewController];
}
+(UIViewController*)pushViewController:(UIViewController*)viewController animated:(UITransitionStyle)animated{
    switch (animated) {
        case UITransitionStyleDissolve:
            [Utils transitionFrom:kCATransitionFade];
            break;
        case UITransitionStyleCoverVertical:
            [Utils transitionFrom:kCATransitionFromTop];
            break;
        case UITransitionStyleCoverHorizontal:
            [Utils transitionFrom:kCATransitionFromRight];
            break;
        default:
            break;
    }
    [[Utils rootController] pushViewController:viewController animated:NO];
    [viewController setTransitionStyle:animated];
    return viewController;
}
+(UIViewController*)popViewController:(UIViewController*)viewController animated:(UITransitionStyle)animated{
    switch (animated) {
        case UITransitionStyleDissolve:
            [Utils transitionFrom:kCATransitionFade];
            break;
        case UITransitionStyleCoverVertical:
            [Utils transitionFrom:kCATransitionFromBottom];
            break;
        case UITransitionStyleCoverHorizontal:
            [Utils transitionFrom:kCATransitionFromLeft];
            break;
        default:
            break;
    }
    [[Utils rootController] popToViewController:viewController animated:NO];
    return viewController;
}
+(void)transitionFrom:(NSString*)transition{
    UIViewController *rootController = [Utils rootController];
    if (rootController) {
        NSArray *orientation=[NSArray arrayWithObjects:kCATransitionFromTop,kCATransitionFromRight,kCATransitionFromBottom,kCATransitionFromLeft, nil];
        NSUInteger index=[orientation indexOfObject:transition];
        if (index==NSNotFound) {
            CATransition *animation = [CATransition animation];
            [animation setType:transition];
            [[Utils keyWindow].layer addAnimation:animation forKey:nil];
        }else{
            switch ([rootController interfaceOrientation]){
                case UIInterfaceOrientationLandscapeLeft:
                    index=(index+1)%4;
                    break;
                case UIInterfaceOrientationPortraitUpsideDown:
                    index=(index+2)%4;
                    break;
                case UIInterfaceOrientationLandscapeRight:
                    index=(index+3)%4;
                    break;
                default:
                    break;
            }
            NSString *transitionSubType = [orientation objectAtIndex:index];
            CATransition *animation = [CATransition animation];
            [animation setSubtype:transitionSubType];
            [animation setType:kCATransitionPush];
            [[Utils keyWindow].layer addAnimation:animation forKey:nil];
        }
    }
}
@end


