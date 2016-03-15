//
//  TMJSON.m
//  cutter
//
//  Created by mac on 16/1/14.
//  Copyright © 2016年 e360. All rights reserved.
//

#import "TMJSON.h"

@implementation TMJSON
+(NSString*)stringify:(id)object{
    if ([NSJSONSerialization isValidJSONObject:object]){
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
        if (nil == error){
            return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}
+(id)parse:(NSString*)object{
    if ([object isKindOfClass:NSString.class]){
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
@end
