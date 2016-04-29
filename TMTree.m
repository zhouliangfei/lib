//
//  TMTree.m
//  xilinmen
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 e360. All rights reserved.
//

#import "TMTree.h"

#pragma mark-
#pragma mark TMTreeNode
@interface TMTreeNode ()
@property(nonatomic, strong) NSMutableArray *childNodes;
@end
@implementation TMTreeNode
-(NSMutableArray *)childNodes{
    if (nil == _childNodes) {
        [self setChildNodes:[NSMutableArray array]];
    }
    return _childNodes;
}
-(NSArray *)nodes{
    return [NSArray arrayWithArray:self.childNodes];
}
-(TMTreeNode*)addNode:(TMTreeNode*)temp{
    @synchronized(self.childNodes) {
        if (temp && [self.childNodes indexOfObject:temp] == NSNotFound) {
            [self.childNodes addObject:temp];
            [temp setParent:self];
            return temp;
        }
        return nil;
    }
}
-(TMTreeNode*)removeNode:(TMTreeNode*)temp{
    @synchronized(self.childNodes) {
        if (temp && [self.childNodes indexOfObject:temp] != NSNotFound) {
            [self.childNodes removeObject:temp];
            [temp setParent:nil];
            return temp;
        }
        return nil;
    }
}
@end


#pragma mark-
#pragma mark TMTree
@interface TMTree () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, weak) id<TMTreeDelegate> treeDelegate;
@property(nonatomic, strong) NSMutableArray *treeNodes;
@property(nonatomic, strong) TMTreeNode *treeRootNode;
@end
@implementation TMTree
@dynamic rootNode;
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [super setAllowsMultipleSelection:YES];
        [super setDataSource:self];
        [super setDelegate:self];
    }
    return self;
}
-(NSMutableArray *)treeNodes{
    if (nil == _treeNodes) {
        [self setTreeNodes:[NSMutableArray array]];
    }
    return _treeNodes;
}
-(void)setDelegate:(id<TMTreeDelegate>)delegate{
    [self setTreeDelegate:delegate];
}
-(void)setDataSource:(id<UITableViewDataSource>)dataSource{
}
-(void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection{
}
//根节点
-(void)setRootNode:(TMTreeNode *)value{
    [self setTreeRootNode:value];
    [self.treeRootNode setExpand:YES];
    [self displayNodes];
}
-(TMTreeNode *)rootNode{
    return [self treeRootNode];
}
-(NSArray*)visibleNodes{
    return [NSArray arrayWithArray:self.treeNodes];
}
//取节点
-(TMTreeNode*)nodeAtIndex:(NSInteger)index{
    if (index<self.treeNodes.count) {
        return [self.treeNodes objectAtIndex:index];
    }
    return nil;
}
-(NSInteger)indexAtNode:(TMTreeNode*)node{
    if (node) {
        return [self.treeNodes indexOfObject:node];
    }
    return NSNotFound;
}
//节点树
-(NSArray*)treeWithNode:(TMTreeNode*)node{
    if (node) {
        NSMutableArray *tree=[NSMutableArray array];
        while (nil!=node.parent) {
            [tree insertObject:node atIndex:0];
            node=node.parent;
        }
        return tree;
    }
    return nil;
}
//展开节点
-(void)expandAll{
    [self expand:self.treeRootNode child:YES];
}
-(void)expand:(TMTreeNode*)node{
    [self expand:node child:NO];
}
-(void)expand:(TMTreeNode*)node child:(BOOL)child{
    if (node) {
        TMTreeNode *top = node;
        while (nil != top) {
            if (top.nodes.count == 0) {
                [top setExpand: NO];
            }else{
                [top setExpand:YES];
            }
            top = top.parent;
        }
        if (node.nodes.count > 0 && child) {
            for (TMTreeNode *item in node.nodes) {
                [self expand:item child:child];
            }
        }
    }
}
//关闭节点
-(void)collapseAll{
    [self collapse:self.treeRootNode child:YES];
}
-(void)collapse:(TMTreeNode*)node{
    [self collapse:node child:NO];
}
-(void)collapse:(TMTreeNode*)node child:(BOOL)child{
    if (node) {
        [node setExpand:NO];
        if (node.nodes.count > 0 && child) {
            for (TMTreeNode *item in node.nodes) {
                [self collapse:item child:child];
            }
        }
    }
}
//有效节点
-(NSArray*)effectiveNodes:(TMTreeNode*)node{
    NSMutableArray *child=[NSMutableArray array];
    if (node.expand) {
        for (TMTreeNode *item in node.nodes) {
            [child addObject:item];
            [child addObjectsFromArray:[self effectiveNodes:item]];
        }
    }
    return child;
}
-(void)displayNodes{
    if (self.visibleCells.count == 0) {
        [self.treeNodes removeAllObjects];
        [self.treeNodes addObjectsFromArray:[self effectiveNodes:self.treeRootNode]];
        [self reloadData];
    }else{
        NSArray *oldCells = [NSArray arrayWithArray:self.treeNodes];
        NSArray *newCells = [self effectiveNodes:self.treeRootNode];
        //删除无效数据
        [self.treeNodes removeAllObjects];
        NSMutableArray *delIndexPaths = [NSMutableArray array];
        for (uint i=0; i<oldCells.count; i++) {
            TMTreeNode *node = [oldCells objectAtIndex:i];
            if (NO == [newCells containsObject:node]) {
                [delIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }else{
                [self.treeNodes addObject:node];
            }
        }
        if (delIndexPaths.count > 0) {
            [self deleteRowsAtIndexPaths:delIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        //插入新数据
        [self.treeNodes removeAllObjects];
        NSMutableArray *addIndexPaths = [NSMutableArray array];
        for (uint i=0; i<newCells.count; i++) {
            TMTreeNode *node = [newCells objectAtIndex:i];
            if (NO == [oldCells containsObject:node]) {
                [addIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [self.treeNodes addObject:node];
        }
        if (addIndexPaths.count > 0) {
            [self insertRowsAtIndexPaths:addIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    //显示状态
    for (NSInteger i=0; i<self.treeNodes.count; i++) {
        TMTreeNode *item = [self.treeNodes objectAtIndex:i];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if (item.select || item.expand) {
            [self selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }else{
            [self deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.treeDelegate respondsToSelector:@selector(treeView:didSelectRowAtIndex:)]) {
        [self.treeDelegate treeView:self didSelectRowAtIndex:indexPath.row];
    }else{
        TMTreeNode *node = [self nodeAtIndex:indexPath.row];
        if (node && node.expand == NO) {
            [self expand:node child:NO];
        }
    }
    [self displayNodes];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.treeDelegate respondsToSelector:@selector(treeView:didDeselectRowAtIndex:)]) {
        [self.treeDelegate treeView:self didDeselectRowAtIndex:indexPath.row];
    }else{
        TMTreeNode *node = [self nodeAtIndex:indexPath.row];
        if (node && node.expand == YES) {
            [self collapse:node child:NO];
        }
    }
    [self displayNodes];
}
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.indentation != 0) {
        TMTreeNode *item = [self nodeAtIndex:indexPath.row];
        return item.level * self.indentation / 10;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.treeDelegate respondsToSelector:@selector(treeView:heightForRowAtIndex:)]) {
        return [self.treeDelegate treeView:self heightForRowAtIndex:indexPath.row];
    }
    return tableView.rowHeight;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([self.treeDelegate respondsToSelector:@selector(treeViewTitleForHeader:)]) {
        return [self.treeDelegate treeViewTitleForHeader:self];
    }
    return nil;
}
//
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.treeNodes.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.treeDelegate treeView:self cellForRowAtIndex:indexPath.row];
}
@end
