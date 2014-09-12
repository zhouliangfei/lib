//
//  SQLManager.m
//  dataTest
//
//  Created by mac on 13-6-17.
//  Copyright (c) 2013年 383541328@qq.com All rights reserved.
//

//
#ifndef SQLManager_m
#define SQLManager_m
    #define SQLITE_VOID       1978
#endif

#import "SQLManager.h"
#import <objc/runtime.h>
#import "sqlite3.h"
//sqlite类型名称
static NSString* sqliteTypeName(id type){
    static NSString *sqlite_text=@"text";
    static NSString *sqlite_blob=@"blob";
    static NSString *sqlite_real=@"real";
    static NSString *sqlite_integer=@"integer";
    switch ([type intValue]) {
        case SQLITE_TEXT:
            return sqlite_text;
        case SQLITE_BLOB:
            return sqlite_blob;
        case SQLITE_FLOAT:
            return sqlite_real;
        case SQLITE_INTEGER:
            return sqlite_integer;
        default:
            break;
    }
    return nil;
}
//修正sqlite类型值
static NSString* sqliteReviseValue(id type,id value){
    static NSString *sqlite_number=@"0";
    static NSString *sqlite_string=@"\"\"";
    if (SQLITE_TEXT==[type intValue]) {
        if (value && value!=[NSNull null]) {
            return [NSString stringWithFormat:@"\"%@\"",value];
        }
        return sqlite_string;
    }
    if (value && value!=[NSNull null]) {
        return [NSString stringWithFormat:@"%@",value];
    }
    return sqlite_number;
}
//转换到sqlite类型
static int sqliteConverType(NSString *type){
    if ([type characterAtIndex:0]=='T') {
        switch ([type characterAtIndex:1]) {
            case '@':{
                NSString *first=[[type componentsSeparatedByString:@","] firstObject];
                NSString *className=[[first substringFromIndex:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                Class class = objc_lookUpClass(className.UTF8String);
                if ([class isSubclassOfClass:NSData.class]) {
                    return SQLITE_BLOB;
                }
                if ([class isSubclassOfClass:NSString.class]) {
                    return SQLITE_TEXT;
                }
                if ([class isSubclassOfClass:NSNumber.class]) {
                    return SQLITE_FLOAT;
                }
                break;
            }
            case 'f':
            case 'd':
                return SQLITE_FLOAT;
            case 'i':
            case 's':
            case 'l':
            case 'q':
            case 'I':
            case 'S':
            case 'L':
            case 'Q':
            case 'B':
                return SQLITE_INTEGER;
            default:
                break;
        }
    }
    return SQLITE_VOID;
}

//********************************************
@protocol SQLTransactionDelegate<NSObject>
-(BOOL)transactionEnd;
-(BOOL)transactionBegin;
-(BOOL)transactionCommit;
-(BOOL)transactionRollback;
@end

//*********************************************************
@interface SQLTransaction()
@property(nonatomic,assign) id<SQLTransactionDelegate>delegate;
@end

@implementation SQLTransaction
@synthesize delegate;
-(BOOL)end{
    if (delegate) {
        return [delegate transactionEnd];
    }
    return NO;
}
-(BOOL)begin{
    if (delegate) {
        return [delegate transactionBegin];
    }
    return NO;
}
-(BOOL)commit{
    if (delegate) {
        return [delegate transactionCommit];
    }
    return NO;
}
-(BOOL)rollback{
    if (delegate) {
        return [delegate transactionRollback];
    }
    return NO;
}
@end

//********************************************
@interface SQLManager()<SQLTransactionDelegate>
@property(nonatomic,readonly) sqlite3 *database;
@property(nonatomic,readonly) BOOL conned;
@end

@implementation SQLManager
@synthesize transaction;
@synthesize database;
@synthesize conned;
+(SQLManager*)shareInstance{
    static SQLManager *instance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance=[[SQLManager alloc] init];
    });
    return instance;
}
-(id)init{
    self = [super init];
    if (self) {
        transaction=[[SQLTransaction alloc] init];
    }
    return self;
}
-(void)dealloc{
    [self close];
    [transaction release];
    [super dealloc];
}
-(BOOL)connect:(NSString *)path{
    if (NO==conned) {
        if (SQLITE_OK==sqlite3_open([path UTF8String], &database)) {
            [transaction setDelegate:self];
            conned=YES;
        }
    }
    return conned;
}
-(void)close{
    if (conned) {
        [transaction setDelegate:nil];
        sqlite3_close(database);
        database=NULL;
    }
    conned=NO;
}
-(BOOL)query:(NSString *)sql{
    if (NO==conned){
        @throw [NSException exceptionWithName:@"query" reason:@"select a dataBase file" userInfo:nil];
    }
    if(SQLITE_OK==sqlite3_exec(database, [sql UTF8String], 0, 0, NULL)){
        return YES;
    } else{
        @throw [NSException exceptionWithName:@"query" reason:sql userInfo:nil];
    }
    return NO;
}
-(id)fetch:(NSString *)sql{
    if (NO==conned){
        @throw [NSException exceptionWithName:@"fetch" reason:@"select a dataBase file" userInfo:nil];
    }
    sqlite3_stmt *statement=NULL;
    if (SQLITE_OK==sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)){
        int len=sqlite3_column_count(statement);
        if (len==0) {
            sqlite3_finalize(statement),statement=NULL;
        }else{
            NSMutableArray *result=[[NSMutableArray alloc] init];
            while (SQLITE_ROW==sqlite3_step(statement)){
                NSMutableDictionary *rows = [[NSMutableDictionary alloc] init];
                //
                for (int i=0; i<len; i++){
                    NSString *name=[NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
                    switch(sqlite3_column_type(statement, i)){
                        case SQLITE_BLOB:
                            [rows setValue:[NSData dataWithBytes:sqlite3_column_blob(statement, i) length:sqlite3_column_bytes(statement, i)] forKey:name];
                            break;
                        case SQLITE_TEXT:
                            [rows setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)] forKey:name];
                            break;
                        case SQLITE_FLOAT:
                            [rows setValue:[NSNumber numberWithFloat:sqlite3_column_double(statement, i)] forKey:name];
                            break;
                        case SQLITE_INTEGER:
                            [rows setValue:[NSNumber numberWithInt:sqlite3_column_int(statement, i)] forKey:name];
                            break;
                        case SQLITE_NULL:
                            [rows setValue:[NSNull null] forKey:name];
                            break;
                        default:
                            break;
                    }
                }
                [result addObject:rows];
                [rows release];
            }
            sqlite3_finalize(statement),statement=NULL;
            return [result autorelease];
        }
    }else{
        @throw [NSException exceptionWithName:@"fetch" reason:sql userInfo:nil];
    }
    return nil;
}
//代理
-(BOOL)transactionEnd{
    if( SQLITE_OK==sqlite3_exec(database,"end transaction", 0, 0, NULL)){
        return YES;
    }
    return NO;
}
-(BOOL)transactionBegin{
    if( SQLITE_OK==sqlite3_exec(database,"begin transaction", 0, 0, NULL)){
        return YES;
    }
    return NO;
}
-(BOOL)transactionCommit{
    if( SQLITE_OK==sqlite3_exec(database,"commit transaction", 0, 0, NULL)){
        return YES;
    }
    return NO;
}
-(BOOL)transactionRollback{
    if( SQLITE_OK==sqlite3_exec(database,"rollback transaction", 0, 0, NULL)){
        return YES;
    }
    return NO;
}
@end

//*********************************************************
@implementation SQLObject
//主键
+(NSMutableDictionary*)primaryKeys{
    static NSMutableDictionary *primaryKeyList=nil;
    if (nil==primaryKeyList) {
        primaryKeyList=[[NSMutableDictionary alloc] init];
    }
    return primaryKeyList;
}
//字段
+(NSMutableDictionary*)fields{
    static NSMutableDictionary *fieldList=nil;
    if (nil==fieldList) {
        fieldList=[[NSMutableDictionary alloc] init];
    }
    //
    NSString *className=[NSString stringWithUTF8String:class_getName(self.class)];
    NSMutableDictionary *classField=[fieldList objectForKey:className];
    if (nil==classField) {
        classField=[NSMutableDictionary dictionary];
        [fieldList setValue:classField forKey:className];
        //
        unsigned int count=0;
        objc_property_t *propertys=class_copyPropertyList(self.class, &count);
        for (int i=0; i<count; i++){
            NSInteger itype=sqliteConverType([NSString stringWithUTF8String:property_getAttributes(propertys[i])]);
            if (itype!=SQLITE_VOID) {
                NSString *name=[NSString stringWithUTF8String:property_getName(propertys[i])];
                [classField setValue:[NSNumber numberWithInt:itype] forKey:name];
            }
        }
        free(propertys);
    }
    return classField;
}
//映射表设置主键
+(BOOL)mapping:(NSString*)primaryKey{
    NSString *className=[NSString stringWithUTF8String:class_getName(self.class)];
    [[SQLObject primaryKeys] setValue:primaryKey forKey:className];
    //
    NSString *sqliteSql=[NSString stringWithFormat:@"PRAGMA table_info(\"%@\")", className];
    if (nil==[[SQLManager shareInstance] fetch:sqliteSql]) {
        NSDictionary *fieldList=[self fields];
        if (fieldList.allKeys.count>0) {
            NSMutableArray *values=[NSMutableArray array];
            for (NSString *name in fieldList.allKeys) {
                NSNumber *type=[fieldList objectForKey:name];
                [values addObject:[NSString stringWithFormat:@"\"%@\" %@ DEFAULT %@", name, sqliteTypeName(type), sqliteReviseValue(type, NULL)]];
            }
            if (values.count>0) {
                if (primaryKey && [fieldList objectForKey:primaryKey]) {
                    sqliteSql=[NSString stringWithFormat:@"CREATE TABLE %@ (%@,PRIMARY KEY(\"%@\"))", className, [values componentsJoinedByString:@","], primaryKey];
                    return [[SQLManager shareInstance] query:sqliteSql];
                }else{
                    @throw [NSException exceptionWithName:@"mapping" reason:@"must set up valid primary key" userInfo:nil];
                }
            }
        }
    }
    return NO;
}
//查询
+(id)find:(NSString *)sql{
    NSString *className=[NSString stringWithUTF8String:class_getName(self.class)];
    NSString *sqliteSql=[NSString stringWithFormat:@"SELECT * FROM %@%@", className, (sql ? [NSString stringWithFormat:@" WHERE %@",sql] : @"")];
    //取内容
    NSMutableArray *source=[NSMutableArray array];
    NSArray *temp=[[SQLManager shareInstance] fetch:sqliteSql];
    for (id tmp in temp) {
        id tmpVal=[[self.class alloc] initWithDictionary:tmp];
        [source addObject:tmpVal];
        [tmpVal release];
    }
    return source;
}
//初始化
-(id)initWithDictionary:(NSDictionary*)data{
    self=[super init];
    if (self) {
        if (data) {
            NSDictionary *fieldList=[self.class fields];
            for (id key in fieldList) {
                id value=[data objectForKey:key];
                if (value && value!=[NSNull null]){
                    [self setValue:value forKey:key];
                }
            }
        }
    }
    return self;
}
-(BOOL)delete{
    NSString *className=[NSString stringWithUTF8String:class_getName(self.class)];
    NSString *primaryKey=[[SQLObject primaryKeys] valueForKey:className];
    NSDictionary *fieldList=[self.class fields];
    if (primaryKey && [fieldList objectForKey:primaryKey]) {
        NSString *reviValue=sqliteReviseValue([fieldList objectForKey:primaryKey], [self valueForKey:primaryKey]);
        NSString *sqliteSql=[NSString stringWithFormat:@"DELETE FROM %@ WHERE %@=%@", className, primaryKey, reviValue];
        return [[SQLManager shareInstance] query:sqliteSql];
    }
    return NO;
}
-(BOOL)save{
    NSDictionary *fieldList=[self.class fields];
    NSMutableArray *values=[NSMutableArray array];
    for (NSString *name in fieldList.allKeys) {
        [values addObject:sqliteReviseValue([fieldList objectForKey:name],[self valueForKey:name])];
    }
    if (values.count>0) {
        NSString *className=[NSString stringWithUTF8String:class_getName(self.class)];
        NSString *sqliteSql=[NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)", className, [fieldList.allKeys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
        return [[SQLManager shareInstance] query:sqliteSql];
    }
    return NO;
}
@end
