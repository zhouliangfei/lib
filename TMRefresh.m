//
//  TMRefresh.m
//  cutter
//
//  Created by mac on 15/5/23.
//  Copyright © 2015年 e360. All rights reserved.
//

#import "TMRefresh.h"
#import <objc/runtime.h>

@interface TMRefresh () {
    UIControlState _state;
}
@property(nonatomic, assign) TMRefreshType type;
@property(nonatomic, strong) UILabel *title;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;
@property(nonatomic, strong) NSMutableDictionary *titles;
@property(nonatomic, assign) UIEdgeInsets originalInset;
@property(nonatomic, assign) UIEdgeInsets scrollInset;
@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, assign) CGPoint scrollOffset;
@end
@implementation TMRefresh
- (instancetype)initWithType:(TMRefreshType)type{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setEnabled:NO];
        [self setUserInteractionEnabled:NO];
        //
        [self setIndicator:[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray]];
        [self.indicator setHidesWhenStopped:NO];
        [self addSubview:self.indicator];
        //
        [self setTitle:[[UILabel alloc] initWithFrame:CGRectZero]];
        [self.title setFont:[UIFont boldSystemFontOfSize:10]];
        [self.title setTextColor:[UIColor darkGrayColor]];
        [self addSubview:self.title];
        //
        [self setType:type];
    }
    return self;
}
- (void)dealloc{
    [self removeObserver];
}
- (void)willMoveToSuperview:(nullable UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
    //
    [self removeObserver];
    [self setScrollView:nil];
    if ([newSuperview isKindOfClass:UIScrollView.class]) {
        [self setScrollView:(UIScrollView*)newSuperview];
        if (self.scrollView.alwaysBounceVertical == YES) {
            [self setNeedsLayout];
            [self addObserver];
        }
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    //
    static CGFloat height = 60.f;
    if (self.type == TMRefreshTypeHeader) {
        [self setFrame:CGRectMake(0, 0 - height, self.scrollView.frame.size.width, height)];
    }else{
        [self setHidden:(self.scrollView.frame.size.height > self.scrollView.contentSize.height)];
        [self setFrame:CGRectMake(0, MAX(self.scrollView.frame.size.height, self.scrollView.contentSize.height), self.scrollView.frame.size.width, height)];
    }
    //
    CGFloat th = self.title.bounds.size.height;
    CGFloat ih = self.indicator.bounds.size.height;
    CGFloat tx = (self.scrollView.bounds.size.width * 0.5);
    CGFloat ty = (height - th - ih) * 0.5;
    //
    [self.indicator setCenter:CGPointMake(tx, ty + ih * 0.5)];
    [self.title setCenter:CGPointMake(tx, ty + ih + th * 0.5)];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (self.scrollView.scrollEnabled == NO) {
        return;
    }
    if ([keyPath isEqualToString:@"contentSize"]){
        [self setNeedsLayout];
    }else{
        if (self.state != UIControlStateSelected) {
            CGFloat ty = 0;
            CGFloat th = 0;
            CGFloat bh = 0;
            CGFloat tl = 0;
            if (self.type == TMRefreshTypeHeader) {
                ty = 0 - self.scrollView.contentOffset.y;
                if (ty < 0) {
                    return;
                }
                th = self.bounds.size.height;
                tl = MIN(1, MAX(0, ty / th));
            }else{
                ty = self.scrollView.contentOffset.y - MAX(self.scrollView.contentSize.height - self.scrollView.frame.size.height, 0);
                if (ty < 0) {
                    return;
                }
                bh = self.bounds.size.height;
                tl = MIN(1, MAX(0, ty / bh));
            }
            if (tl < 1) {
                [self.indicator setTransform:CGAffineTransformMakeRotation(tl * M_PI * 2)];
                [self setState:UIControlStateNormal];
            }else{
                if ([keyPath isEqualToString:@"state"] && [[change valueForKey:NSKeyValueChangeNewKey] integerValue] == UIGestureRecognizerStateEnded) {
                    [self setOriginalInset:self.scrollView.contentInset];
                    [self setScrollInset:UIEdgeInsetsMake(self.originalInset.top + th, self.originalInset.left, self.originalInset.bottom + bh, self.originalInset.right)];
                    [self setState:UIControlStateSelected];
                }else{
                    if (self.scrollView.isTracking && self.scrollView.isDragging) {
                        [self.indicator setTransform:CGAffineTransformMakeRotation(tl * M_PI * 2)];
                        [self setState:UIControlStateDisabled];
                    }
                }
            }
        }
    }
}
- (void)setState:(UIControlState)state{
    if (_state != state || self.title.text.length == 0) {
        _state = state;
        //
        NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)state];
        [self.title setText:[NSString stringWithFormat:@"%@",[self.titles objectForKey:key]]];
        [self.title sizeToFit];
        [self layoutSubviews];
        //
        if (self.hidden == NO && self.scrollView.scrollEnabled) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}
-(UIControlState)state{
    return _state;
}
//
- (BOOL)refreshing{
    return self.state == UIControlStateSelected;
}
- (void)beginRefreshing{
    [UIView beginAnimations:nil context:nil];
    [self.scrollView setContentInset:self.scrollInset];
    [UIView commitAnimations];
    //
    [self.indicator startAnimating];
    [self.scrollView setScrollEnabled:NO];
    if (self.type == TMRefreshTypeHeader) {
        [self setScrollOffset:CGPointMake(self.scrollView.contentOffset.x, 0)];
    }else{
        [self setScrollOffset:self.scrollView.contentOffset];
    }
}
- (void)endRefreshing{
    [self setState:UIControlStateNormal];
    //
    [NSThread sleepForTimeInterval:1];
    [UIView beginAnimations:nil context:nil];
    [self.scrollView setContentInset:self.originalInset];
    [self.scrollView setContentOffset:self.scrollOffset animated:NO];
    [UIView commitAnimations];
    //
    [self.scrollView setScrollEnabled:YES];
    [self.indicator stopAnimating];
}
//
- (void)addObserver{
    [self.scrollView.panGestureRecognizer addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [self setScrollInset:self.scrollView.contentInset];
}
- (void)removeObserver{
    [self.scrollView.panGestureRecognizer removeObserver:self forKeyPath:@"state"];
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self.scrollView removeObserver:self forKeyPath:@"contentSize"];
    [self setScrollInset:UIEdgeInsetsZero];
}
- (void)setTitle:(nullable NSString *)title forState:(TMRefreshState)state{
    NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)state];
    [self.titles setValue:title forKey:key];
    [self setNeedsLayout];
}
- (NSMutableDictionary *)titles{
    if (_titles == nil) {
        [self setTitles:[NSMutableDictionary dictionary]];
    }
    return _titles;
}
@end


@implementation UIScrollView (TMRefresh)
@dynamic headerView,footerView;
static const void *scrollViewHeaderView = "scrollViewHeaderView";
static const void *scrollViewFooterView = "scrollViewFooterView";
-(TMRefresh *)headerView{
    TMRefresh *_header = objc_getAssociatedObject(self, scrollViewHeaderView);
    if (nil == _header) {
        _header = [[TMRefresh alloc] initWithType:TMRefreshTypeHeader];
        objc_setAssociatedObject(self, scrollViewHeaderView, _header, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    if (_header.superview != self) {
        [self addSubview:_header];
    }
    return _header;
}
-(TMRefresh *)footerView{
    TMRefresh *_footer = objc_getAssociatedObject(self, scrollViewFooterView);
    if (nil == _footer) {
        _footer = [[TMRefresh alloc] initWithType:TMRefreshTypeFooter];
        objc_setAssociatedObject(self, scrollViewFooterView, _footer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
    }
    if (_footer.superview != self) {
        [self addSubview:_footer];
    }
    return _footer;
}
@end