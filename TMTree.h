//
//  TMTree.h
//  xilinmen
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 e360. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark-
#pragma mark TMTreeDelegate
@class TMTree;
@protocol TMTreeDelegate <UITableViewDelegate>
@required
-(UITableViewCell *)treeView:(TMTree *)treeView cellForRowAtIndex:(NSInteger)index;

@optional
-(CGFloat)treeView:(TMTree *)treeView heightForRowAtIndex:(NSInteger)index;
-(void)treeView:(TMTree *)treeView collapseRowAtIndex:(NSInteger)index;
-(void)treeView:(TMTree *)treeView expandRowAtIndex:(NSInteger)index;
-(id)treeViewTitleForHeader:(TMTree *)treeView;
@end


#pragma mark-
#pragma mark TMTreeNode
@interface TMTreeNode : NSObject
@property(nonatomic,strong) id value;
@property(nonatomic,strong) NSArray *nodes;
@property(nonatomic,strong) TMTreeNode *parent;
@property(nonatomic,strong) NSString *label;
@property(nonatomic,assign) NSInteger idetify;
@property(nonatomic,assign) NSInteger level;
@property(nonatomic,assign) BOOL select;
@property(nonatomic,assign) BOOL expand;
-(TMTreeNode*)addNode:(TMTreeNode*)nodes;
-(TMTreeNode*)removeNode:(TMTreeNode*)temp;
@end


#pragma mark-
#pragma mark TMTree
@interface TMTree : UITableView
@property(nonatomic,assign) IBInspectable CGFloat indentation;
@property(nonatomic,readonly) NSArray *visibleNodes;
@property(nonatomic,retain) TMTreeNode *rootNode;
//
-(TMTreeNode*)nodeAtIndex:(NSInteger)index;
-(NSInteger)indexAtNode:(TMTreeNode*)node;
-(NSArray*)treeWithNode:(TMTreeNode*)node;
-(void)collapse:(TMTreeNode*)node;
-(void)expand:(TMTreeNode*)node;
-(void)displayNodes;
-(void)collapseAll;
-(void)expandAll;
@end

