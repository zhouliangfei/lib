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
@property(nonatomic, copy) NSString *tempPath;
@property(nonatomic, copy) NSString *filePath;
@property(nonatomic, strong) NSData *cacheData;
@property(nonatomic, assign) NSInteger cacheType;
@property(nonatomic, strong) NSURLRequest *currentRequest;
@property(nonatomic, strong) NSURLSession *currentSession;
@property(nonatomic, strong) NSURLSessionDataTask *currentTask;
@property(nonatomic, strong) dispatch_semaphore_t semaphore;

@property(nonatomic, weak) id<TMLoaderDelegate> delegate;
-(void)load:(NSURLRequest*)request name:(NSString*)name delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache;
@end
//
@implementation TMLoader
+(NSOperationQueue*)queue{
    static dispatch_once_t onceToken = 0;
    static NSOperationQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSOperationQueue alloc] init];
        [instance setMaxConcurrentOperationCount:1];
    });
    return instance;
}
+(TMLoader*)load:(NSURLRequest*)request name:(NSString*)name delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache{
    if (request) {
        TMLoader *loader = [[TMLoader alloc] init];
        [loader load:request name:name delegate:delegate cache:cache];
        return loader;
    }
    return nil;
}
+(TMLoader*)load:(NSURLRequest*)request delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache{
    if (request) {
        TMLoader *loader = [[TMLoader alloc] init];
        [loader load:request name:nil delegate:delegate cache:cache];
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
        [self setCurrentSession:[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:self.delegate ? [NSOperationQueue mainQueue] : nil]];
        [self setCurrentTask:[self.currentSession dataTaskWithRequest:self.currentRequest]];
        //
        [self onOpen:nil];
        [self semaphoreMake];
        [self.currentTask resume];
        [self semaphoreWait];
    }
}
-(void)cancel{
    [super cancel];
    [self semaphoreSignal];
    [self.currentTask cancel];
    [self.currentSession invalidateAndCancel];
    [self setCurrentSession:nil];
    [self setCurrentTask:nil];
}
//信号
-(void)semaphoreSignal{
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
        [self setSemaphore:nil];
    }
}
-(void)semaphoreMake{
    [self setSemaphore:dispatch_semaphore_create(0)];
}
-(void)semaphoreWait{
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
}
//
-(NSString *)file{
    return self.filePath;
}
-(NSData *)data{
    if (self.cacheType == 0) {
        if (self.cacheData == nil) {
            [self setCacheData:[NSData dataWithContentsOfFile:self.filePath]];
            [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
        }
        return self.cacheData;
    }
    return [NSData dataWithContentsOfFile:self.filePath];
}
-(NSURLRequest*)request{
    return [self currentRequest];
}
-(void)load:(NSURLRequest*)request name:(NSString*)name delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache{
    if (request) {
        bytesTotal = 0;
        bytesLoaded = 0;
        [self setCacheData:nil];
        [self setCacheType:cache];
        [self setDelegate:delegate];
        [self setCurrentRequest:request];
        //
        [self setName:name];
        if (self.name == nil) {
            [self setName:[request.URL.absoluteString pathHash]];
        }
        //
        [self setFilePath:[NSString libraryAppend:self.name]];
        if (self.cacheType==2 && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            if (self.delegate) {
                bytesTotal = bytesLoaded = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil] fileSize];
                [self onComplete:nil];
            }
            [self cancel];
        }else{
            [self setTempPath:[NSString temporaryAppend:self.name]];
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
            if (self.delegate) {
                [[TMLoader queue] addOperation:self];
            }else{
                [self start];
            }
        }
    }
}
//
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    [self onProgress:nil];
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
            [self onProgress:nil];
        }
    }else{
        [self cancel];
    }
}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (error == nil) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempPath]) {
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
            }
            [[NSFileManager defaultManager] moveItemAtPath:self.tempPath toPath:self.filePath error:nil];
        }
    }
    [self onComplete:error];
    [self cancel];
}
//
-(void)onOpen:(id)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(openLoader:)]) {
        [self.delegate openLoader:self];
    }
}
-(void)onProgress:(id)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressLoader:bytesLoaded:bytesTotal:)]) {
        [self.delegate progressLoader:self bytesLoaded:bytesLoaded bytesTotal:bytesTotal];
    }
}
-(void)onComplete:(id)error{
    if (self.delegate && [self.delegate respondsToSelector:@selector(completeLoader:error:)]) {
        [self.delegate completeLoader:self error:error];
    }
}
@end
