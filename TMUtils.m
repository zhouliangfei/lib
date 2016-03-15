//
//  Utils+Category.m
//
//
//  Created by 周良飞 on 15/5/5.
//  Copyright (c) 2015年 e360. All rights reserved.
//
#import "TMUtils.h"

#pragma mark-
#pragma mark TMUtils
@interface TMAlertController : UIAlertController
@end;
@implementation TMAlertController
-(void)viewDidLoad{
    [super viewDidLoad];
    [self resetCorner:self.view];
}
-(void)resetCorner:(UIView*)view{
    for (UIView *v in view.subviews) {
        if (v.layer.cornerRadius > 8) {
            [v.layer setCornerRadius:8];
        }
        [self resetCorner:v];
    }
}
@end;

@implementation TMUtils
+(UIAlertController*)showMessage:(NSString*)message title:(NSString*)title buttons:(NSArray*)buttons handler:(void (^)(UIAlertAction *action))handler{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (window) {
        UIAlertController *alert = [TMAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        for (NSString *label in buttons) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:label style:UIAlertActionStyleDefault handler:handler];
            if (action) {
                [alert addAction:action];
            }
        }
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
        return alert;
    }
    return nil;
}
@end


//
@implementation TMAlert
+(void)showAtView:(UIView*)view image:(NSString*)image{
    TMAlert *alert = [[TMAlert alloc] initWithFrame:CGRectZero];
    [alert.imageView setImage:[UIImage imageNamed:image]];
    [alert showAtView:view];
}
+(void)hiddenAtView:(UIView*)view{
    for (TMAlert *subview in view.subviews.reverseObjectEnumerator) {
        if ([subview isKindOfClass:self.class]) {
            [subview hiddenAtView:view];
        }
    }
}
//
-(void)showAtView:(UIView*)view{
    [self sizeToFit];
    [self setAlpha:0];
    [self setCenter:CGPointMake(CGRectGetMidX(view.bounds), CGRectGetMidY(view.bounds) * 0.9 - 20)];
    [view addSubview:self];
    //
    __weak TMAlert *this = self;
    [UIView animateWithDuration:0.2 animations:^{
        [this setAlpha:1];
        [this setCenter:CGPointMake(this.center.x, this.center.y + 20)];
    } completion:^(BOOL finished) {
        [this performSelector:@selector(hiddenAtView:) withObject:view afterDelay:2];
    }];
}
-(void)hiddenAtView:(UIView*)view{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    //
    __weak TMAlert *this = self;
    [UIView animateWithDuration:0.2 animations:^{
        [this setAlpha:0];
        [this setCenter:CGPointMake(this.center.x, this.center.y - 20)];
    } completion:^(BOOL finished) {
        [this removeFromSuperview];
    }];
}
//
-(UIImageView *)imageView{
    if (_imageView == nil) {
        [self setImageView:[[UIImageView alloc] initWithFrame:CGRectZero]];
        [self addSubview:self.imageView];
    }
    return _imageView;
}
-(CGSize)sizeThatFits:(CGSize)size{
    [self.imageView sizeToFit];
    return self.imageView.bounds.size;
}
-(BOOL)pointInside:(CGPoint)point withEvent:(nullable UIEvent *)event{
    return YES;
}
@end