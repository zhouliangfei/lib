//
//  TMRequest.h
//  
//
//  Created by 周良飞 on 15/5/23.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import <Foundation/Foundation.h>

//
#pragma mark-
#pragma mark TMRequest
@interface TMRequest : NSMutableURLRequest
+(TMRequest*)requestWithURL:(NSURL*)url data:(id)data;
+(TMRequest*)requestWithURL:(NSURL*)url data:(id)data type:(NSString*)type;
@end