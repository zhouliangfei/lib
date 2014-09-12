//
//  NSObject+Category.m
//  Board2D
//
//  Created by mac on 14-5-4.
//  Copyright (c) 2014年 e360. All rights reserved.
//
#ifndef Utils_Category_m
#define Utils_Category_m
#define COLOR_RGBFORMAT                       @"0x%02X%02X%02X"
#define UTILS_PARAMETER                       @"Utils::Parameter"
#define OBJC_NSOBJECT_VALUE                   "objc::NSObject::Value"
#define OBJC_NSOBJECT_SOURCE                  "objc::NSObject::Source"
#define OBJC_UIIMAGEVIEW_URL                  "objc::UIImageView::URL"
#define OBJC_UIVIEWCONTROLLER_TRANSITIONSTYLE "objc::UIViewController::TransitionStyle"
#endif

#import "Utils+Category.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>
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
    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, self.CGColor);
    CGContextFillRect(context, rect);
    UIImage *colorImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return colorImg;
}
@end

//UIDevice****************************************
NSString *const UIDeviceNetWorkDidChangeNotification = @"UIDeviceNetWorkDidChangeNotification";
@implementation UIDevice(Utils_Category)
@dynamic network;
//
static NetworkStatus network=NetworkNone;
static SCNetworkReachabilityRef reachability=nil;
static void detectNetworkCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info){
	UIDevice *device = (UIDevice*)info;
	[device netWorkDidChange];
}
+(id)alloc{
    UIDevice *device=[UIDevice allocWithZone:NSDefaultMallocZone()];
    if (device) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            network=NetworkNone;
            reachability=SCNetworkReachabilityCreateWithName(NULL, "0.0.0.0");
            if(reachability) {
                SCNetworkReachabilityContext context={0, ( void *)device, NULL, NULL, NULL};
                SCNetworkReachabilitySetCallback(reachability, detectNetworkCallback, &context);
                SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
            }
        });
    }
    return device;
}
-(NetworkStatus)network{
    return network;
}
-(void)netWorkDidChange{
    NetworkStatus temp = NetworkNone;
    SCNetworkReachabilityFlags flags = 0;
    SCNetworkReachabilityGetFlags(reachability, &flags);
    if(flags & kSCNetworkReachabilityFlagsReachable){
        if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
            temp = NetworkWiFi;
        }
        if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)){
            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0){
                temp = NetworkWiFi;
            }
        }
        if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN){
            temp = NetworkWWAN;
        }
    }
    if (temp != network) {
        network = temp;
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
    UIView *temp = [[self.class alloc] initWithFrame:frame];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent background:(UIColor*)background{
    UIView *temp = [self.class viewWithFrame:frame parent:parent];
    [temp setBackgroundColor:background];
    return temp;
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
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UIImageView *temp = [[self.class alloc] initWithFrame:frame];
    [temp setContentMode:UIViewContentModeScaleAspectFit];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source{
    UIImageView *temp = [self.class viewWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageWithResource:source]];
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent document:(NSString*)document{
    UIImageView *temp = [self.class viewWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageWithDocument:document]];
    return temp;
}
//移魂大法重写dealloc
//+load是在一个类最开始加载时调用
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Method oriMethod = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
        Method newMethod = class_getInstanceMethod([self class], @selector(__dealloc__));
        method_exchangeImplementations(oriMethod, newMethod);
    });
}
-(void)__dealloc__{
    [self setImage:nil];
    [self setHighlightedImage:nil];
    [self __dealloc__];
}
//从网络加载
-(void)setURL:(NSURL*)URL{
    [self setURL:URL onComplete:nil];
}
-(NSURL*)URL{
    return objc_getAssociatedObject(self, OBJC_UIIMAGEVIEW_URL);
}
-(void)setURL:(NSURL*)URL onComplete:(void (^)(id target))onComplete{
    objc_setAssociatedObject(self, OBJC_UIIMAGEVIEW_URL, URL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    //
    const void *loaderKey="imageLoaderKey";
    NSLoader *loader = objc_getAssociatedObject(self, loaderKey);
    if (nil==loader) {
        loader=[[[NSLoader alloc] init] autorelease];
        objc_setAssociatedObject(self, loaderKey, loader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    //
    [self setImage:nil];
    [loader request:URL post:nil priority:NSLoaderCachePolicyLocalData complete:^(NSLoader *target) {
        [self setImage:[UIImage imageWithData:target.data]];
        [target clear];
        if (onComplete) {
            onComplete(self);
        }
    }];
}
@end

//UILabel****************************************
@implementation UILabel(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    UILabel *temp = [self.class viewWithFrame:frame parent:parent];
    if (text) {
        [temp setText:text];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UILabel *temp = [self.class viewWithFrame:frame parent:parent text:text];
    [temp setTextAlignment:align];
    [temp setTextColor:color];
    [temp setFont:font];
    return temp;
}
@end

//UITextField****************************************
@implementation UITextField(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UITextField *temp = [[self.class alloc] initWithFrame:frame];
    [temp setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [temp setAutocorrectionType:UITextAutocorrectionTypeNo];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    UITextField *temp = [self.class viewWithFrame:frame parent:parent];
    if (text) {
        [temp setText:text];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UITextField *temp = [self.class viewWithFrame:frame parent:parent text:text];
    [temp setTextAlignment:align];
    [temp setTextColor:color];
    [temp setFont:font];
    return temp;
}
@end

//UITextView****************************************
@implementation UITextView(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UITextView *temp = [[self.class alloc] initWithFrame:frame];
    [temp setScrollIndicatorInsets:UIEdgeInsetsZero];
    [temp setContentInset:UIEdgeInsetsZero];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    UITextView *temp = [self.class viewWithFrame:frame parent:parent];
    if (text) {
        [temp setText:text];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UITextView *temp = [self.class viewWithFrame:frame parent:parent text:text];
    [temp setTextAlignment:align];
    [temp setTextColor:color];
    [temp setFont:font];
    return temp;
}
@end

//UIButton****************************************
@implementation UIButton(Utils_Category)
-(void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state{
    [self setBackgroundImage:color.image forState:state];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent target:(id)target event:(SEL)event{
    UIButton *temp = [self.class viewWithFrame:frame parent:parent];
    if (target && event) {
        [temp addTarget:target action:event forControlEvents:UIControlEventTouchUpInside];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source target:(id)target event:(SEL)event{
    UIButton *temp = [self.class viewWithFrame:frame parent:parent target:target event:event];
    if (source) {
        [temp setImage:[UIImage imageWithResource:source] forState:UIControlStateNormal];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event{
    UIButton *temp = [self.class viewWithFrame:frame parent:parent target:target event:event];
    if (font && color) {
        [temp setTitleColor:color forState:UIControlStateNormal];
        [temp.titleLabel setFont:font];
    }
    if (text) {
        [temp setTitle:text forState:UIControlStateNormal];
    }
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent source:(NSString*)source text:(NSString*)text font:(UIFont*)font color:(UIColor*)color target:(id)target event:(SEL)event{
    UIButton *temp = [self.class viewWithFrame:frame parent:parent text:text font:font color:color target:target event:event];
    if (source) {
        [temp setImage:[UIImage imageWithResource:source] forState:UIControlStateNormal];
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
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent{
    UITableView *temp = [[self.class alloc] initWithFrame:frame];
    if ([temp respondsToSelector:@selector(setSeparatorInset:)]) {
        [temp performSelector:@selector(setSeparatorInset:) withObject:[NSValue valueWithUIEdgeInsets:UIEdgeInsetsZero]];
    }
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
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
@interface NSLoader(){
    BOOL hasCache;
    BOOL isFinish;
    NSLoaderCachePolicy tmpPriority;
}
@property(nonatomic,copy) void (^tmpOnComplete)(NSLoader *target);
@property(nonatomic,retain) NSURLConnection *tmpConnection;
@property(nonatomic,retain) NSMutableData *tmpData;
@property(nonatomic,retain) NSURL *tmpURL;
@end
//
@implementation NSLoader
@synthesize tmpOnComplete,tmpConnection,tmpData,tmpURL;
@dynamic connection,data,URL;
+(id)request:(NSURL*)url post:(id)post priority:(NSLoaderCachePolicy)priority complete:(void (^)(NSLoader *target))complete{
    NSLoader *temp = [[NSLoader alloc] init];
    [temp request:url post:post priority:priority complete:complete];
    return [temp autorelease];
}
-(void)dealloc{
    [tmpOnComplete release];
    [tmpConnection release];
    [tmpData release];
    [tmpURL release];
    [super dealloc];
}
-(void)clear{
    [self setTmpData:nil];
}
-(void)request:(NSURL*)url post:(id)post priority:(NSLoaderCachePolicy)priority complete:(void (^)(NSLoader *target))complete{
    [self setTmpOnComplete:complete];
    [[self tmpConnection] cancel];
    [self setTmpConnection:nil];
    [self setTmpData:nil];
    [self setTmpURL:url];
    tmpPriority=priority;
    hasCache=NO;
    isFinish=NO;
    //
    if (url) {
        NSString *filePath=[Utils pathForDocument:MD5(url.absoluteString)];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            hasCache=YES;
        }
        //
        if ([[UIDevice currentDevice] network]==NetworkNone || (hasCache && NSLoaderCachePolicyLocalData==priority)) {
            if (hasCache) {
                [self setTmpData:[NSMutableData dataWithContentsOfFile:filePath]];
            }
            if (tmpOnComplete) {
                tmpOnComplete(self);
            }
        }else{
            if (url) {
                NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
                if (post) {
                    if ([post isKindOfClass:[NSDictionary class]]) {
                        //post数据
                        NSString *boundary = @"64F4845541AEA084";
                        NSMutableData *body = [NSMutableData data];
                        for(NSString *key in [post allKeys]){
                            id value = [post objectForKey:key];
                            if (value) {
                                if([value isKindOfClass:[NSData class]]){
                                    NSString *temp = [NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: attachment; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, key];
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
                        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:body];
                    }
                    if ([post isKindOfClass:[NSString class]]) {
                        NSData *body=[post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                        //
                        [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded;"] forHTTPHeaderField:@"Content-Type"];
                        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:body];
                    }
                    if ([post isKindOfClass:[NSData class]]) {
                        [request setValue:[NSString stringWithFormat:@"application/octet-stream;"] forHTTPHeaderField:@"Content-Type"];
                        [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[post length]] forHTTPHeaderField:@"Content-Length"];
                        [request setHTTPBody:post];
                    }
                    [request setHTTPMethod:@"POST"];
                }
                [self setTmpConnection:[NSURLConnection connectionWithRequest:request delegate:self]];
                //同步方式
                if (nil==tmpOnComplete) {
                    do{
                        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
                    }while(!isFinish);
                }
            }
        }
    }
}
-(NSURLConnection*)connection{
    return tmpConnection;
}
-(NSData*)data{
    return tmpData;
}
-(NSURL*)URL{
    return tmpURL;
}
//代理
-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    if ([self connection]==connection) {
        if (hasCache) {
            NSString *filePath=[Utils pathForDocument:MD5(connection.currentRequest.URL.absoluteString)];
            [self setTmpData:[NSMutableData dataWithContentsOfFile:filePath]];
        }else{
            [self setTmpData:nil];
        }
        isFinish=YES;
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse{
    if ([self connection]==connection) {
        [self setTmpData:[NSMutableData data]];
        isFinish=NO;
    }
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    if ([self connection]==connection) {
        [tmpData appendData:data];
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    if ([self connection]==connection) {
        if (NSLoaderCachePolicyNULL != tmpPriority) {
            NSString *filePath=[Utils pathForDocument:MD5(connection.currentRequest.URL.absoluteString)];
            [tmpData writeToFile:filePath atomically:YES];
        }
        if (tmpOnComplete) {
            tmpOnComplete(self);
        }
        isFinish=YES;
    }
}
@end

//***************************************************************************************************
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
//跳转
+(id)gotoWithName:(NSString*)name animated:(UITransitionStyle)animated{
    NSArray *viewControllers = [[Utils rootViewController] viewControllers];
    for (UIViewController *viewController in viewControllers) {
        if ([name isEqualToString:NSStringFromClass(viewController.class)]) {
            return [Utils popViewController:viewController animated:animated];
        }
    }
    Class class = NSClassFromString(name);
    if (class) {
        UIViewController *viewController = [[[class alloc] initWithNibName:nil bundle:nil] autorelease];
        return [Utils pushViewController:viewController animated:animated];
    }
    return nil;
}
+(id)back{
    NSArray *viewControllers = [[Utils rootViewController] viewControllers];
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
        UIViewController *parentController = [[Utils rootViewController] visibleViewController];
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
    UIViewController *parentController = [[Utils rootViewController] visibleViewController];
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
+(UINavigationController*)rootViewController{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    if (keyWindow) {
        if (nil==[keyWindow rootViewController]) {
            UINavigationController *rootViewController=[[UINavigationController alloc] init];
            [keyWindow setRootViewController:rootViewController];
            [rootViewController setNavigationBarHidden:YES];
            [rootViewController release];
            NSLog(@"%@",NSDocuments());
        }
        return (UINavigationController*)[keyWindow rootViewController];
    }else{
        @throw [NSException exceptionWithName:NSObjectNotAvailableException reason:@"applications must have a key window!" userInfo:nil];
    }
    return nil;
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
    [[Utils rootViewController] pushViewController:viewController animated:NO];
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
    [[Utils rootViewController] popToViewController:viewController animated:NO];
    return viewController;
}
+(void)transitionFrom:(NSString*)transition{
    UIViewController *rootController = [Utils rootViewController];
    if (rootController) {
        NSArray *orientation = [NSArray arrayWithObjects:kCATransitionFromTop,kCATransitionFromRight,kCATransitionFromBottom,kCATransitionFromLeft, nil];
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        NSUInteger index = [orientation indexOfObject:transition];
        if (index==NSNotFound) {
            CATransition *animation = [CATransition animation];
            [animation setType:transition];
            [keyWindow.layer addAnimation:animation forKey:@"keyWindow::CATransition"];
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
            [keyWindow.layer addAnimation:animation forKey:@"keyWindow::CATransition"];
        }
    }
}
@end