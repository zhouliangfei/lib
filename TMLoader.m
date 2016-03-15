//
//  TMLoader.m
//  
//
//  Created by 周良飞 on 15/5/23.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import "TMLoader.h"
#import "TMCategory.h"

//
#pragma mark-
#pragma mark TMLoader
@interface TMLoader () <NSStreamDelegate>{
    unsigned long long bytesLoaded;
    unsigned long long bytesTotal;
}
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, copy) NSString *tempPath;
@property(nonatomic, strong) NSLock *locker;
@property(nonatomic, strong) NSData *cacheData;
@property(nonatomic, assign) NSInteger cacheType;
@property(nonatomic, strong) NSURLRequest *currentRequest;
@property(nonatomic, strong) NSURLSession *currentSession;
@property(nonatomic, strong) NSURLSessionDataTask *currentTask;
@property(nonatomic, weak) id<TMLoaderDelegate> delegate;
-(void)load:(NSURLRequest*)request delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache;
@end
//
@implementation TMLoader
+(NSOperationQueue*)queue{
    static dispatch_once_t onceToken = 0;
    static NSOperationQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSOperationQueue alloc] init];
        [instance setMaxConcurrentOperationCount:3];
    });
    return instance;
}
+(NSMutableArray*)waits{
    static dispatch_once_t onceToken = 0;
    static NSMutableArray *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSMutableArray alloc] init];
    });
    return instance;
}
+(TMLoader*)load:(NSURLRequest*)request delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache{
    if (request) {
        TMLoader *loader = [[TMLoader alloc] init];
        [loader load:request delegate:delegate cache:cache];
        return loader;
    }
    return nil;
}
+(void)cancel{
    [[TMLoader queue] cancelAllOperations];
}
//**********************************************************
-(void)main{
    if (NO == self.isCancelled) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [self setCurrentSession:[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[[NSOperationQueue alloc] init]]];
        [self setCurrentTask:[self.currentSession dataTaskWithRequest:self.currentRequest]];
        [self.currentTask resume];
        //
        if ([self.delegate respondsToSelector:@selector(openLoader:)]) {
            [self.delegate openLoader:self];
        }
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHand:) userInfo:nil repeats:YES];
        while(self.isCancelled == NO){
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        }
        [timer invalidate];
    }
}
-(void)cancel{
    [super cancel];
    [self.currentTask cancel];
    [self.currentSession invalidateAndCancel];
    [self setCurrentSession:nil];
    [self setCurrentTask:nil];
    [self setDelegate:nil];
}
//
-(void)timerHand:(NSTimer*)timer{
    NSLog(@"000000");
}
-(NSData *)data{
    if ([self cacheData]) {
        return [self cacheData];
    }
    return [NSData dataWithContentsOfFile:self.filePath];
}
-(NSURLRequest*)request{
    return [self currentRequest];
}
-(void)load:(NSURLRequest*)request delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache{
    if (request) {
        bytesTotal = 0;
        bytesLoaded = 0;
        [self setCacheData:nil];
        [self setCacheType:cache];
        [self setDelegate:delegate];
        [self setCurrentRequest:request];
        //
        NSString *hashName = [self hashRequest:request];
        [self setFilePath:[NSString libraryAppend:hashName]];
        if (self.cacheType==2 && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            if (self.delegate) {
                bytesTotal = bytesLoaded = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil] fileSize];
                if ([self.delegate respondsToSelector:@selector(completeLoader:error:)]) {
                    [self.delegate completeLoader:self error:nil];
                }
            }
            [self cancel];
        }else{
            [self setTempPath:[NSString temporaryAppend:hashName]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempPath]) {
                if ([self.currentRequest respondsToSelector:@selector(addValue:forHTTPHeaderField:)]) {
                    bytesLoaded = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.tempPath error:nil] fileSize];
                    [(NSMutableURLRequest*)self.currentRequest addValue:[NSString stringWithFormat:@"bytes=%llu-", bytesLoaded] forHTTPHeaderField:@"Range"];
                }else{
                    [[NSFileManager defaultManager] removeItemAtPath:self.tempPath error:nil];
                    [[NSFileManager defaultManager] createFileAtPath:self.tempPath contents:nil attributes:nil];
                }
            }else{
                [[NSFileManager defaultManager] createFileAtPath:self.tempPath contents:nil attributes:nil];
            }
            //
            if (self.delegate) {
                if ([[TMLoader queue] maxConcurrentOperationCount] != 1) {
                    @synchronized([TMLoader waits]) {
                        for (TMLoader *temp in [[TMLoader queue] operations]) {
                            if ([temp.request.URL isEqual:self.request.URL]) {
                                [[TMLoader waits] addObject:self];
                                return;
                            }
                        }
                    }
                }
                @synchronized([TMLoader queue]) {
                    [[TMLoader queue] addOperation:self];
                }
            }else{
                [self start];
            }
        }
    }
}
-(NSString*)hashRequest:(NSURLRequest*)request{
    NSString *string = [[request URL] absoluteString];
    if (string) {
        NSString *src = [string md5];
        NSString *ext = [string pathExtension];
        if (ext && [ext length] > 0) {
            return [src stringByAppendingPathExtension:ext];
        }
        return src;
    }
    return @"";
}
//
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    if ([self.delegate respondsToSelector:@selector(progressLoader:bytesLoaded:bytesTotal:)]) {
        [self.delegate progressLoader:self bytesLoaded:totalBytesSent bytesTotal:totalBytesExpectedToSend];
    }
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    NSHTTPURLResponse *response = (NSHTTPURLResponse*)dataTask.response;
    if (response.statusCode == 200 || response.statusCode == 206) {
        if (response.statusCode == 200) {
            bytesTotal = dataTask.countOfBytesExpectedToReceive;
        }else{
            NSString *contentRange = [response.allHeaderFields valueForKey:@"Content-Range"];
            if ([contentRange hasPrefix:@"bytes"]) {
                NSArray *bytes = [contentRange componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -/"]];
                if ([bytes count] == 4) {
                    bytesTotal = [[bytes objectAtIndex:3] longLongValue];
                }
            }
        }
        if (data) {
            NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:[self tempPath]];
            [fileHandle seekToEndOfFile];
            [fileHandle writeData:data];
            [fileHandle closeFile];
            //
            bytesLoaded += data.length;
            if ([self.delegate respondsToSelector:@selector(progressLoader:bytesLoaded:bytesTotal:)]) {
                [self.delegate progressLoader:self bytesLoaded:bytesLoaded bytesTotal:bytesTotal];
            }
        }
    }
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    NSString *tempPath = [self tempPath];
    if (error == nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
            NSString *filePath = [self filePath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            if (self.cacheType == 0) {
                [self setCacheData:[NSData dataWithContentsOfFile:tempPath]];
                [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
            }else{
                [[NSFileManager defaultManager] moveItemAtPath:tempPath toPath:filePath error:nil];
            }
        }
    }else{
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    }
    if ([self.delegate respondsToSelector:@selector(completeLoader:error:)]) {
        [self.delegate completeLoader:self error:error];
    }
    [self cancel];
    //
    @synchronized([TMLoader waits]) {
        for (TMLoader *temp in [[TMLoader waits] reverseObjectEnumerator]) {
            if ([temp isCancelled]) {
                [[TMLoader waits] removeObject:temp];
            }
        }
    }
    @synchronized([TMLoader queue]) {
        for (TMLoader *temp in [TMLoader waits]) {
            if ([temp.request.URL isEqual:self.request.URL]) {
                [[TMLoader queue] addOperation:temp];
                break;
            }
        }
    }
}
@end