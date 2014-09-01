//
//  SelectorView.h
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-7.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//



@class SelectorView;

@protocol SelectViewDelegate <NSObject>

@optional
-(void) didSelect:(SelectorView*)selectorView index:(NSUInteger)index;

@end




@interface SelectorView : UIView

@property (nonatomic, weak) id<SelectViewDelegate> delegate;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) NSArray* icons;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat cellHeight;
@property (readonly) CGFloat totalHeight;
@property (readonly) CGFloat borderHeight;
@property (readonly) UIImageView* bgView;

-(void) showInView:(UIView*)view;
-(void) dismiss;

@end


