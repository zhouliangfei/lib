//
//  SQLManager.h
//  dataTest
//
//  Created by mac on 13-6-17.
//  Copyright (c) 2013年 383541328@qq.com All rights reserved.
//
#import <Foundation/Foundation.h>

//********************************************
@interface SQLTransaction : NSObject
-(BOOL)end;
-(BOOL)begin;
-(BOOL)commit;
-(BOOL)rollback;
@end

//********************************************
@interface SQLManager : NSObject
+(SQLManager*)shareInstance;
//
@property(nonatomic,readonly) SQLTransaction *transaction;
-(BOOL)connect:(NSString *)path;
-(void)close;
//
-(BOOL)query:(NSString *)sql;
-(id)fetch:(NSString *)sql;
@end

//********************************************
@interface SQLObject : NSObject
+(BOOL)mapping:(NSString*)primaryKey;
+(id)find:(NSString *)sql;
//
-(id)initWithDictionary:(NSDictionary*)data;
-(BOOL)delete;
-(BOOL)save;
@end
