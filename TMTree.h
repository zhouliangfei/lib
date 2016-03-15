//
//  TMTree.h
//  xilinmen
//
//  Created by mac on 15/2/10.
//  Copyright (c) 2015年 e360. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark-
#pragma mark UITreeDelegate
@class TMTree;
@protocol UITreeDelegate <UITableViewDelegate>
@required
-(UITableViewCell *)treeView:(TMTree *)treeView cellForRowAtIndex:(NSInteger)index;

@optional
-(CGFloat)treeView:(TMTree *)treeView heightForRowAtIndex:(NSInteger)index;
-(void)treeView:(TMTree *)treeView didDeselectRowAtIndex:(NSInteger)index;
-(void)treeView:(TMTree *)treeView didSelectRowAtIndex:(NSInteger)index;
-(id)treeViewTitleForHeader:(TMTree *)treeView;
@end


#pragma mark-
#pragma mark TMTreeNode
@interface TMTreeNode : NSObject{
    NSMutableArray *_nodes;
}
@property(nonatomic,retain) id value;
@property(nonatomic,readonly) NSArray *nodes;
@property(nonatomic,retain) TMTreeNode *parent;
@property(nonatomic,retain) NSString *label;
@property(nonatomic,assign) NSInteger idetify;
@property(nonatomic,assign) NSInteger level;
@property(nonatomic,assign) BOOL select;
@property(nonatomic,assign) BOOL expand;
-(TMTreeNode*)addNode:(TMTreeNode*)nodes;
@end


#pragma mark-
#pragma mark TMTree
@interface TMTree : UITableView{
    NSMutableArray *_treeNodes;
}
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

