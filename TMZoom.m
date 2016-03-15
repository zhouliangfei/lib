//
//  TMZoom.m
//  cutter
//
//  Created by mac on 16/1/20.
//  Copyright © 2016年 e360. All rights reserved.
//

#import "TMZoom.h"

@implementation TMZoom
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self addSubview:self.imageView];
        [super setDelegate:self];
    }
    return self;
}
-(void)setDelegate:(id<UIScrollViewDelegate>)delegate{
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (CGSizeEqualToSize(self.imageView.bounds.size, self.bounds.size) == NO) {
        [self.imageView setBounds:self.bounds];
        [self scrollViewDidZoom:self];
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesBegan:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesMoved:touches withEvent:event];
    [super touchesMoved:touches withEvent:event];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self nextResponder] touchesEnded:touches withEvent:event];
    [super touchesEnded:touches withEvent:event];
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [[self nextResponder] touchesCancelled:touches withEvent:event];
    [super touchesCancelled:touches withEvent:event];
}
//
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (self.zoomScale <= 1.0) {
        CGFloat cx = CGRectGetMidX(self.bounds);
        CGFloat cy = CGRectGetMidY(self.bounds);
        [self.imageView setCenter:CGPointMake(cx, cy)];
    }
}
-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}
-(UIImageView *)imageView{
    if (_imageView == nil) {
        [self setImageView:[[UIImageView alloc] initWithFrame:self.bounds]];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    return _imageView;
}
@end
