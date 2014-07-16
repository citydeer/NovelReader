//
//  GridView.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-8-29.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//



@interface GridIndex : NSObject
{
@private
	NSUInteger x;
	NSUInteger y;
}

@property (readonly) NSUInteger x;
@property (readonly) NSUInteger y;

+(id) indexWithX:(NSUInteger)x Y:(NSUInteger)y;

@end



@interface GridViewCell : UIView
{
@private
	NSUInteger x;
	NSUInteger y;
	UIImageView* _imageView;
}

@property (readonly) UIImageView* imageView;

@end



@protocol GridViewDataSource;

@interface GridView : UIScrollView <UIScrollViewDelegate>
{
@private
	
	
	NSMutableSet* _visibleThumbs;
	NSMutableSet* _reusableThumbs;
	
	NSMutableSet* _selectedIndex;
	BOOL _allowsMultiSelection;
	
	CGFloat _selectedAlpha;
	CGFloat _normalAlpha;
	
	// Config image layout
	CGSize _thumbSpace;
	CGSize _thumbSize;
	NSUInteger _rowCount;
	NSUInteger _columnCount;
	UIEdgeInsets _gridsInsets;
}

@property (nonatomic, weak) id<GridViewDataSource> dataSource;
@property (readonly) NSMutableSet* selectedIndex;
@property (nonatomic, assign) CGFloat selectedAlpha;
@property (nonatomic, assign) CGFloat normalAlpha;
@property (nonatomic, assign) BOOL allowsMultiSelection;
@property (nonatomic, assign) CGSize thumbSpace;
@property (nonatomic, assign) CGSize thumbSize;
@property (nonatomic, assign) NSUInteger rowCount;
@property (nonatomic, assign) NSUInteger columnCount;
@property (nonatomic, assign) UIEdgeInsets gridsInsets;

-(void) reloadCells;
-(void) reloadCellsWithVisible:(GridIndex*)index;
-(void) reloadCellAtIndex:(GridIndex*)index;
-(void) deselectCellAtIndex:(GridIndex*)index animated:(BOOL)animated;
-(GridViewCell*) dequeueReusableCell;
-(GridViewCell*) cellAtIndex:(GridIndex*)index;
-(GridIndex*) indexOfCell:(GridViewCell*)cell;
-(NSArray*) indexOfVisibleCells;
-(void) scrollCellToVisible:(GridIndex*)index;

@end


@protocol GridViewDataSource <NSObject>

@required
-(GridViewCell*) gridView:(GridView*)gridView cellForIndex:(GridIndex*)index;

@optional
-(void) gridView:(GridView*)gridView didSelectCellAtIndex:(GridIndex*)index;
-(void) didTapOnGridViewBlankSpace:(GridView*)gridView;
-(void) gridView:(GridView*)gridView didLongTapOnCellAtIndex:(GridIndex*)index;
-(void) didStopScrolling:(GridView*)gridView;
-(void) gridViewDidEndDragging:(GridView *)gridView;

@end
