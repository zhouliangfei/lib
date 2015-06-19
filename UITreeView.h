//
//  UITreeView.h
//  lib
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 e360. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark-
#pragma mark UITreeDelegate
@class UITreeView;
@protocol UITreeDelegate <UITableViewDelegate>
@required
-(UITableViewCell *)treeView:(UITreeView *)treeView cellForRowAtIndex:(NSInteger)index;

@optional
-(CGFloat)treeView:(UITreeView *)treeView heightForRowAtIndex:(NSInteger)index;
-(void)treeView:(UITreeView *)treeView didDeselectRowAtIndex:(NSInteger)index;
-(void)treeView:(UITreeView *)treeView didSelectRowAtIndex:(NSInteger)index;
@end


#pragma mark-
#pragma mark UITreeNode
@interface UITreeNode : NSObject{
    NSMutableArray *_nodes;
}
@property(nonatomic,readonly) NSArray *nodes;
@property(nonatomic,retain) UITreeNode *parent;
@property(nonatomic,retain) NSString *label;
@property(nonatomic,assign) NSInteger idetify;
@property(nonatomic,assign) NSInteger level;
@property(nonatomic,assign) BOOL select;
@property(nonatomic,assign) BOOL expand;
-(UITreeNode*)addNode:(UITreeNode*)nodes;
@end


#pragma mark-
#pragma mark UITreeView
@interface UITreeView : UITableView{
    NSMutableArray *_treeNodes;
}
@property(nonatomic,readonly) NSArray *visibleNodes;
@property(nonatomic,retain) UITreeNode *rootNode;
@property(nonatomic,assign) CGFloat indentation;
//
-(UITreeNode*)nodeAtIndex:(NSInteger)index;
-(NSInteger)indexAtNode:(UITreeNode*)node;
-(NSArray*)treeWithNode:(UITreeNode*)node;
-(void)collapse:(UITreeNode*)node;
-(void)expand:(UITreeNode*)node;
-(void)displayNodes;
-(void)collapseAll;
-(void)expandAll;
@end

