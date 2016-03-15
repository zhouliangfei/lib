//
//  TMRequest.m
//  
//
//  Created by 周良飞 on 15/5/23.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import "TMRequest.h"

//
#pragma mark-
#pragma mark TMRequest
@implementation TMRequest
+(TMRequest*)requestWithURL:(NSURL*)url data:(id)data{
    return [TMRequest requestWithURL:url data:data type:nil];
}
+(TMRequest*)requestWithURL:(NSURL*)url data:(id)data type:(NSString*)type{
    if (url) {
        TMRequest *request= [TMRequest requestWithURL:url];
        if (data) {
            if ([data isKindOfClass:[NSDictionary class]]) {
                NSString *boundary = @"----64F4845541AEA084";
                NSMutableData *body = [NSMutableData data];
                for(NSString *key in [data allKeys]){
                    id value = [data objectForKey:key];
                    if (value) {
                        if([value isKindOfClass:[NSData class]]){
                            NSString *temp=[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: application/octet-stream\r\n\r\n", boundary, key, key];
                            [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                            [body appendData:value];
                        }else{
                            NSString *temp=[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n%@", boundary, key, value];
                            [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                        }
                        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                    }
                }
                NSString *temp = [NSString stringWithFormat:@"--%@--",boundary];
                [body appendData:[temp dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
                //
                [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[body length]] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:body];
            }
            if ([data isKindOfClass:[NSString class]]) {
                NSData *body=[data dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                [request setValue:(type == nil ? @"application/x-www-form-urlencoded;" : type) forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[body length]] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:body];
            }
            if ([data isKindOfClass:[NSData class]]) {
                [request setValue:@"application/octet-stream;" forHTTPHeaderField:@"Content-Type"];
                [request setValue:[NSString stringWithFormat:@"%llu", (unsigned long long)[data length]] forHTTPHeaderField:@"Content-Length"];
                [request setHTTPBody:data];
            }
            [request setTimeoutInterval:120];
            [request setHTTPMethod:@"POST"];
        }
        return request;
    }
    return nil;
}
@end