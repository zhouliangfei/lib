//
//  TMCategory.m
//  cutter
//
//  Created by mac on 16/3/12.
//  Copyright © 2016年 e360. All rights reserved.
//

#import "TMCategory.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#pragma mark-
#pragma mark NSObject
@implementation NSObject(Utils_Category);
-(id)duplicate{
    NSData *archive = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [NSKeyedUnarchiver unarchiveObjectWithData:archive];
}
@end


#pragma mark-
#pragma mark NSNull
@implementation NSNull (Utils_Category)
-(long long)longLongValue{
    return 0;
}
-(NSInteger)integerValue{
    return 0;
}
-(double)doubleValue{
    return 0;
}
-(float)floatValue{
    return 0;
}
-(BOOL)boolValue{
    return NO;
}
-(int)intValue{
    return 0;
}
@end


#pragma mark-
#pragma mark NSDateFormatter
@implementation NSDateFormatter(Utils_Category)
+(NSDateFormatter*)shareInstance{
    static NSDateFormatter *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NSDateFormatter alloc] init];
        [instance setDateStyle:NSDateFormatterFullStyle];
        //[instance setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    });
    return instance;
}
@end


#pragma mark-
#pragma mark NSDate
@implementation NSDate (Utils_Category)
@dynamic components;
-(NSDateComponents*)components{
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitNanosecond | NSCalendarUnitWeekday;
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
}
-(id)stringFromFormatter:(NSString*)format{
    if (format && [format isKindOfClass:[NSString class]]) {
        [[NSDateFormatter shareInstance] setDateFormat:format];
        return [[NSDateFormatter shareInstance] stringFromDate:self];
    }
    return nil;
}
@end


#pragma mark-
#pragma mark NSString
@implementation NSString (Utils_Category)
+(id)temporaryAppend:(NSString *)path{
    if ([path isKindOfClass:NSString.class]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(id)resourceAppend:(NSString *)path{
    if ([path isKindOfClass:NSString.class]) {
        return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(id)documentAppend:(NSString *)path{
    if ([path isKindOfClass:NSString.class]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(id)libraryAppend:(NSString *)path{
    if ([path isKindOfClass:NSString.class]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:path];
    }
    return nil;
}
+(id)uuid{
    CFUUIDRef cs = CFUUIDCreate(kCFAllocatorDefault);
    NSString *ns = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, cs);
    CFRelease(cs);
    return ns;
}
//
-(id)dateFromFormatter:(NSString*)format{
    if (format && [format isKindOfClass:[NSString class]]) {
        [[NSDateFormatter shareInstance] setDateFormat:format];
        return [[NSDateFormatter shareInstance] dateFromString:self];
    }
    return nil;
}
//base64解码
-(id)base64Encoded{
    NSData *nd = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [nd base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
}
//base64解码
-(id)base64Decoded{
    NSData *nd = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc] initWithData:nd encoding:NSUTF8StringEncoding];
}
//md5加密
-(id)md5{
    const char *cc = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cc, (CC_LONG)strlen(cc), result);
    
    NSMutableString *ms = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(uint i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
        [ms appendFormat:@"%02x",result[i]];
    }
    return [ms lowercaseString];
}
@end

#pragma mark-
#pragma mark UIDevice
NSString *const UIDeviceNetWorkDidChangeNotification = @"UIDeviceNetWorkDidChangeNotification";
@implementation UIDevice(Utils_Category)
@dynamic network;
static UIDeviceNetwork network;
static SCNetworkReachabilityRef reachability = NULL;
static void detectNetworkCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void *info){
    UIDevice *device = (__bridge UIDevice*)info;
    [device netWorkDidChange:flags];
}
+ (void)initialize{
    [[UIDevice currentDevice] initReachability];
}
-(void)initReachability{
    if (self == [UIDevice currentDevice]) {
        static dispatch_once_t onceToken = 0;
        dispatch_once(&onceToken, ^{
            reachability = SCNetworkReachabilityCreateWithName(NULL, "0.0.0.0");
            if(reachability) {
                SCNetworkReachabilityContext context = {0, (__bridge  void *)self, NULL, NULL, NULL};
                SCNetworkReachabilitySetCallback(reachability, detectNetworkCallback, &context);
                SCNetworkReachabilityScheduleWithRunLoop(reachability, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
                //抓取状态
                network=UIDeviceNetworkNone;
                SCNetworkReachabilityFlags flags = 0;
                BOOL retrieveFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
                if(retrieveFlags){
                    [self netWorkDidChange:flags];
                }
            }
        });
    }
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
    if (temp != network) {
        network = temp;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIDeviceNetWorkDidChangeNotification object:self];
    }
}
@end


#pragma mark-
#pragma mark UIColor
@implementation UIColor(Utils_Category)
@dynamic hex;
+(UIColor*)colorWithHex:(NSInteger)hex alpha:(CGFloat)alpha{
    CGFloat bc = (hex & 0xFF);
    CGFloat gc = (hex & 0xFF00) >> 8;
    CGFloat rc = (hex & 0xFF0000) >> 16;
    return [UIColor colorWithRed:rc / 255 green:gc / 255 blue:bc / 255 alpha:alpha];
}
+(UIColor*)colorWithHex:(NSInteger)hex{
    return [UIColor colorWithHex:hex alpha:1.0];
}
-(NSInteger)hex{
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    uint rc = (uint)(0xFF * c[0]) << 16;
    uint gc = (uint)(0xFF * c[1]) << 8;
    uint bc = (uint)(0xFF * c[2]);
    return rc + gc + bc;
}
@end


#pragma mark-
#pragma mark UIView
@implementation UIView(Utils_Category)
@dynamic corner,borderColor,borderWidth;
-(void)setCorner:(CGFloat)corner{
    [self.layer setCornerRadius:corner];
}
-(CGFloat)corner{
    return [self.layer cornerRadius];
}
-(void)setBorderWidth:(CGFloat)borderWidth{
    [self.layer setBorderWidth:borderWidth];
}
-(CGFloat)borderWidth{
    return [self.layer borderWidth];
}
-(void)setBorderColor:(UIColor *)borderColor{
    [self.layer setBorderColor:borderColor.CGColor];
}
-(UIColor *)borderColor{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}
-(void)setCorner:(UIRectCorner)corners radii:(CGFloat)radii{
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(radii, radii)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    [layer setFrame:self.bounds];
    [layer setPath:path.CGPath];
    [self.layer setMask:layer];
}
-(UIImage*)snapshot{
    /*UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
     [self.layer renderInContext:UIGraphicsGetCurrentContext()];
     UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
     [self.layer setContents:nil];
     UIGraphicsEndImageContext();
     return image;*/
    //
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end


#pragma mark-
#pragma mark UIImage
@implementation UIImage(Utils_Category)
-(UIImage*)insert:(CGSize)size{
    CGFloat scale = MIN(size.width / self.size.width, size.height / self.size.height);
    if (scale > 1.0) {
        size = CGSizeMake(self.size.width * scale, self.size.height * scale);
        //
        UIGraphicsBeginImageContext(size);
        [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
    return self;
}
@end


#pragma mark-
#pragma mark UIImageView
@implementation UIImageView (TMLoader)
static const void *ImageViewIndicator = "imageView.indicator";
static const void *ImageViewTask = "imageView.task";
static const void *ImageViewSrc = "imageView.src";
@dynamic src;
-(void)setSrc:(NSString *)src{
    //@synchronized(self) {
        if (self.image==nil || [src isEqualToString:self.src] == NO) {
            objc_setAssociatedObject(self, ImageViewSrc, src, OBJC_ASSOCIATION_COPY_NONATOMIC);
            //
            NSString *name = [self hashPath:src];
            NSString *path = [NSString libraryAppend:name];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                [self setImage:image];
            }else{
                NSURL *url = [NSURL URLWithString:src];
                if (url) {
                    [[self task] cancel];
                    NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                        if (nil == error) {
                            [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
                        }
                        UIImage *image = [UIImage imageWithContentsOfFile:path];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[self indicator] removeFromSuperview];
                            [[self indicator] stopAnimating];
                            [self setImage:image];
                        });
                    }];
                    [[self indicator] setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
                    [self addSubview:[self indicator]];
                    [[self indicator] startAnimating];
                    [self setTask:task];
                    [self setImage:nil];
                    [task resume];
                }
            }
        }
    //}
}
-(NSString *)src{
    return objc_getAssociatedObject(self, ImageViewSrc);
}
//
-(void)setTask:(NSURLSessionDownloadTask*)task{
    objc_setAssociatedObject(self, ImageViewTask, task, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NSURLSessionDownloadTask*)task{
    return objc_getAssociatedObject(self, ImageViewTask);
}
//
-(UIActivityIndicatorView*)indicator{
    UIActivityIndicatorView *temp = objc_getAssociatedObject(self, ImageViewIndicator);
    if (temp == nil) {
        temp = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        objc_setAssociatedObject(self, ImageViewIndicator, temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return temp;
}
-(NSString*)hashPath:(NSString*)val{
    if (val) {
        NSString *src = [val md5];
        NSString *ext = [val pathExtension];
        if (ext && [ext length] > 0) {
            return [src stringByAppendingPathExtension:ext];
        }
        return src;
    }
    return @"";
}
@end