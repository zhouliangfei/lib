//
//  TMPanorama.h
//  panorama
//
//  Created by 周良飞 on 15/5/30.
//  Copyright (c) 2015年 tinymedia. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
/*
 y  z
 | /
 |/
 ---------x
 |
 */

//
//
typedef struct{
    GLfloat start;
    GLfloat end;
}TMRange;
TMRange TMMakeRange(GLfloat start, GLfloat end);

//
//
#pragma mark-
#pragma mark TMPanoramaHotSpot
@interface TMPanoramaHotSpot:UIButton
@property (strong, nonatomic) id data;
@property (assign, nonatomic) CGFloat x;
@property (assign, nonatomic) CGFloat y;
@property (assign, nonatomic) CGFloat z;
@end

//
//
@interface TMPanorama : GLKViewController
@property(assign ,nonatomic) TMRange pitchRange;
@property(assign ,nonatomic) TMRange rollRange;
@property(assign ,nonatomic) TMRange yawRange;
@property(assign ,nonatomic) TMRange fovRange;
//Panorama
//[right,left,down,up,front,back]
-(void)loadPanorama:(NSArray*)cube atIndex:(NSUInteger)index;
-(void)unloadPanoramaAtIndex:(NSUInteger)index;
//HotSpot
-(TMPanoramaHotSpot*)addHotSpot:(UIImage*)image x:(CGFloat)x y:(CGFloat)y z:(CGFloat)z;
-(TMPanoramaHotSpot*)addHotSpot:(UIImage*)image u:(CGFloat)u v:(CGFloat)v face:(NSInteger)face;
-(TMPanoramaHotSpot*)addHotSpot:(UIImage*)image u:(CGFloat)u v:(CGFloat)v;
-(void)hotspotTouch:(UIControl*)sender;
-(void)removeHotSpots;
@end
