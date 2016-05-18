//
//  TMSQLite.m
//  lib
//
//  Created by mac on 13-6-17.
//  Copyright (c) 2013年 tinymedia.cn All rights reserved.
//

#import "TMSQLite.h"
#import <objc/runtime.h>

//
#ifndef TMSQLite_m
#define TMSQLite_m
#define SQLITE_VOID       0xFF
#endif

//sqlite类型名称
static NSString* sqliteTypeName(id type){
    static NSString *sqlite_text = @"text";
    static NSString *sqlite_blob = @"blob";
    static NSString *sqlite_real = @"real";
    static NSString *sqlite_integer = @"integer";
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
    static NSString *sqlite_number = @"0";
    static NSString *sqlite_string = @"\'\'";
    if (SQLITE_TEXT == [type intValue]) {
        if (value && value != [NSNull null]) {
            /*NSString *string=[value stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
             string=[string stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
             string=[string stringByReplacingOccurrencesOfString:@"[" withString:@"/["];
             string=[string stringByReplacingOccurrencesOfString:@"]" withString:@"/]"];
             string=[string stringByReplacingOccurrencesOfString:@"%" withString:@"/%"];
             string=[string stringByReplacingOccurrencesOfString:@"&" withString:@"/&"];
             string=[string stringByReplacingOccurrencesOfString:@"_" withString:@"/_"];
             string=[string stringByReplacingOccurrencesOfString:@"(" withString:@"/("];
             string=[string stringByReplacingOccurrencesOfString:@")" withString:@"/)"];*/
            NSString *string = [value stringByReplacingOccurrencesOfString:@"'" withString:@"''"];
            return [NSString stringWithFormat:@"\'%@\'",string];
        }
        return sqlite_string;
    }
    if (value && value != [NSNull null]) {
        return [NSString stringWithFormat:@"%@",value];
    }
    return sqlite_number;
}

//转换到sqlite类型
static int sqliteConverType(NSString *type){
    if ([type characterAtIndex:0] == 'T') {
        switch ([type characterAtIndex:1]) {
            case '@':{
                NSString *first = [[type componentsSeparatedByString:@","] firstObject];
                NSString *className = [[first substringFromIndex:2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
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
@protocol TMTransactionDelegate<NSObject>
-(BOOL)transactionEnd;
-(BOOL)transactionBegin;
-(BOOL)transactionCommit;
-(BOOL)transactionRollback;
@end

//********************************************
@interface TMTransaction ()
@property(nonatomic,assign) id<TMTransactionDelegate>delegate;
@end
@implementation TMTransaction
-(BOOL)end{
    if ([self.delegate respondsToSelector:@selector(transactionEnd)]) {
        return [self.delegate transactionEnd];
    }
    return NO;
}
-(BOOL)begin{
    if ([self.delegate respondsToSelector:@selector(transactionBegin)]) {
        return [self.delegate transactionBegin];
    }
    return NO;
}
-(BOOL)commit{
    if ([self.delegate respondsToSelector:@selector(transactionCommit)]) {
        return [self.delegate transactionCommit];
    }
    return NO;
}
-(BOOL)rollback{
    if ([self.delegate respondsToSelector:@selector(transactionRollback)]) {
        return [self.delegate transactionRollback];
    }
    return NO;
}
@end

//********************************************
@interface TMSQLite()<TMTransactionDelegate>{
    sqlite3 *database;
}
@property(strong, atomic) NSThread *thread;
@property(assign, atomic) BOOL conned;
@end
@implementation TMSQLite
+(TMSQLite*)shareInstance{
    static TMSQLite *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[TMSQLite alloc] init];
    });
    return instance;
}
-(instancetype)init{
    self = [super init];
    if (self) {
        [self setTransaction:[[TMTransaction alloc] init]];
        [self setThread:[NSThread currentThread]];
    }
    return self;
}
-(int)lastInsertId{
    if (self.conned){
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(lastInsertId) args:nil];
            return [result intValue];
        }
        return (int)sqlite3_last_insert_rowid(database);
    }
    return 0;
}
-(int)changes{
    if (self.conned){
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(changes) args:nil];
            return [result intValue];
        }
        return sqlite3_changes(database);
    }
    return 0;
}
-(BOOL)connect:(NSString*)path{
    if (self.conned == NO) {
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(connect:) args:[NSArray arrayWithObject:path]];
            return [result boolValue];
        }
        if (SQLITE_OK == sqlite3_open_v2([path UTF8String], &database, SQLITE_CONFIG_MULTITHREAD, NULL)) {
            [self.transaction setDelegate:self];
            [self setConned:YES];
            return YES;
        }
    }
    return NO;
}
-(id)query:(NSString *)sql{
    if (self.conned){
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(query:) args:[NSArray arrayWithObject:sql]];
            return result;
        }
        //
        sqlite3_stmt *statement = NULL;
        if (SQLITE_OK == sqlite3_prepare_v2(database, [sql UTF8String], -1, &statement, NULL)){
            int step = sqlite3_step(statement);
            if (step == SQLITE_DONE) {
                int readonly = sqlite3_stmt_readonly(statement);
                sqlite3_finalize(statement);
                if (readonly == 0) {
                    return [NSNumber numberWithBool:YES];
                }
            }
            if (step == SQLITE_ROW) {
                int length = sqlite3_column_count(statement);
                NSMutableArray *result = [NSMutableArray array];
                while (step == SQLITE_ROW){
                    NSMutableDictionary *rows = [NSMutableDictionary dictionary];
                    for (uint i = 0; i < length; i++){
                        NSString *name = [NSString stringWithUTF8String:sqlite3_column_name(statement, i)];
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
                    //
                    step = sqlite3_step(statement);
                }
                sqlite3_finalize(statement);
                return result;
            }
        }else{
            sqlite3_finalize(statement);
            @throw [NSException exceptionWithName:[NSString stringWithFormat:@"%s",sqlite3_errmsg(database)] reason:sql userInfo:nil];
        }
    }
    return nil;
}
-(BOOL)close{
    if (self.conned) {
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(close) args:nil];
            return [result boolValue];
        }
        if (SQLITE_OK == sqlite3_close_v2(database)) {
            [self.transaction setDelegate:nil];
            [self setConned:NO];
            database = NULL;
            return YES;
        }
    }
    return NO;
}
-(BOOL)transactionEnd{
    if(self.conned){
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(transactionEnd) args:nil];
            return [result boolValue];
        }
        NSString *sql = @"END TRANSACTION";
        if (SQLITE_OK == sqlite3_exec(database, [sql UTF8String], 0, 0, NULL)) {
            return YES;
        }
    }
    return NO;
}
-(BOOL)transactionBegin{
    if(self.conned){
        if ([NSThread isMainThread] == NO) {
            id result = [self cmd:@selector(transactionBegin) args:nil];
            return [result boolValue];
        }
        NSString *sql = @"BEGIN TRANSACTION";
        if (SQLITE_OK == sqlite3_exec(database, [sql UTF8String], 0, 0, NULL)) {
            return YES;
        }
    }
    return NO;
}
-(BOOL)transactionCommit{
    if(self.conned){
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(transactionCommit) args:nil];
            return [result boolValue];
        }
        NSString *sql = @"COMMIT TRANSACTION";
        if (SQLITE_OK == sqlite3_exec(database, [sql UTF8String], 0, 0, NULL)) {
            return YES;
        }
    }
    return NO;
}
-(BOOL)transactionRollback{
    if(self.conned){
        if ([NSThread currentThread] != self.thread) {
            id result = [self cmd:@selector(transactionRollback) args:nil];
            return [result boolValue];
        }
        NSString *sql = @"ROLLBACK TRANSACTION";
        if (SQLITE_OK == sqlite3_exec(database, [sql UTF8String], 0, 0, NULL)) {
            return YES;
        }
    }
    return NO;
}
-(id)cmd:(SEL)selector args:(NSArray*)args{
    NSMethodSignature *method = [self.class instanceMethodSignatureForSelector:selector];
    NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:method];
    if (args && [args count] > 0) {
        for (NSUInteger i=0;i<[args count];i++) {
            id arg = [args objectAtIndex:i];
            [invocation setArgument:&arg atIndex:2 + i];
        }
    }
    [invocation retainArguments];
    [invocation setSelector:selector];
    [invocation performSelector:@selector(invokeWithTarget:) onThread:self.thread withObject:self waitUntilDone:YES];
    //
    NSUInteger len = method.methodReturnLength;
    if (len > 0) {
        const char *type = method.methodReturnType;
        if(!strcmp(type, @encode(id)) ){
            id __unsafe_unretained data = nil;
            [invocation getReturnValue:&data];
            return data;
        }
        //
        void *buffer = (void *)malloc(len);
        [invocation getReturnValue:buffer];
        if(!strcmp(type, @encode(BOOL)) || !strcmp(type, @encode(int))) {
            return [NSNumber numberWithChar:*((char*)buffer)];
        }
        return [NSValue valueWithBytes:buffer objCType:type];
    }
    return nil;
}
@end

//*********************************************************
@implementation TMSQLiteObject
//主键
+(NSMutableDictionary*)primaryKeys{
    static dispatch_once_t onceToken = 0;
    static NSMutableDictionary *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[NSMutableDictionary alloc] init];
    });
    return instance;
}
//字段
+(NSMutableDictionary*)fields{
    static dispatch_once_t onceToken = 0;
    static NSMutableDictionary *fieldList = nil;
    dispatch_once(&onceToken, ^{
        fieldList = [[NSMutableDictionary alloc] init];
    });
    //
    NSString *className = [NSString stringWithUTF8String:class_getName(self.class)];
    NSMutableDictionary *classField = [fieldList objectForKey:className];
    if (nil == classField) {
        classField = [NSMutableDictionary dictionary];
        [fieldList setValue:classField forKey:className];
        //
        unsigned int count=0;
        objc_property_t *propertys = class_copyPropertyList(self.class, &count);
        for (uint i = 0; i < count; i++){
            NSInteger itype = sqliteConverType([NSString stringWithUTF8String:property_getAttributes(propertys[i])]);
            if (itype != SQLITE_VOID) {
                NSString *name=[NSString stringWithUTF8String:property_getName(propertys[i])];
                [classField setValue:[NSNumber numberWithInteger:itype] forKey:name];
            }
        }
        free(propertys);
    }
    return classField;
}
//映射表设置主键
+(BOOL)mapping:(NSArray*)primaryKeys{
    NSString *className = [NSString stringWithUTF8String:class_getName(self.class)];
    if (primaryKeys.count > 0) {
        [[TMSQLiteObject primaryKeys] setValue:primaryKeys forKey:className];
    }
    //
    NSString *sqliteSql = [NSString stringWithFormat:@"PRAGMA table_info(\"%@\")", className];
    if (nil == [[TMSQLite shareInstance] query:sqliteSql]) {
        NSDictionary *fieldList = [self fields];
        if (fieldList.allKeys.count > 0) {
            NSMutableArray *field = [NSMutableArray array];
            for (NSString *name in fieldList.allKeys) {
                NSNumber *type = [fieldList objectForKey:name];
                [field addObject:[NSString stringWithFormat:@"\"%@\" %@ DEFAULT %@", name, sqliteTypeName(type), sqliteReviseValue(type, NULL)]];
            }
            if (primaryKeys.count > 0) {
                NSString *primary = nil;
                for (id key in primaryKeys) {
                    if (primary) {
                        primary = [primary stringByAppendingFormat:@", \"%@\"",key];
                    }else{
                        primary = [NSString stringWithFormat:@"\"%@\"",key];
                    }
                }
                sqliteSql = [NSString stringWithFormat:@"CREATE TABLE %@ (%@, PRIMARY KEY(%@))", className, [field componentsJoinedByString:@","], primary];
            }else{
                sqliteSql = [NSString stringWithFormat:@"CREATE TABLE %@ (%@)", className, [field componentsJoinedByString:@","]];
            }
            if ([[TMSQLite shareInstance] query:sqliteSql]) {
                return YES;
            }
        }
    }
    return NO;
}
//查询
+(id)find:(NSString *)find{
    NSString *className = [NSString stringWithUTF8String:class_getName(self.class)];
    NSString *sqliteSql = [NSString stringWithFormat:@"SELECT * FROM %@", className];
    if (find) {
        sqliteSql = [sqliteSql stringByAppendingFormat:@" WHERE %@",find];
    }
    //
    NSArray *temp = [[TMSQLite shareInstance] query:sqliteSql];
    if (temp) {
        NSMutableArray *source = [NSMutableArray array];
        for (id tmp in temp) {
            id tmpVal = [[self.class alloc] initWithData:tmp];
            [source addObject:tmpVal];
        }
        return source;
    }
    return nil;
}
//初始化
-(id)initWithData:(NSDictionary*)data{
    self = [super init];
    if (self && data) {
        NSDictionary *fieldList = [self.class fields];
        for (id key in fieldList) {
            id value = [data objectForKey:key];
            if (value && value != [NSNull null]){
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}
-(BOOL)delete{
    NSString *className = [NSString stringWithUTF8String:class_getName(self.class)];
    NSArray *primaryKey = [[TMSQLiteObject primaryKeys] valueForKey:className];
    NSDictionary *fieldList = [self.class fields];
    if (nil == primaryKey) {
        primaryKey = fieldList.allKeys;
    }
    NSString *values = nil;
    for (NSString *name in primaryKey) {
        NSString *value = sqliteReviseValue([fieldList objectForKey:name], [self valueForKey:name]);
        if (values) {
            values = [values stringByAppendingFormat:@" AND %@=%@",name,value];
        }else{
            values = [NSString stringWithFormat:@"%@=%@",name,value];
        }
    }
    if (values) {
        NSString *sqliteSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@", className, values];
        if ([[TMSQLite shareInstance] query:sqliteSql]) {
            return YES;
        }
        return NO;
    }
    return NO;
}
-(BOOL)save{
    NSDictionary *fieldList = [self.class fields];
    NSMutableArray *values = [NSMutableArray array];
    for (NSString *name in fieldList.allKeys) {
        [values addObject:sqliteReviseValue([fieldList objectForKey:name],[self valueForKey:name])];
    }
    if (values.count > 0) {
        NSString *className = [NSString stringWithUTF8String:class_getName(self.class)];
        NSString *sqliteSql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)", className, [fieldList.allKeys componentsJoinedByString:@","], [values componentsJoinedByString:@","]];
        if ([[TMSQLite shareInstance] query:sqliteSql]) {
            return YES;
        }
        return NO;
    }
    return NO;
}
@end
