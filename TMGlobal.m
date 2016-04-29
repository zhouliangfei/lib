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
