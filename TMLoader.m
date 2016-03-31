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
+(NSString*)hash:(NSString*)hash{
    if (hash) {
        NSString *src = [hash md5];
        NSString *ext = [hash pathExtension];
        if (ext && [ext length] > 0) {
            return [src stringByAppendingPathExtension:ext];
        }
        return src;
    }
    return @"";
}
+(void)cancel{
    [[TMLoader queue] cancelAllOperations];
}
//**********************************************************
-(void)main{
    if (NO == self.isCancelled) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [self setCurrentSession:[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil]];
        [self setCurrentTask:[self.currentSession dataTaskWithRequest:self.currentRequest]];
        [self setSemaphore:dispatch_semaphore_create(0)];
        [self.currentTask resume];
        //
        [self performSelectorOnMainThread:@selector(onOpen:) withObject:nil waitUntilDone:NO];
        dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    }
}
-(void)cancel{
    [super cancel];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
        [self setSemaphore:nil];
    }
    //
    [self.currentTask cancel];
    [self.currentSession invalidateAndCancel];
    [self setCurrentSession:nil];
    [self setCurrentTask:nil];
    [self setDelegate:nil];
}
//
-(NSString *)file{
    return self.filePath;
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
-(void)load:(NSURLRequest*)request name:(NSString*)name delegate:(id<TMLoaderDelegate>)delegate cache:(NSInteger)cache{
    if (request) {
        bytesTotal = 0;
        bytesLoaded = 0;
        [self setCacheData:nil];
        [self setCacheType:cache];
        [self setDelegate:delegate];
        [self setCurrentRequest:request];
        //
        if (name == nil) {
            name = [TMLoader hash:request.URL.absoluteString];
        }
        //
        [self setFilePath:[NSString libraryAppend:name]];
        if (self.cacheType==2 && [[NSFileManager defaultManager] fileExistsAtPath:self.filePath]) {
            if (self.delegate) {
                bytesTotal = bytesLoaded = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.filePath error:nil] fileSize];
                [self performSelectorOnMainThread:@selector(onComplete:) withObject:nil waitUntilDone:NO];
            }
            [self cancel];
        }else{
            [self setTempPath:[NSString temporaryAppend:name]];
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
                [[TMLoader queue] addOperation:self];
            }else{
                [self start];
            }
        }
    }
}
//
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    [self performSelectorOnMainThread:@selector(onProgress:) withObject:nil waitUntilDone:NO];
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
            [self performSelectorOnMainThread:@selector(onProgress:) withObject:nil waitUntilDone:NO];
        }
    }else{
        [self cancel];
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
    }
    [self performSelectorOnMainThread:@selector(onComplete:) withObject:error waitUntilDone:NO];
    [self cancel];
}
//
-(void)onOpen:(id)error{
    if ([self.delegate respondsToSelector:@selector(openLoader:)]) {
        [self.delegate openLoader:self];
    }
}
-(void)onProgress:(id)error{
    if ([self.delegate respondsToSelector:@selector(progressLoader:bytesLoaded:bytesTotal:)]) {
        [self.delegate progressLoader:self bytesLoaded:bytesLoaded bytesTotal:bytesTotal];
    }
}
-(void)onComplete:(id)error{
    if ([self.delegate respondsToSelector:@selector(completeLoader:error:)]) {
        [self.delegate completeLoader:self error:error];
    }
}
@end