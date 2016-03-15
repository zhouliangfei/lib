//
//  TMPanorama.m
//  panorama
//
//  Created by 周良飞 on 15/5/30.
//  Copyright (c) 2015年 tinymedia. All rights reserved.
//
#import "TMPanorama.h"

//
//
TMRange TMMakeRange(GLfloat start, GLfloat end) {
    return (TMRange){.start = start,.end = end};
}

//
//
#pragma mark-
#pragma mark TMPanoramaHotSpot
@implementation TMPanoramaHotSpot
@end

//
//
#pragma mark-
#pragma mark PanoramaViewController
@interface TMPanorama(){
    GLKMatrix4 projectionMatrix;
    GLKMatrix4 modelViewMatrix;
    GLKMatrix4 modelMatrix;
    GLKMatrix4 viewMatrix;
    //
    GLfloat fov;//视场
    GLfloat yaw;//是围绕Y轴旋转，也叫偏航角
    GLfloat roll;//是围绕Z轴旋转，也叫翻滚角
    GLfloat pitch;//是围绕X轴旋转，也叫做俯仰角
    GLfloat speed;
}
@property (strong, nonatomic) NSMutableDictionary *panorama;
@property (strong, nonatomic) NSMutableArray *hotSpot;
@property (strong, nonatomic) EAGLContext *context;
@end
//
@implementation TMPanorama
@synthesize pitchRange,rollRange,yawRange,fovRange;
-(void)viewDidLoad {
    [super viewDidLoad];
    //
    if([self setupGL]){
        pitchRange = TMMakeRange(-90,90);
        rollRange = TMMakeRange(0,0);
        yawRange = TMMakeRange(-180,180);
        fovRange = TMMakeRange(10,120);
        speed = 0.1;
        fov = 60;
    }
}
-(void)dealloc{
    [self deleteGL];
}
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    //清空
    glClearColor(1.0 ,1.0 ,1.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    //开启深度测试
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LEQUAL);
    //开启透明混合
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //显示全景
    NSArray *keys = [self.panorama.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSInteger i = 0; i < keys.count; i++) {
        GLKSkyboxEffect *skybox = [self.panorama objectForKey:[keys objectAtIndex:i]];
        [skybox prepareToDraw];
        [skybox draw];
    }
    //关闭深度测试,透明混合
    glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    //
    //更新热点
    int viewport[] = {0,0,self.view.bounds.size.width,self.view.bounds.size.height};
    for (TMPanoramaHotSpot *hotSpot in self.hotSpot) {
        GLKVector3 point = GLKVector3Make(hotSpot.x, hotSpot.y, hotSpot.z);
        GLKVector3 screenPoint = GLKMathProject(point ,modelViewMatrix ,projectionMatrix, viewport);
        if (isnan(screenPoint.x) || isnan(screenPoint.y)) {
            [hotSpot setHidden:YES];
        }else{
            [hotSpot setCenter:CGPointMake(screenPoint.x, self.view.bounds.size.height - screenPoint.y)];
            [hotSpot setHidden:screenPoint.z > 1];
        }
    }
}
//
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;{
    if(touches.count == 2){
        UITouch *ta = [[touches allObjects] objectAtIndex:0];
        UITouch *tb = [[touches allObjects] objectAtIndex:1];
        //
        CGPoint ca = [ta locationInView:self.view];
        CGPoint pa = [ta previousLocationInView:self.view];
        CGPoint cb = [tb locationInView:self.view];
        CGPoint pb = [tb previousLocationInView:self.view];
        //
        GLfloat px = pa.x - pb.x;
        GLfloat py = pa.y - pb.y;
        GLfloat cx = ca.x - cb.x;
        GLfloat cy = ca.y - cb.y;
        //
        GLfloat pd = sqrtf(px * px + py * py);
        GLfloat cd = sqrtf(cx * cx + cy * cy);
        if (cd > 0) {
            fov *= pd / cd;
        }
        //
        GLfloat ra = atan2(py, px);
        GLfloat rb = atan2(cy, cx);
        roll += GLKMathRadiansToDegrees(rb - ra);
    }else{
        CGPoint ca = [[touches anyObject] locationInView:self.view];
        CGPoint pa = [[touches anyObject] previousLocationInView:self.view];
        //
        pitch -= (ca.y - pa.y) * speed;
        yaw -= (pa.x - ca.x) * speed;
    }
    //修正数据
    if (pitchRange.end - pitchRange.start < 360) {
        pitch = MAX(pitchRange.start, MIN(pitchRange.end, pitch));
    }
    if (rollRange.end - rollRange.start < 360) {
        roll = MAX(rollRange.start, MIN(rollRange.end, yaw));
    }
    if (yawRange.end-  yawRange.start < 360) {
        yaw = MAX(yawRange.start, MIN(yawRange.end, yaw));
    }
    fov = MAX(fovRange.start, MIN(fovRange.end, fov));
    //
    [self update];
}
//
-(BOOL)setupGL{
    self.context=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (self.context && [EAGLContext setCurrentContext:self.context]) {
        [self setPanorama:[NSMutableDictionary dictionary]];
        [self setHotSpot:[NSMutableArray array]];
        //
        GLKView *view = (GLKView *)self.view;
        [view setDrawableDepthFormat:GLKViewDrawableDepthFormat24];
        [view setDrawableMultisample:GLKViewDrawableMultisample4X];
        [view setContext:self.context];
        [view setOpaque:YES];
        return YES;
    }
    return NO;
}
-(void)deleteGL{
    if ([EAGLContext currentContext]==self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    [self setContext:nil];
    //
    for (GLKSkyboxEffect *panorama in self.panorama.allValues) {
        [self deleteTextureCubeMapAtSkyboxEffect:panorama];
    }
    [self setPanorama:nil];
    [self setHotSpot:nil];
}
-(void)update{
    GLKMatrix4 xRotations = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(pitch));
    GLKMatrix4 yRotations = GLKMatrix4MakeYRotation(GLKMathDegreesToRadians(yaw));
    GLKMatrix4 zRotations = GLKMatrix4MakeZRotation(GLKMathDegreesToRadians(roll));
    //
    viewMatrix = GLKMatrix4MakeLookAt(0, 0, 0, 0, 0, 1, 0, -1, 0);
    modelMatrix = GLKMatrix4Multiply(GLKMatrix4Multiply(xRotations ,yRotations),zRotations);
    modelViewMatrix = GLKMatrix4Multiply(viewMatrix, modelMatrix);
    //
    CGFloat aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(fov), aspect, 0.1f, 120.0f);
    //
    for (GLKSkyboxEffect *panorama in self.panorama.allValues) {
        panorama.transform.projectionMatrix = projectionMatrix;
        panorama.transform.modelviewMatrix = modelViewMatrix;
    }
}
-(void)deleteTextureCubeMapAtSkyboxEffect:(GLKSkyboxEffect*)element{
    GLuint textures = element.textureCubeMap.name;
    if (textures > 0) {
        glDeleteTextures(1, &textures);
    }
}
//
-(void)loadPanorama:(NSArray*)cube atIndex:(NSUInteger)index{
    NSError *error = nil;
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft:@YES,GLKTextureLoaderApplyPremultiplication:@YES};
    GLKTextureInfo *cubemap = [GLKTextureLoader cubeMapWithContentsOfFiles:cube options:options error:&error];
    if (nil == error) {
        GLKSkyboxEffect *skybox = [self panoramaAtIndex:index];
        [self deleteTextureCubeMapAtSkyboxEffect:skybox];
        [skybox.textureCubeMap setName:cubemap.name];
        [self update];
    }
}
-(void)unloadPanoramaAtIndex:(NSUInteger)index{
    id key = [NSNumber numberWithUnsignedInteger:index];
    GLKSkyboxEffect *skybox = [self.panorama objectForKey:key];
    if (skybox) {
        [self deleteTextureCubeMapAtSkyboxEffect:skybox];
        [self.panorama removeObjectForKey:key];
    }
}
-(GLKSkyboxEffect*)panoramaAtIndex:(NSUInteger)index{
    id key = [NSNumber numberWithUnsignedInteger:index];
    id panorama = [self.panorama objectForKey:key];
    if (nil == panorama) {
        panorama = [[GLKSkyboxEffect alloc] init];
        [self.panorama setObject:panorama forKey:key];
    }
    return panorama;
}
//
//
-(TMPanoramaHotSpot*)addHotSpot:(UIImage*)image x:(CGFloat)x y:(CGFloat)y z:(CGFloat)z{
    TMPanoramaHotSpot *temp = [[TMPanoramaHotSpot alloc] initWithFrame:CGRectZero];
    [temp addTarget:self action:@selector(hotspotTouch:) forControlEvents:UIControlEventTouchUpInside];
    [temp setHidden:YES];
    [temp setX:x];
    [temp setY:y];
    [temp setZ:z];
    //
    if (image) {
        [temp setBounds:CGRectMake(0, 0, image.size.width, image.size.height)];
        [temp setImage:image forState:UIControlStateNormal];
    }
    //
    [self.hotSpot addObject:temp];
    [self.view addSubview:temp];
    [self update];
    return temp;
}
-(TMPanoramaHotSpot*)addHotSpot:(UIImage*)image u:(CGFloat)u v:(CGFloat)v face:(NSInteger)face{
    //[right,left,down,up,front,back]
    if (face==0) {
        return [self addHotSpot:image x:-1 y: v z: u];
    }
    if (face==1) {
        return [self addHotSpot:image x: 1 y: v z:-u];
    }
    if (face==2) {
        return [self addHotSpot:image x:-u y: 1 z: v];
    }
    if (face==3) {
        return [self addHotSpot:image x:-u y:-1 z:-v];
    }
    if (face==4) {
        return [self addHotSpot:image x: u y: v z: 1];
    }
    if (face==5) {
        return [self addHotSpot:image x:-u y: v z:-1];
    }
    return nil;
}
-(TMPanoramaHotSpot*)addHotSpot:(UIImage*)image u:(CGFloat)u v:(CGFloat)v{
    GLfloat a = GLKMathDegreesToRadians(u);
    GLfloat b = GLKMathDegreesToRadians(v);
    GLfloat x = sinf(a) * cosf(b);
    GLfloat z = cosf(a) * cosf(b);
    GLfloat y = -sinf(b);
    //
    return [self addHotSpot:image x:x y:y z:z];
}
-(void)removeHotSpots{
    [self.hotSpot makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.hotSpot removeAllObjects];
}
-(void)hotspotTouch:(UIControl*)sender{
}
@end