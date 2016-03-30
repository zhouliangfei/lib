//
//  TMSQLite.h
//  lib
//
//  Created by mac on 13-6-17.
//  Copyright (c) 2013年 tinymedia.cn All rights reserved.
//
#import "sqlite3.h"
#import <Foundation/Foundation.h>

//********************************************
@interface TMTransaction : NSObject
-(BOOL)end;
-(BOOL)begin;
-(BOOL)commit;
-(BOOL)rollback;
@end

//********************************************
@interface TMSQLite : NSObject
@property(strong ,nonatomic) TMTransaction *transaction;
@property(readonly ,nonatomic) long long int lastInsertId;
@property(readonly ,nonatomic) int changes;
+(TMSQLite*)shareInstance;
-(BOOL)connect:(NSString *)path;
-(id)query:(NSString *)sql;
-(void)close;
@end

//********************************************
@interface TMSQLiteObject : NSObject
+(BOOL)mapping:(NSArray*)primaryKeys;
+(id)find:(NSString *)find;
//
-(id)initWithData:(NSDictionary*)data;
-(BOOL)delete;
-(BOOL)save;
@end
