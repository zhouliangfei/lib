//
//  TMJSON.h
//  cutter
//
//  Created by mac on 16/1/14.
//  Copyright © 2016年 e360. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMJSON : NSObject
+(NSString*)stringify:(id)object;
+(id)parse:(NSString*)object;
@end
