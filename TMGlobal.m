//
//  TMGlobal.m
//  cutter
//
//  Created by mac on 16/1/14.
//  Copyright © 2016年 e360. All rights reserved.
//

#import "TMGlobal.h"
#import <CommonCrypto/CommonDigest.h>

@implementation TMGlobal
+(NSMutableDictionary*)shareInstance{
    static dispatch_once_t onceToken = 0;
    static NSMutableDictionary *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSMutableDictionary alloc] init];
    });
    return instance;
}
+(void)setValue:(id)value forKey:(NSString*)forKey{
    [[TMGlobal shareInstance] setValue:value forKey:forKey];
}
+(id)valueForKey:(NSString*)forKey{
    return [[TMGlobal shareInstance] valueForKey:forKey];
}
@end
//
id filterEmpty(id object){
    if (object == nil || object == [NSNull null]) {
        return nil;
    }
    if ([object isKindOfClass:NSArray.class] && [object count] == 0) {
        return nil;
    }
    if ([object isKindOfClass:NSString.class] && [object length] == 0) {
        return nil;
    }
    if ([object isKindOfClass:NSDictionary.class] && [object count] == 0) {
        return nil;
    }
    return object;
}
NSString *uuid(){
    CFUUIDRef object = CFUUIDCreate(kCFAllocatorDefault);
    NSString *string = (__bridge NSString *)CFUUIDCreateString(kCFAllocatorDefault, object);
    CFRelease(object);
    return string;
}
//md5
NSString *md5(NSString* string){
    if (string && [string isKindOfClass:[NSString class]]) {
        const char *cStr = [string UTF8String];
        unsigned char result[CC_MD5_DIGEST_LENGTH];
        CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
        
        NSMutableString *temp = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
        for(uint i = 0; i < CC_MD5_DIGEST_LENGTH; i++){
            [temp appendFormat:@"%02x",result[i]];
        }
        return [temp lowercaseString];
    }
    return @"";
}
//base64解码
NSString *base64Encoded(NSString* string){
    if (string && [string isKindOfClass:[NSString class]]) {
        NSData *data=[string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *encode=[data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        return encode;
    }
    return @"";
}
//base64解码
NSString *base64Decoded(NSString* string){
    if (string && [string isKindOfClass:[NSString class]]) {
        NSData *data=[[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *decode=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return decode;
    }
    return @"";
}
//
//
NSString *pathForTemporary(NSString*path){
    if ([path isKindOfClass:NSString.class]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] stringByAppendingPathComponent:path];
    }
    return nil;
}
NSString *pathForDocument(NSString*path){
    if ([path isKindOfClass:NSString.class]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:path];
    }
    return nil;
}
NSString *pathForResource(NSString*path){
    if ([path isKindOfClass:NSString.class]) {
        return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:path];
    }
    return nil;
}
NSString *pathForLibrary(NSString*path){
    if ([path isKindOfClass:NSString.class]) {
        return [[NSHomeDirectory() stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:path];
    }
    return nil;
}