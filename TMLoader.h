//
//  TMLoader.h
//  
//
//  Created by 周良飞 on 15/5/23.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import <Foundation/Foundation.h>

//
#pragma mark-
#pragma mark TMLoader
@protocol TMLoaderDelegate;
@interface TMLoader : NSOperation<NSURLSessionDataDelegate>
@property(nonatomic, readonly) NSURLRequest *request;
@property(nonatomic, readonly) NSData *data;
//request,[nil=同步],[0=不缓存,1=网络优先，2=本地优先]
+(TMLoader*)load:(NSURLRequest*)request delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache;
+(void)cancel;
@end

//
#pragma mark-
#pragma mark TMLoaderDelegate
@protocol TMLoaderDelegate <NSObject>
@optional
-(void)openLoader:(TMLoader *)loader;
-(void)completeLoader:(TMLoader *)loader error:(NSError*)error;
-(void)progressLoader:(TMLoader *)loader bytesLoaded:(unsigned long long)bytesLoaded bytesTotal:(unsigned long long)bytesTotal;
@end