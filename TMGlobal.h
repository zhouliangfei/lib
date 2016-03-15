//
//  TMGlobal.h
//  cutter
//
//  Created by mac on 16/1/14.
//  Copyright © 2016年 e360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMGlobal : NSObject
+(void)setValue:(id)value forKey:(NSString*)forKey;
+(id)valueForKey:(NSString*)forKey;
@end

//
id filterEmpty(id object);
NSString *uuid();
NSString *md5(NSString *string);
NSString *base64Encoded(NSString *string);
NSString *base64Decoded(NSString *string);

//
NSString *pathForTemporary(NSString *path);
NSString *pathForDocument(NSString *path);
NSString *pathForResource(NSString *path);
NSString *pathForLibrary(NSString *path);
