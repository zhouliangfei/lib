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
