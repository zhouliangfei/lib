//
//  UITreeView.m
//  lib
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 e360. All rights reserved.
//

#import "UITreeView.h"

#pragma mark-
#pragma mark UITreeNode
@implementation UITreeNode
-(instancetype)init{
    self=[super init];
    if (self) {
        _nodes=[[NSMutableArray alloc] init];
        _parent=nil;
    }
    return self;
}
-(NSArray *)nodes{
    return [NSArray arrayWithArray:_nodes];
}
-(void)dealloc{
    [_parent release];
    [_nodes release];
    [_label release];
    [super dealloc];
}
-(UITreeNode*)addNode:(UITreeNode*)temp{
    [_nodes addObject:temp];
    [temp setParent:self];
    return temp;
}
@end


#pragma mark-
#pragma mark UITreeView
@interface UITreeView()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign) id<UITreeDelegate> treeDelegate;
@property(nonatomic,retain) UITreeNode *treeRootNode;
@end
@implementation UITreeView
@dynamic rootNode;
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _treeNodes=[[NSMutableArray alloc] init];
        //
        [super setAllowsMultipleSelection:YES];
        [super setDataSource:self];
        [super setDelegate:self];
    }
    return self;
}
-(void)dealloc{
    [_treeRootNode release];
    [_treeNodes release];
    [super dealloc];
}
-(void)setDelegate:(id<UITreeDelegate>)delegate{
    [self setTreeDelegate:delegate];
}
-(void)setDataSource:(id<UITableViewDataSource>)dataSource{
}
-(void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection{
}
//根节点
-(void)setRootNode:(UITreeNode *)value{
    [self setTreeRootNode:value];
    [_treeRootNode setExpand:YES];
    [self displayNodes];
}
-(UITreeNode *)rootNode{
    return [self treeRootNode];
}
-(NSArray*)visibleNodes{
    return [NSArray arrayWithArray:_treeNodes];
}
//取节点
-(UITreeNode*)nodeAtIndex:(NSInteger)index{
    if (index<_treeNodes.count) {
        return [_treeNodes objectAtIndex:index];
    }
    return nil;
}
-(NSInteger)indexAtNode:(UITreeNode*)node{
    if (node) {
        return [_treeNodes indexOfObject:node];
    }
    return NSNotFound;
}
//节点树
-(NSArray*)treeWithNode:(UITreeNode*)node{
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
    [self expand:_treeRootNode child:YES];
}
-(void)expand:(UITreeNode*)node{
    [self expand:node child:NO];
}
-(void)expand:(UITreeNode*)node child:(BOOL)child{
    if (node) {
        //取消选择
        for (UITreeNode *item in _treeNodes) {
            [item setSelect:NO];
        }
        //展开父级树
        UITreeNode *top=node;
        while (nil!=top.parent) {
            if (top.nodes.count==0) {
                [top setSelect:YES];
                [top setExpand: NO];
            }else{
                [top setSelect:YES];
                [top setExpand:YES];
            }
            top=top.parent;
        }
        //
        if (node.nodes.count==0) {
            [node setSelect:YES];
            [node setExpand: NO];
        }else{
            [node setSelect:YES];
            [node setExpand:YES];
            //
            if (child) {
                for (UITreeNode *item in node.nodes) {
                    [self expand:item child:child];
                }
            }
        }
    }
}
//关闭节点
-(void)collapseAll{
    [self collapse:_treeRootNode child:YES];
}
-(void)collapse:(UITreeNode*)node{
    [self collapse:node child:NO];
}
-(void)collapse:(UITreeNode*)node child:(BOOL)child{
    if (node) {
        [node setSelect:NO];
        [node setExpand:NO];
        //
        if (child) {
            for (UITreeNode *item in node.nodes) {
                [self collapse:item child:child];
            }
        }
    }
}
//有效节点
-(NSArray*)effectiveNodes:(UITreeNode*)node{
    NSMutableArray *child=[NSMutableArray array];
    if (node.expand) {
        for (UITreeNode *item in node.nodes) {
            [child addObject:item];
            [child addObjectsFromArray:[self effectiveNodes:item]];
        }
    }
    return child;
}
-(void)displayNodes{
    if (self.visibleCells.count==0) {
        [_treeNodes removeAllObjects];
        [_treeNodes addObjectsFromArray:[self effectiveNodes:_treeRootNode]];
        [self reloadData];
    }else{
        NSArray *oldCells=[NSArray arrayWithArray:_treeNodes];
        NSArray *newCells=[self effectiveNodes:_treeRootNode];
        //删除无效数据
        [_treeNodes removeAllObjects];
        NSMutableArray *delIndexPaths=[NSMutableArray array];
        for (uint i=0;i<oldCells.count;i++) {
            UITreeNode *node=[oldCells objectAtIndex:i];
            if (NO==[newCells containsObject:node]) {
                [delIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }else{
                [_treeNodes addObject:node];
            }
        }
        if (delIndexPaths.count>0) {
            [self deleteRowsAtIndexPaths:delIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
        //插入新数据
        [_treeNodes removeAllObjects];
        NSMutableArray *addIndexPaths=[NSMutableArray array];
        for (uint i=0; i<newCells.count; i++) {
            UITreeNode *node=[newCells objectAtIndex:i];
            if (NO==[oldCells containsObject:node]) {
                [addIndexPaths addObject:[NSIndexPath indexPathForItem:i inSection:0]];
            }
            [_treeNodes addObject:node];
        }
        if (addIndexPaths.count>0) {
            [self insertRowsAtIndexPaths:addIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
    //显示状态
    for (NSInteger i=0;i<_treeNodes.count;i++) {
        UITreeNode *item=[_treeNodes objectAtIndex:i];
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:i inSection:0];
        if (item.select) {
            [self selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }else{
            [self deselectRowAtIndexPath:indexPath animated:NO];
        }
    }
}
//
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITreeNode *node=[self nodeAtIndex:indexPath.row];
    if (node) {
        if (node.expand || node.select) {
            [self tableView:tableView didDeselectRowAtIndexPath:indexPath];
        }else{
            [self expand:node child:NO];
            if ([_treeDelegate respondsToSelector:@selector(treeView:didSelectRowAtIndex:)]) {
                [_treeDelegate treeView:self didSelectRowAtIndex:indexPath.row];
            }
            [self displayNodes];
        }
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITreeNode *node=[self nodeAtIndex:indexPath.row];
    if (node) {
        [self collapse:node child:NO];
        if ([_treeDelegate respondsToSelector:@selector(treeView:didDeselectRowAtIndex:)]) {
            [_treeDelegate treeView:self didDeselectRowAtIndex:indexPath.row];
        }
        [self displayNodes];
    }
}
-(NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_indentation!=0) {
        UITreeNode *item=[self nodeAtIndex:indexPath.row];
        return item.level*_indentation/10;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _treeNodes.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([_treeDelegate respondsToSelector:@selector(treeView:heightForRowAtIndex:)]) {
        return [_treeDelegate treeView:self heightForRowAtIndex:indexPath.row];
    }
    return 42.0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[_treeDelegate treeView:self cellForRowAtIndex:indexPath.row];
    return cell;
}
@end
