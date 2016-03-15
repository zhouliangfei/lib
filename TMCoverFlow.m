//
//  UICoverFlowLayout.m
//  Topkea
//
//  Created by 周良飞 on 15/5/5.
//  Copyright (c) 2015年 e360. All rights reserved.
//

#import "TMCoverFlow.h"

@interface TMCoverFlow()
@property (nonatomic,readonly) NSInteger elementsCount;
@end
//
@implementation TMCoverFlow
@dynamic elementsCount;
-(void)prepareLayout {
    [super prepareLayout];
    [self.collectionView setDecelerationRate:UIScrollViewDecelerationRateFast];
    NSAssert(self.collectionView.numberOfSections == 1, @"TMCoverFlow: Multiple sections aren't supported!");
}
-(CGSize)collectionViewContentSize {
    return CGSizeMake(self.space * self.elementsCount + (self.collectionView.bounds.size.width - self.space), self.collectionView.bounds.size.height);
}
-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}
//
-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    //全部
    NSMutableArray *allIndexPaths=[NSMutableArray array];
    for (uint i = 0; i < self.elementsCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        [allIndexPaths addObject:indexPath];
    }
    //可视区
    CGSize size = self.collectionView.bounds.size;
    CGPoint offset = self.collectionView.contentOffset;
    CGRect visible = CGRectMake(offset.x, offset.y, size.width, size.height);
    //
    NSMutableArray *resultAttributes=[NSMutableArray array];
    for(NSIndexPath *indexPath in allIndexPaths){
        UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:indexPath];
        if (CGRectContainsRect(visible, attribute.frame) || CGRectIntersectsRect(visible, attribute.frame)) {
            [resultAttributes addObject:attribute];
        }
    }
    return [NSArray arrayWithArray:resultAttributes];
}
-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    static CGFloat radian = M_PI / 180.0;
    //属性
    UICollectionViewLayoutAttributes *attribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    [attribute setCenter:CGPointMake(indexPath.item*self.space+self.collectionView.bounds.size.width * 0.5, self.collectionView.bounds.size.height * 0.5)];
    [attribute setSize:self.itemSize];
    //中心点
    CGSize size = self.collectionView.bounds.size;
    CGPoint offset = self.collectionView.contentOffset;
    CGPoint center = CGPointMake(offset.x + size.width * 0.5, offset.y + size.height * 0.5);
    CGFloat length = attribute.center.x - center.x;
    CGFloat ratio = length / self.space;
    CGFloat scale = 1.0;
    if (ratio > 0) {
        ratio = MIN(ratio, 1.0);
        scale = 1.0 - (1.0 - self.scale) * ratio;
    }
    if (ratio < 0) {
        ratio = MAX(ratio, -1.0);
        scale = 1.0 + (1.0 - self.scale) * ratio;
    }
    //效果
    CATransform3D transform = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0.002,
        0, 0, 0, 1
    };
    transform = CATransform3DScale(transform, scale, scale, 1.0);
    transform = CATransform3DTranslate(transform, ratio * self.expand, 0.0, 0.0);
    transform = CATransform3DRotate(transform, ratio * self.degree * radian, 0.0, 1.0, 0.0);
    //
    [attribute setZIndex:(center.x - ABS(length)) * 0xFF];
    [attribute setTransform3D:transform];
    return attribute;
}
-(CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    //中点
    CGSize size = self.collectionView.bounds.size;
    CGPoint center = CGPointMake(proposedContentOffset.x + size.width * 0.5, proposedContentOffset.y + size.height * 0.5);
    CGRect visible = CGRectMake(proposedContentOffset.x, proposedContentOffset.y, size.width, size.height);
    //取差
    CGFloat difference = CGFLOAT_MAX;
    NSArray *resultAttributes = [self layoutAttributesForElementsInRect:visible];
    for(UICollectionViewLayoutAttributes *attribute in resultAttributes){
        CGFloat temp = attribute.center.x - center.x;
        if (ABS(difference) > ABS(temp)) {
            difference = temp;
        }
    }
    return CGPointMake(proposedContentOffset.x + difference, proposedContentOffset.y);
}
//
-(NSInteger)elementsCount{
    return [self.collectionView numberOfItemsInSection:0];
}
@end