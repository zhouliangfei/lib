//
//  TMCategory.m
//  cutter
//
//  Created by mac on 16/3/12.
//  Copyright © 2016年 e360. All rights reserved.
//

#import "TMCategory.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#pragma mark-
#pragma mark NSObject
@implementation NSObject(Utils_Category);
static const void *objectPrototype = "object.prototype";
@dynamic prototype;
-(NSMutableDictionary *)prototype{
    NSMutableDictionary *dictionary = objc_getAssociatedObject(self, objectPrototype);
    if (dictionary == nil) {
        dictionary = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, objectPrototype, dictionary, OBJC_ASSOCIATION_RETAIN);
    }
    return dictionary;
}
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
-(id)toString:(NSString*)format{
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
//路径混淆
-(id)pathHash{
    if (self.length > 0) {
        NSString *src = [self md5];
        NSString *ext = [self pathExtension];
        if (ext && [ext length] > 0) {
            return [src stringByAppendingPathExtension:ext];
        }
        return src;
    }
    return nil;
}
-(id)toDate:(NSString*)format{
    if (self.length > 0) {
        if (format && [format isKindOfClass:[NSString class]]) {
            [[NSDateFormatter shareInstance] setDateFormat:format];
            return [[NSDateFormatter shareInstance] dateFromString:self];
        }
    }
    return nil;
}
//AES256加密
-(id)aes256EncodedWithKey:(NSString *)key{
    if (self.length > 0) {
        char keyPtr[kCCKeySizeAES256 + 1];
        bzero(keyPtr, sizeof(keyPtr));
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        //
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSUInteger dataLength = [data length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesEncrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding | kCCOptionECBMode,
                                              keyPtr, kCCBlockSizeAES128,
                                              NULL,
                                              [data bytes], dataLength,
                                              buffer, bufferSize,
                                              &numBytesEncrypted);
        if (cryptStatus == kCCSuccess) {
            NSData *temp = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
            return [[NSString alloc] initWithData:temp encoding:NSUTF8StringEncoding];
        }
        free(buffer);
    }
    return nil;
}
//AES256解码
-(id)aes256DecodedWithKey:(NSString *)key{
    if (self.length > 0) {
        char keyPtr[kCCKeySizeAES256 + 1];
        bzero(keyPtr, sizeof(keyPtr));
        [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
        //
        NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSUInteger dataLength = [data length];
        size_t bufferSize = dataLength + kCCBlockSizeAES128;
        void *buffer = malloc(bufferSize);
        size_t numBytesDecrypted = 0;
        CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                              kCCOptionPKCS7Padding | kCCOptionECBMode,
                                              keyPtr, kCCBlockSizeAES128,
                                              NULL,
                                              [data bytes], dataLength,
                                              buffer, bufferSize,
                                              &numBytesDecrypted);
        if (cryptStatus == kCCSuccess) {
            NSData *temp = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
            return [[NSString alloc] initWithData:temp encoding:NSUTF8StringEncoding];
        }
        free(buffer);
    }
    return nil;
}
//base64解码
-(id)base64Encoded{
    if (self.length > 0) {
        NSData *nd = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        return [nd base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    }
    return nil;
}
//base64解码
-(id)base64Decoded{
    if (self.length > 0) {
        NSData *nd = [[NSData alloc] initWithBase64EncodedString:self options:NSDataBase64DecodingIgnoreUnknownCharacters];
        return [[NSString alloc] initWithData:nd encoding:NSUTF8StringEncoding];
    }
    return nil;
}
//md5加密
-(id)md5{
    if (self.length > 0) {
        const char *cc = [self UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cc, (CC_LONG)strlen(cc), result);
        
        NSMutableString *ms = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for(uint i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
            [ms appendFormat:@"%02x",result[i]];
        }
        return [ms lowercaseString];
    }
    return nil;
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
-(UIImage*)blendWithColor:(UIColor*)color{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, self.scale);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    //
    UIRectFill(rect);
    [self drawInRect:rect blendMode:kCGBlendModeOverlay alpha:1.0f];
    [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
-(UIImage*)resize:(CGSize)size{
    CGFloat scale = MIN(size.width / self.size.width, size.height / self.size.height);
    if (scale != 1.0) {
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
@implementation UIImageView (Utils_Category)
static NSString *imageViewIndicator = @"imageView.indicator";
static NSString *imageViewSource = @"imageView.source";
static NSString *imageViewBlend = @"imageView.blend";
static NSString *imageViewSrc = @"imageView.src";
@dynamic blend, src;
+(void)load{
    Method swizzledLayoutSubviews = class_getInstanceMethod(self, @selector(layoutSubviewsSwizzled));
    Method originalLayoutSubviews = class_getInstanceMethod(self, @selector(layoutSubviews));
    method_exchangeImplementations(originalLayoutSubviews, swizzledLayoutSubviews);
    //
    Method swizzledSetImage = class_getInstanceMethod(self, @selector(setImageSwizzled:));
    Method originalSetImage = class_getInstanceMethod(self, @selector(setImage:));
    method_exchangeImplementations(originalSetImage, swizzledSetImage);
    //
    Method swizzledGetImage = class_getInstanceMethod(self, @selector(imageSwizzled));
    Method originalGetImage = class_getInstanceMethod(self, @selector(image));
    method_exchangeImplementations(originalGetImage, swizzledGetImage);
}
+(NSCache*)cache{
    static NSCache *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[NSCache alloc] init];
    });
    return instance;
}
-(void)layoutSubviewsSwizzled{
    [self layoutSubviewsSwizzled];
    //
    UIActivityIndicatorView *indicator = [self.prototype valueForKey:imageViewIndicator];
    if (indicator) {
        [indicator setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
    }
}
-(void)setImageSwizzled:(UIImage*)image{
    [self.prototype setValue:image forKey:imageViewSource];
    if (self.blend) {
        [self setImageSwizzled:[image blendWithColor:self.blend]];
    }else{
        [self setImageSwizzled:image];
    }
}
-(UIImage*)imageSwizzled{
    return [self.prototype valueForKey:imageViewSource];
}
-(void)setBlend:(UIColor *)blend{
    [self.prototype setValue:blend forKey:imageViewBlend];
    [self setImage:self.image];
}
-(UIColor *)blend{
    return [self.prototype valueForKey:imageViewBlend];
}
//本地相对于library目录，网络相对于base目录
-(void)load:(NSString*)file base:(NSString*)base{
    [self.prototype setValue:file forKey:imageViewSrc];
    //
    NSString *path = [NSString libraryAppend:file];
    if (path) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
            if (isDirectory == NO) {
                UIImage *image = [[UIImageView cache] objectForKey:path];
                if (image == nil) {
                    image = [UIImage imageWithContentsOfFile:path];
                }
                if (image) {
                    [[UIImageView cache] setObject:image forKey:path];
                    [self setImage:image];
                }
            }else{
                [self setImage:nil];
            }
            return;
        }
        //
        if (base == nil) base = @"";
        NSString *app = [base stringByAppendingPathComponent:file];
        NSString *web = [app stringByReplacingOccurrencesOfString:@":/" withString:@"://"];
        NSURL *url = [NSURL URLWithString:web];
        if (url) {
            UIActivityIndicatorView *indicator = [self.prototype valueForKey:imageViewIndicator];
            if (indicator == nil) {
                indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [self.prototype setValue:indicator forKey:imageViewIndicator];
                [self addSubview:indicator];
                [indicator startAnimating];
            }
            //
            __weak UIImageView *this = self;
            NSURLSessionDownloadTask *task = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (nil == error) {
                    NSString *dir = [path stringByDeletingLastPathComponent];
                    if (NO == [[NSFileManager defaultManager] fileExistsAtPath:dir]) {
                        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:path] error:nil];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *image = [UIImage imageWithContentsOfFile:path];
                    if (image) {
                        [[UIImageView cache] setObject:image forKey:path];
                        [this setImage:image];
                    }
                    [this.prototype setValue:nil forKey:imageViewIndicator];
                    [indicator removeFromSuperview];
                    [indicator stopAnimating];
                });
            }];
            //
            NSString *imageViewTask = @"imageView.task";
            [[self.prototype valueForKey:imageViewTask] cancel];
            [self.prototype setValue:task forKey:imageViewTask];
            [self setImage:nil];
            [task resume];
        }
    }else{
        [self setImage:nil];
    }
}
-(void)setSrc:(NSString *)src{
    if (self.image == nil || [src isEqualToString:self.src] == NO) {
        [self load:src base:nil];
    }
}
-(NSString *)src{
    return [self.prototype valueForKey:imageViewSrc];
}
@end
