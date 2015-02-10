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

CGFloat CGPointAngle(CGPoint a,CGPoint b){
    CGFloat deltaX = a.x - b.x;
    CGFloat deltaY = a.y - b.y;
    return atan2(deltaY,deltaX);
}
CGFloat CGPointDistance(CGPoint a,CGPoint b){
    CGFloat deltaX = a.x - b.x;
    CGFloat deltaY = a.y - b.y;
    return sqrt(deltaX * deltaX + deltaY * deltaY);
}
CGFloat CGPointCross(CGPoint a,CGPoint b,CGPoint c){
    return (b.x-a.x)*(c.y-a.y)-(c.x-a.x)*(b.y-a.y);
}
BOOL CGPointIntersect(CGPoint a,CGPoint b,CGPoint c,CGPoint d, CGPoint *o){
    //不相交>0，共线=0
    if(CGPointCross(a,b,c)*CGPointCross(a,b,d)>=0||CGPointCross(c,d,a)*CGPointCross(c,d,b)>=0){
        return NO;
    }
    if (NULL != o){
        float x1 = a.x-b.x;
        float y1 = a.y-b.y;
        float x2 = c.x-d.x;
        float y2 = c.y-d.y;
        
        if(y1==0 && x2==0){
            o->x = c.x;
            o->y = a.y;
        }else if(x1==0 && y2==0){
            o->x = a.x;
            o->y = c.y;
        }else{
            if(x1==0){
                float k = y2/x2;
                float b = c.y-c.x*k;
                o->x = a.x;
                o->y = k*o->x+b;
            }else if(x2==0){
                float k = y1/x1;
                float b = a.y-a.x*k;
                o->x = c.x;
                o->y = k*o->x+b;
            }else{
                float k1 = y1/x1;
                float k2 = y2/x2;
                float b1 = a.y-a.x*k1;
                float b2 = c.y-c.x*k2;
                o->x = (b2-b1)/(k1-k2);
                o->y = k1*o->x+b1;
            }
        }
    }
    return YES;
}

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
    if ([NSJSONSerialization isValidJSONObject:object]) {
        return object;
    }
    if ([object isKindOfClass:[NSString class]]){
        NSData *data = [object dataUsingEncoding: NSUTF8StringEncoding];
        if (data) {
            NSError *error = nil;
            id temp=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (nil==error && [NSJSONSerialization isValidJSONObject:temp]){
                return temp;
            }
        }
    }
    return nil;
}
+(NSString*)stringify:(id)object{
    if ([object isKindOfClass:[NSString class]]){
        return object;
    }
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
@implementation NSString (Utils_Category)
static const char encodingTable[]="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
-(id)dateFromFormatter:(NSString*)format{
    if (format && [format isKindOfClass:[NSString class]]) {
        NSDateFormatter *formatter=[NSDateFormatter shareInstance];
        [formatter setDateFormat:format];
        return [formatter dateFromString:self];
    }
    return nil;
}
-(NSString *)base64Encoded{
    if ([self length]==0){
        return nil;
    }
    //
    NSData *data=[self dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    char *characters=malloc((([data length]+2)/3)*4);
    if (characters==NULL){
        return nil;
    }
    NSUInteger i=0;
    NSUInteger length=0;
    while (i<[data length]){
        char buffer[3]={0,0,0};
        short bufferLength = 0;
        while (bufferLength<3 && i<[data length]){
            buffer[bufferLength++]=((char *)[data bytes])[i++];
        }
        characters[length++]=encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++]=encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength>1){
            characters[length++]=encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        }else {
            characters[length++]='=';
        }
        if (bufferLength > 2){
            characters[length++]=encodingTable[buffer[2] & 0x3F];
        }else {
            characters[length++]='=';
        }
    }
    return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}
-(NSString *)base64Decoded{
    static char *decodingTable=NULL;
    if (decodingTable==NULL){
        decodingTable=malloc(256);
        if (decodingTable==NULL){
            return nil;
        }
        memset(decodingTable, CHAR_MAX, 256);
        for (uint i=0; i<64; i++){
            decodingTable[(short)encodingTable[i]] = i;
        }
    }
    //
    if ([self length]==0){
        return nil;
    }
    const char *characters=[self cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters==NULL){
        return nil;
    }
    char *bytes=malloc((([self length]+3)/4)*3);
    if (bytes==NULL){
        return nil;
    }
    //
    NSUInteger i=0;
    NSUInteger length=0;
    while (YES){
        char buffer[4];
        short bufferLength;
        for (bufferLength=0; bufferLength<4; i++){
            if (characters[i]=='\0'){
                break;
            }
            if (isspace(characters[i])||characters[i]=='='){
                continue;
            }
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX){
                free(bytes);
                return nil;
            }
        }
        if (bufferLength==0){
            break;
        }
        if (bufferLength==1){
            free(bytes);
            return nil;
        }
        bytes[length++]=(buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength>2){
            bytes[length++]=(buffer[1] << 4) | (buffer[2] >> 2);
        }
        if (bufferLength>3){
            bytes[length++]=(buffer[2] << 6) | buffer[3];
        }
    }
    realloc(bytes, length);
    //
    return [[[NSString alloc] initWithBytesNoCopy:bytes length:length encoding:NSASCIIStringEncoding freeWhenDone:YES] autorelease];
}
@end

//NSDateFormatter*********************************
@implementation NSDateFormatter(Utils_Category)
+(NSDateFormatter*)shareInstance{
    static NSDateFormatter *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
        [instance setDateStyle:NSDateFormatterFullStyle];
        [instance setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"] autorelease]];
    });
    return instance;
}
@end

//NSDate****************************************
@implementation NSDate (Utils_Category)
-(id)stringFromFormatter:(NSString*)format{
    if (format && [format isKindOfClass:[NSString class]]) {
        NSDateFormatter *formatter=[NSDateFormatter shareInstance];
        [formatter setDateFormat:format];
        return [formatter stringFromDate:self];
    }
    return nil;
}
@end

//UIColor****************************************
NSNumber* NSNumberFromColor(UIColor* color){
    if (color && [color isKindOfClass:[UIColor class]]) {
        const CGFloat *c=CGColorGetComponents(color.CGColor);
        uint rc=(int)(0xFF*c[0])<<16;
        uint gc=(int)(0xFF*c[1])<<8;
        uint bc=(int)(0xFF*c[2]);
        return [NSNumber numberWithInteger:rc+gc+bc];
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
-(void)setCheck:(NSString *)check{
    if (self==[UIDevice currentDevice]) {
        objc_setAssociatedObject(self, OBJC_UIDEVICE_CHECK, check, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        //
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            reachability=SCNetworkReachabilityCreateWithName(NULL, "0.0.0.0");
            if(reachability) {
                SCNetworkReachabilityContext context={0, ( void *)self, NULL, NULL, NULL};
                SCNetworkReachabilitySetCallback(reachability, detectNetworkCallback, &context);
                SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                //抓取状态
                network=UIDeviceNetworkNone;
                SCNetworkReachabilityFlags flags=0;
                BOOL retrieveFlags=SCNetworkReachabilityGetFlags(reachability, &flags);
                if(retrieveFlags){
                    [self netWorkDidChange:flags];
                }
            }
        });
    }
}
-(NSString *)check{
    if (self==[UIDevice currentDevice]) {
        return objc_getAssociatedObject(self, OBJC_UIDEVICE_CHECK);
    }
    return nil;
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
    if((flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired)){
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
    if (UIDeviceNetworkNone!=temp) {
        SCNetworkReachabilityRef chechReachability=SCNetworkReachabilityCreateWithName(NULL, [self.check UTF8String]);
        if(chechReachability) {
            BOOL retrieveFlags=SCNetworkReachabilityGetFlags(chechReachability, &flags);
            if(retrieveFlags){
                if(NO==(flags & kSCNetworkFlagsReachable) || (flags & kSCNetworkFlagsConnectionRequired)){
                    temp=UIDeviceNetworkNone;
                }
            }
            CFRelease(chechReachability);
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
+(id)imageWithSource:(NSString*)path{
    return [UIImage imageWithContentsOfFile:[Utils pathForResource:path]];
}
+(id)imageWithLibrary:(NSString*)path{
    return [UIImage imageWithContentsOfFile:[Utils pathForLibrary:path]];
}
-(UIImage*)imageWithTintColor:(UIColor*)tintColor{
    if (tintColor) {
        CGRect bounds = (CGRect){.origin=CGPointZero,.size=self.size};
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, NO, self.scale);
        CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), tintColor.CGColor);
        UIRectFill(bounds);
        //kCGBlendModeOverlay保留灰度信息
        [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
        //kCGBlendModeDestinationIn保留透明度信息
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        
        UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return tintedImage;
    }
    return self;
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
    [self.layer setContents:nil];
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
    [self.loader close];
    [self setImage:nil];
    [self __dealloc__];
}
//从网络加载
-(NSURLLoader*)loader{
    return objc_getAssociatedObject(self, OBJC_UIIMAGEVIEW_URL);
}
-(void)setLoader:(NSURLLoader*)loader{
    objc_setAssociatedObject(self, OBJC_UIIMAGEVIEW_URL, loader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
//
-(void)setURL:(NSString*)urlString{
    [self setURL:urlString onComplete:nil];
}
-(NSString*)URL{
    return [[[[[self loader] connection] currentRequest] URL] absoluteString];
}
-(void)setURL:(NSString*)urlString onComplete:(void (^)(id target))onComplete{
    [[self loader] close];
    //
    __block UIImageView *blockSelf=self;
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLLoader *loader=[NSURLLoader load:request priority:NSURLLoaderCachePolicyLocalData open:nil progress:nil complete:^(NSURLLoader *target, NSError *error) {
        if (nil==error) {
            [blockSelf performSelectorOnMainThread:@selector(setImage:) withObject:[UIImage imageWithData:target.data] waitUntilDone:YES];
        }
        if (onComplete) {
            onComplete(blockSelf);
        }
    }];
    [self setLoader:loader];
}
//
+(id)viewWithSource:(NSString*)source{
    UIImage *image=[UIImage imageWithSource:source];
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
    [temp setImage:[UIImage imageWithSource:source]];
    return temp;
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent library:(NSString*)library{
    UIImageView *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setImage:[UIImage imageWithLibrary:library]];
    return temp;
}
@end

//UILabel****************************************
@implementation UILabel(Utils_Category)
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UILabel *temp=[[self.class alloc] initWithFrame:frame];
    [temp setBackgroundColor:[UIColor clearColor]];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
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
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UITextField *temp=[[self.class alloc] initWithFrame:frame];
    [temp setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [temp setAutocorrectionType:UITextAutocorrectionTypeNo];
    [temp setSpellCheckingType:UITextSpellCheckingTypeNo];
    [temp setBackgroundColor:[UIColor clearColor]];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
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
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UITextView *temp=[[self.class alloc] initWithFrame:frame];
    [temp setBackgroundColor:[UIColor clearColor]];
    if (parent) {
        [parent addSubview:temp];
    }
    return [temp autorelease];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text{
    return [self viewWithFrame:frame parent:parent text:text font:nil color:nil align:NSTextAlignmentLeft];
}
+(id)viewWithFrame:(CGRect)frame parent:(UIView*)parent text:(NSString*)text font:(UIFont*)font color:(UIColor*)color align:(NSTextAlignment)align{
    UITextView *temp=[self.class viewWithFrame:frame parent:parent];
    [temp setTextAlignment:align];
    [temp setEditable:NO];
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
        [temp setImage:[UIImage imageWithSource:active] forState:UIControlStateHighlighted];
        [temp setImage:[UIImage imageWithSource:active] forState:UIControlStateSelected];
    }
    if (normal) {
        [temp setImage:[UIImage imageWithSource:normal] forState:UIControlStateNormal];
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
+(id)viewWithFrame:(CGRect)frame parent:(UIView *)parent{
    UITableView *temp=[[self.class alloc] initWithFrame:frame];
    if ([temp respondsToSelector:@selector(setSeparatorInset:)]) {
        [temp setSeparatorInset:UIEdgeInsetsZero];
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
        [(id)layout setMinimumInteritemSpacing:0];
        [(id)layout setMinimumLineSpacing:0];
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
        [instance setHidesWhenStopped:YES];
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
    if (referenceCount>0 && nil==self.superview) {
        UIView *root=[Utils keyWindow];
        if (root) {
            [self setCenter:root.center];
            [root addSubview:self];
            [self startAnimating];
            [self setHidden:NO];
        }
    }
}
-(void)hidden{
    referenceCount--;
    if (referenceCount<1 && self.superview) {
        [self performSelector:@selector(removeAndHidden) withObject:nil afterDelay:0.4];
    }
}
-(void)removeAndHidden{
    [self removeFromSuperview];
    [self setHidden:YES];
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    return !self.hidden;
}
@end

//UIAlertView****************************************
@implementation UIAlertView(Utils_Category)
+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message onClick:(void (^)(UIAlertView *alertView, NSInteger index))onClick cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil];
    //
    if (otherButtonTitles) {
        id arg;
        va_list argList;
        va_start(argList,otherButtonTitles);
        while ((arg=va_arg(argList,id))){
            [alertView addButtonWithTitle:arg];
        }
        va_end(argList);
    }
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

//
@implementation NSURLRequest (Utils_Category)
+(NSURLRequest*)requestWithURL:(NSURL*)URL post:(id)post{
    if (URL) {
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:URL];
        if (post) {
            //post数据
            if ([post isKindOfClass:[NSDictionary class]]) {
                NSString *boundary = @"64F4845541AEA084";
                NSMutableData *body = [NSMutableData data];
                for(NSString *key in [post allKeys]){
                    id value = [post objectForKey:key];
                    if (value) {
                        if([value isKindOfClass:[NSData class]]){
                            //单文件
                            NSString *temp=[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%d\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, 0];
                            [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                            [body appendData:[NSData dataWithData:value]];
                        }else if([value isKindOfClass:[NSArray class]]){
                            //多文件
                            int index=0;
                            for(id item in value){
                                if ([item isKindOfClass:[NSData class]]) {
                                    NSString *temp=[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%d\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, index++];
                                    [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                                    [body appendData:[NSData dataWithData:value]];
                                }
                            }
                        }else{
                            NSString *temp=[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@", boundary, key, value];
                            [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                        }
                    }
                }
                NSString *temp = [NSString stringWithFormat:@"\r\n--%@--",boundary];
                [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                //
                [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
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
                [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded;"] forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[post length]] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:post];
            }
            [request setHTTPMethod:@"POST"];
        }
        return request;
    }
    return nil;
}
@end
//
@implementation NSURLLoader
@synthesize connection,onOpen,onProgress,onComplete,bytesLoaded,bytesTotal;
@synthesize identifier;
@dynamic request,data;
+(NSOperationQueue*)queue{
    static NSOperationQueue *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[NSOperationQueue alloc] init];
        [instance setMaxConcurrentOperationCount:1];
    });
    return instance;
}
//
+(NSURLLoader*)load:(NSURLRequest*)urlRequest priority:(NSURLLoaderCachePolicy)priority open:(void (^)(NSURLLoader *target))open progress:(void (^)(NSURLLoader *target))progress complete:(void (^)(NSURLLoader *target,NSError *error))complete{
    if (urlRequest) {
        NSURLLoader *loader=[[NSURLLoader alloc] initWithPriority:priority];
        [loader setOnComplete:complete];
        [loader setOnProgress:progress];
        [loader setRequest:urlRequest];
        [loader setOnOpen:open];
        //
        [[NSURLLoader queue] addOperation:loader];
        [loader release];
        return loader;
    }
    return nil;
}
-(NSURLLoader*)initWithPriority:(NSURLLoaderCachePolicy)urlPriority{
    self=[super init];
    if (self) {
        priority=urlPriority;
    }
    return self;
}
-(void)dealloc{
    [self close];
    [onComplete release];
    [onProgress release];
    [identifier release];
    [fileName release];
    [bitData release];
    [onOpen release];
    [super dealloc];
}
//
-(void)close{
    finished=YES;
    //
    if (connection) {
        [connection cancel];
        [connection release];
    }
    connection=nil;
    //
    if (writeStream) {
        [writeStream close];
        [writeStream release];
    }
    writeStream=nil;
    //
    if (fileName) {
        [fileName release];
    }
    fileName=nil;
    //
    if (bitData) {
        [bitData release];
    }
    bitData=nil;
}
//
-(void)setRequest:(NSURLRequest *)request{
    [self close];
    if (request) {
        finished=NO;
        bytesTotal=0;
        bytesLoaded=0;
        fileName=[[Utils hashPath:request.URL.absoluteString] copy];
        connection=[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        //取缓存文件大小
        NSString *cachePath=[Utils pathForCaches:fileName];
        if ([request respondsToSelector:@selector(addValue:forHTTPHeaderField:)] && [[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
            bytesLoaded=[[[NSFileManager defaultManager] attributesOfItemAtPath:cachePath error:nil] fileSize];
            [(id)request addValue:[NSString stringWithFormat:@"bytes=%llu-", bytesLoaded] forHTTPHeaderField:@"Range"];
            //
            writeStream=[[NSOutputStream alloc] initToFileAtPath:cachePath append:YES];
        }else{
            writeStream=[[NSOutputStream alloc] initToFileAtPath:cachePath append:NO];
        }
    }
}
-(NSURLRequest *)request{
    if (connection) {
        return connection.currentRequest;
    }
    return nil;
}
//
-(void)main{
    if (NO==self.isCancelled) {
        NSString *filePath=[Utils pathForLibrary:fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            if (NSURLLoaderCachePolicyLocalData==priority) {
                bytesTotal=bytesLoaded=[[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
                //完成
                if (onComplete) {
                    onComplete(self,nil);
                }
                finished=YES;
                return;
            }
        }
        //加载文件
        [connection start];
        [writeStream open];
        //等待结束
        do{
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }while(NO==finished && NO==self.isCancelled);
    }
}
-(void)load:(NSURLRequest*)urlRequest{
    [self setRequest:urlRequest];
    [self main];
}
//
-(NSData*)data{
    if (finished) {
        if (bitData) {
            return bitData;
        }
        if (fileName) {
            NSString *filePath=[Utils pathForLibrary:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                return [NSData dataWithContentsOfFile:filePath];
            }
        }
    }
    return nil;
}
//
-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse{
    return nil;
}
-(void)connection:(NSURLConnection *)urlConnection didFailWithError:(NSError *)error{
    if (NO==self.isCancelled && urlConnection==self.connection) {
        finished=YES;
        if (NO==self.isCancelled && onComplete) {
            onComplete(self,error);
        }
    }
}
-(void)connection:(NSURLConnection *)urlConnection didReceiveResponse:(NSURLResponse *)response{
    if (NO==self.isCancelled && urlConnection==self.connection) {
        if (response && [response respondsToSelector:@selector(statusCode)]) {
            NSInteger statusCode=[(id)response statusCode];
            if (statusCode==200) {
                if([response respondsToSelector:@selector(allHeaderFields)]){
                    bytesTotal=bytesLoaded+[[[(id)response allHeaderFields] objectForKey:@"Content-Length"] longLongValue];
                }
                if (onOpen) {
                    onOpen(self);
                }
            }else{
                finished=YES;
                if (onComplete) {
                    NSMutableDictionary *userInfo=[NSMutableDictionary dictionary];
                    [userInfo setObject:urlConnection.currentRequest.URL forKey:NSURLErrorFailingURLErrorKey];
                    [userInfo setObject:urlConnection.currentRequest.URL.absoluteString forKey:NSURLErrorFailingURLStringErrorKey];
                    [userInfo setObject:[(id)response localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
                    onComplete(self,[NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:userInfo]);
                }
            }
        }
    }
}
-(void)connection:(NSURLConnection *)urlConnection didReceiveData:(NSData *)data{
    if (NO==self.isCancelled && urlConnection==self.connection) {
        const uint8_t *dataBytes=[data bytes];
        NSInteger dataLength=[data length];
        NSInteger bytesWrittenSoFar=0;
        NSInteger bytesWritten=0;
        do {
            bytesWritten=[writeStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength-bytesWrittenSoFar];
            assert(bytesWritten!=0);
            if (bytesWritten==-1) {
                break;
            } else {
                bytesWrittenSoFar+=bytesWritten;
            }
        }while(bytesWrittenSoFar!=dataLength);
        //进度
        bytesLoaded+=bytesWrittenSoFar;
        if (onProgress) {
            onProgress(self);
        }
    }
}
-(void)connectionDidFinishLoading:(NSURLConnection *)urlConnection{
    if (NO==self.isCancelled && urlConnection==self.connection) {
        NSString *cachePath=[Utils pathForCaches:fileName];
        if (NSURLLoaderCachePolicyNULL!=priority) {
            NSString *filePath=[Utils pathForLibrary:fileName];
            if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                [[NSFileManager defaultManager] moveItemAtPath:cachePath toPath:filePath error:nil];
            }
        }else{
            if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
                bitData=[[NSData alloc] initWithContentsOfFile:cachePath];
                [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
            }
        }
        //完成
        finished=YES;
        if (onComplete) {
            onComplete(self,nil);
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
+(NSString*)pathForResource:(NSString*)path{
    if ([path isKindOfClass:[NSString class]]) {
        return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(NSString*)pathForTemporary:(NSString*)path{
    //Temporary目录存贮的内容不会同步到icloud和itunes上，在空间不足时会清空此目录
    if ([path isKindOfClass:[NSString class]]) {
        return [NSTemporaryDirectory() stringByAppendingPathComponent:path];
    }
    return nil;
}
+(NSString*)pathForDocument:(NSString*)path{
    //Documents目录存贮的内容会默认同步到icloud和itunes上，在空间不足时不会清空此目录
    if ([path isKindOfClass:[NSString class]]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(NSString*)pathForLibrary:(NSString*)path{
    //Library目录存贮的内容不会默认同步到icloud和itunes上，在空间不足时不会清空此目录
    if ([path isKindOfClass:[NSString class]]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(NSString*)pathForCaches:(NSString*)path{
    //Library/Caches目录存贮的内容不会默认同步到icloud和itunes上，在空间不足时会清空此目录
    if ([path isKindOfClass:[NSString class]]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(NSString*)hashPath:(NSString*)path{
    if ([path isKindOfClass:[NSString class]]) {
        NSString *extension=[path pathExtension];
        if ([extension isEqualToString:@""]) {
            return MD5(path);
        }
        return [MD5(path) stringByAppendingPathExtension:extension];
    }
    return nil;
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
        NSLog(@"%@",NSHomeDirectory());
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
            switch ([[UIApplication sharedApplication] statusBarOrientation]){
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
