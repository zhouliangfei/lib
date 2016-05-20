//
//  TMRefresh.m
//  cutter
//
//  Created by mac on 15/5/23.
//  Copyright © 2015年 e360. All rights reserved.
//

#import "TMRefresh.h"
#import <objc/runtime.h>

@interface TMRefresh ()
@property(nonatomic, strong) UILabel *title;
@property(nonatomic, strong) UIActivityIndicatorView *indicator;
@property(nonatomic, strong) NSMutableDictionary *titles;
@property(nonatomic, strong) UIScrollView *scrollView;
//
@property(nonatomic, assign) UIEdgeInsets originalInset;
@property(nonatomic, assign) UIEdgeInsets scrollInset;
@property(nonatomic, assign) CGPoint originalOffset;
@property(nonatomic, assign) TMRefreshType type;
@property(nonatomic, assign) NSInteger current;
@property(nonatomic, assign) BOOL refresh;
@end
@implementation TMRefresh
- (instancetype)initWithType:(TMRefreshType)type{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setType:type];
        [self setEnabled:YES];
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
            [self layoutIfNeeded];
            [self addObserver];
        }
    }
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (self.enabled) {
        static CGFloat height = 60.f;
        if (self.type == TMRefreshTypeHeader) {
            [self setFrame:CGRectMake(0, 0 - height, self.scrollView.bounds.size.width, height)];
        }else{
            [self setFrame:CGRectMake(0, MAX(self.scrollView.bounds.size.height, self.scrollView.contentSize.height), self.scrollView.bounds.size.width, height)];
        }
        //
        CGFloat th = self.title.bounds.size.height;
        CGFloat ih = self.indicator.bounds.size.height;
        CGFloat cx = self.scrollView.bounds.size.width * 0.5;
        CGFloat ty = (height - th - ih) * 0.5;
        //
        [self.indicator setCenter:CGPointMake(cx, ty + ih * 0.5)];
        [self.title setCenter:CGPointMake(cx, ty + ih + th * 0.5)];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if (self.isRefreshing == YES) {
        return;
    }
    if ([keyPath isEqualToString:@"contentSize"]){
        [self layoutIfNeeded];
        return;
    }
    //
    CGFloat ty = 0;
    if (self.type == TMRefreshTypeHeader) {
        ty = 0 - self.scrollView.contentOffset.y;
    }else{
        ty = self.scrollView.contentOffset.y - MAX(self.scrollView.contentSize.height - self.scrollView.frame.size.height, 0);
    }
    if (ty < 0) {
        return;
    }
    //
    ty = MIN(1, MAX(0, ty / self.bounds.size.height));
    if (ty < 1) {
        [self.indicator setTransform:CGAffineTransformMakeRotation(ty * M_PI * 2)];
        [self updataTitle:TMRefreshStatePulling];
    }else{
        if ([keyPath isEqualToString:@"state"] && [[change valueForKey:NSKeyValueChangeNewKey] integerValue] == UIGestureRecognizerStateEnded) {
            [self beginRefreshing];
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }else{
            if (self.scrollView.isTracking && self.scrollView.isDragging) {
                [self.indicator setTransform:CGAffineTransformMakeRotation(ty * M_PI * 2)];
                [self updataTitle:TMRefreshStateNormal];
            }
        }
    }
}
-(void)setEnabled:(BOOL)enabled{
    [super setEnabled:NO];
    if (self.type == TMRefreshTypeFooter) {
        [self setHidden:!enabled];
    }else{
        [self setHidden:NO];
    }
}
-(BOOL)isEnabled{
    return !self.hidden;
}
//
-(BOOL)isRefreshing{
    return self.refresh;
}
- (void)updataTitle:(TMRefreshState)state{
    if (self.current != state) {
        [self setCurrent:state];
        //
        NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)state];
        [self.title setText:[NSString stringWithFormat:@"%@",[self.titles objectForKey:key]]];
        [self.title sizeToFit];
    }
    [self layoutIfNeeded];
}
-(void)beginRefreshing{
    if (self.refresh == NO) {
        [self setRefresh:YES];
        [self updataTitle:TMRefreshStateRefreshing];
        //
        if (self.type == TMRefreshTypeHeader) {
            UIEdgeInsets insets = self.originalInset;
            [self setScrollInset:UIEdgeInsetsMake(insets.top + self.bounds.size.height, insets.left, insets.bottom, insets.right)];
        }else{
            UIEdgeInsets insets = self.originalInset;
            [self setScrollInset:UIEdgeInsetsMake(insets.top, insets.left, insets.bottom + self.bounds.size.height, insets.right)];
        }
        //
        [self.indicator startAnimating];
        [self.scrollView setScrollEnabled:NO];
        [UIView beginAnimations:nil context:nil];
        [self.scrollView setContentInset:self.scrollInset];
        [UIView commitAnimations];
        //
        [self setOriginalOffset:self.scrollView.contentOffset];
    }
}
- (void)endRefreshing{
    [NSThread sleepForTimeInterval:1];
    if (self.refresh == YES) {
        [self setRefresh:NO];
        [self updataTitle:TMRefreshStateNormal];
        //
        [self.indicator stopAnimating];
        [self.scrollView setScrollEnabled:YES];
        if (self.type == TMRefreshTypeFooter && self.enabled == YES) {
            [UIView beginAnimations:nil context:nil];
            [self.scrollView setContentInset:self.originalInset];
            [self.scrollView setContentOffset:self.originalOffset];
            [UIView commitAnimations];
        }else{
            [UIView beginAnimations:nil context:nil];
            [self.scrollView setContentInset:self.originalInset];
            [UIView commitAnimations];
        }
    }
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
- (void)setTitle:(NSString *)title forState:(TMRefreshState)state{
    NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)state];
    [self.titles setValue:title forKey:key];
    [self updataTitle:self.current];
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
static const void *scrollViewHeaderView = "scrollView.headerView";
static const void *scrollViewFooterView = "scrollView.footerView";
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
