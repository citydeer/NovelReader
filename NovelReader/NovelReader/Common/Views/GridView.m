//
//  GridView.m
//  Kuyun
//
//  Created by Pang Zhenyu on 11-8-29.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "GridView.h"



@implementation GridIndex

@synthesize x, y;

+(id) indexWithX:(NSUInteger)x Y:(NSUInteger)y
{
	GridIndex* ret = [[GridIndex alloc] init];
	ret->x = x;
	ret->y = y;
	return ret;
}

-(BOOL) isEqual:(id)object
{
	if ([object isKindOfClass:[GridIndex class]])
	{
		return ((GridIndex*)object).x == x && ((GridIndex*)object).y == y;
	}
	return NO;
}

-(NSUInteger) hash
{
	return x + y;
}

@end



@interface GridViewCell()

@property (assign) NSUInteger x;
@property (assign) NSUInteger y;

@end


@implementation GridViewCell

@synthesize x, y;

-(id) initWithFrame:(CGRect)frame
{
	if (CGRectIsEmpty(frame))
		frame = CGRectMake(0, 0, 40, 40);
	
	self = [super initWithFrame:frame];
	if (self)
	{
	}
	return self;
}

-(id) init
{
	self = [super initWithFrame:CGRectMake(0, 0, 40, 40)];
	if (self != nil)
	{
	}
	return self;
}

-(UIImageView*) imageView
{
	if (_imageView == nil)
	{
		_imageView = [[UIImageView alloc] initWithFrame:self.bounds];
		_imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_imageView.clipsToBounds = YES;
		_imageView.contentMode = UIViewContentModeScaleAspectFill;
		[self addSubview:_imageView];
	}
	return _imageView;
}

@end




@interface GridView()

-(void) scrolling;
-(void) configThumb:(GridViewCell*)thumb atX:(NSUInteger)x Y:(NSUInteger)y;
-(void) selectThumb:(GridViewCell*)thumb;
-(void) deselectThumb:(GridViewCell*)thumb;
-(void) deselectAllThumbs;
-(void) didEndScrolling;
-(void) adjustContentSize;

@end



@implementation GridView

@synthesize dataSource = _dataSource;
@synthesize rowCount = _rowCount;
@synthesize columnCount = _columnCount;
@synthesize thumbSize = _thumbSize;
@synthesize thumbSpace = _thumbSpace;
@synthesize selectedIndex = _selectedIndex;
@synthesize allowsMultiSelection = _allowsMultiSelection;
@synthesize normalAlpha = _normalAlpha;
@synthesize selectedAlpha = _selectedAlpha;
@synthesize gridsInsets = _gridsInsets;


-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_reusableThumbs = [[NSMutableSet alloc] init];
		_visibleThumbs = [[NSMutableSet alloc] init];
		_selectedIndex = [[NSMutableSet alloc] init];
		_thumbSpace = CGSizeMake(4.0f, 4.0f);
		_thumbSize = CGSizeMake(75.0f, 75.0f);
		_allowsMultiSelection = NO;
		_selectedAlpha = 0.55f;
		_normalAlpha = 1.0f;
		
		self.delegate = self;
		
		UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(thumbTapped:)];
		tgr.numberOfTapsRequired = 1;
		tgr.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:tgr];
		
		UILongPressGestureRecognizer* lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(thumbLongTapped:)];
		lpgr.minimumPressDuration = 0.8f;
		[self addGestureRecognizer:lpgr];
	}
	return self;
}

-(void) reloadCells
{
	[self adjustContentSize];
	[self scrolling];
}

-(void) reloadCellAtIndex:(GridIndex*)index
{
	GridViewCell* cell = [self cellAtIndex:index];
	if (cell != nil)
	{
		[_reusableThumbs addObject:cell];
		[_visibleThumbs removeObject:cell];
		[cell removeFromSuperview];
		
		GridViewCell* newCell = [_dataSource gridView:self cellForIndex:index];
		if (newCell != nil)
		{
			[self configThumb:newCell atX:index.x Y:index.y];
			[self addSubview:newCell];
			[_visibleThumbs addObject:newCell];
		}
	}
}

-(void) deselectCellAtIndex:(GridIndex*)index animated:(BOOL)animated
{
	GridViewCell* thumb = [self cellAtIndex:index];
	if (thumb != nil)
	{
		if (animated)
		{
			[UIView beginAnimations:nil context:nil];
			[UIView setAnimationDuration:0.3f];
		}
		[self deselectThumb:thumb];
		if (animated)
		{
			[UIView commitAnimations];
		}
	}
	[_selectedIndex removeObject:index];
}

-(GridViewCell*) dequeueReusableCell
{
	GridViewCell* thumb = [_reusableThumbs anyObject];
	if (thumb)
	{
		[_reusableThumbs removeObject:thumb];
	}
	return thumb;
}

-(GridViewCell*) cellAtIndex:(GridIndex*)index
{
	for (GridViewCell* thumb in _visibleThumbs)
		if (thumb.x == index.x && thumb.y == index.y)
			return thumb;
	return nil;
}

-(GridIndex*) indexOfCell:(GridViewCell*)cell
{
	if ([_visibleThumbs containsObject:cell])
	{
		return [GridIndex indexWithX:cell.x Y:cell.y];
	}
	return nil;
}

-(NSArray*) indexOfVisibleCells
{
	NSMutableArray* ret = [NSMutableArray arrayWithCapacity:_visibleThumbs.count];
	for (GridViewCell* thumb in _visibleThumbs)
	{
		[ret addObject:[GridIndex indexWithX:thumb.x Y:thumb.y]];
	}
	return [NSArray arrayWithArray:ret];
}

-(void) scrollRectToVisible:(CGRect)rect animated:(BOOL)animated
{
	[super scrollRectToVisible:rect animated:animated];
	[self scrolling];
}

-(void) reloadCellsWithVisible:(GridIndex*)index
{
	[self adjustContentSize];
	[self scrollCellToVisible:index];
}

-(void) scrollCellToVisible:(GridIndex*)index
{
	CGPoint origin = CGPointMake(index.x * (_thumbSize.width + _thumbSpace.width), index.y * (_thumbSize.height + _thumbSpace.height));
	origin.x += _gridsInsets.left;
	origin.y += _gridsInsets.top;
	CGRect rect = CGRectMake(origin.x, origin.y, _thumbSize.width, _thumbSize.height);
	if (self.pagingEnabled)
	{
		CGPoint center = CGPointZero;
		center.x = rect.origin.x + rect.size.width / 2.0f;
		center.y = rect.origin.y + rect.size.height / 2.0f;
		CGRect bound = self.bounds;
		if (!CGRectIsEmpty(bound))
		{
			int pageX = floorf(center.x / bound.size.width);
			int pageY = floorf(center.y / bound.size.height);
			bound.origin.x = pageX * bound.size.width;
			bound.origin.y = pageY * bound.size.height;
			rect = bound;
		}
	}
	[self scrollRectToVisible:rect animated:NO];
}

-(void) thumbTapped:(id)sender
{
	CGPoint point = [(UIGestureRecognizer*)sender locationInView:self];
	point.x -= _gridsInsets.left;
	point.y -= _gridsInsets.top;
	int x = floorf(point.x / (_thumbSize.width + _thumbSpace.width));
	if (point.x <= x * (_thumbSize.width + _thumbSpace.width) + _thumbSize.width)
	{
		int y = floorf(point.y / (_thumbSize.height + _thumbSpace.height));
		if (point.y <= y * (_thumbSize.height + _thumbSpace.height) + _thumbSize.height)
		{
			GridIndex* index = [GridIndex indexWithX:x Y:y];
			if (!_allowsMultiSelection) [self deselectAllThumbs];
			[_selectedIndex addObject:index];
			[self selectThumb:[self cellAtIndex:index]];
			if ([_dataSource respondsToSelector:@selector(gridView:didSelectCellAtIndex:)])
				[_dataSource gridView:self didSelectCellAtIndex:index];
			return;
		}
	}
	if ([_dataSource respondsToSelector:@selector(didTapOnGridViewBlankSpace:)])
		[_dataSource didTapOnGridViewBlankSpace:self];
}

-(void) thumbLongTapped:(id)sender
{
	CGPoint point = [(UIGestureRecognizer*)sender locationInView:self];
	point.x -= _gridsInsets.left;
	point.y -= _gridsInsets.top;
	int x = floorf(point.x / (_thumbSize.width + _thumbSpace.width));
	if (point.x <= x * (_thumbSize.width + _thumbSpace.width) + _thumbSize.width)
	{
		int y = floorf(point.y / (_thumbSize.height + _thumbSpace.height));
		if (point.y <= y * (_thumbSize.height + _thumbSpace.height) + _thumbSize.height)
		{
			GridIndex* index = [GridIndex indexWithX:x Y:y];
			if ([_dataSource respondsToSelector:@selector(gridView:didLongTapOnCellAtIndex:)])
				[_dataSource gridView:self didLongTapOnCellAtIndex:index];
		}
	}
}


#pragma Private Methods

-(void) adjustContentSize
{
	CGFloat contentWidth = (_columnCount == 0) ? 0 : (_columnCount * (_thumbSize.width + _thumbSpace.width) - _thumbSpace.width);
	CGFloat contentHeight = (_rowCount == 0) ? 0 : (_rowCount * (_thumbSize.height + _thumbSpace.height) - _thumbSpace.height);
	contentWidth = contentWidth + _gridsInsets.left + _gridsInsets.right;
	contentHeight = contentHeight + _gridsInsets.top + _gridsInsets.bottom;
	self.contentSize = CGSizeMake(contentWidth, contentHeight);
	
	for (GridViewCell* thumb in _visibleThumbs)
	{
		[_reusableThumbs addObject:thumb];
		[thumb removeFromSuperview];
	}
	[_visibleThumbs removeAllObjects];
}

-(void) selectThumb:(GridViewCell*)thumb
{
	thumb.alpha = _selectedAlpha;
}

-(void) deselectThumb:(GridViewCell*)thumb
{
	thumb.alpha = _normalAlpha;
}

-(void) deselectAllThumbs
{
	for (GridViewCell* thumb in _visibleThumbs)
		[self deselectThumb:thumb];
	[_selectedIndex removeAllObjects];
}

-(void) scrolling
{
	if (_rowCount == 0 || _columnCount == 0)
		return;
	
	// Calculate which thumbs are visible
	CGRect visibleBounds = self.bounds;
	visibleBounds.origin.x -= _gridsInsets.left;
	visibleBounds.origin.y -= _gridsInsets.top;
	int firstNeededImageX = floorf((CGRectGetMinX(visibleBounds) + _thumbSpace.width) / (_thumbSize.width + _thumbSpace.width));
	int firstNeededImageY = floorf((CGRectGetMinY(visibleBounds) + _thumbSpace.height) / (_thumbSize.height + _thumbSpace.height));
	int lastNeededImageX = floorf((CGRectGetMaxX(visibleBounds) - 1) / (_thumbSize.width + _thumbSpace.width));
	int lastNeededImageY = floorf((CGRectGetMaxY(visibleBounds) - 1) / (_thumbSize.height + _thumbSpace.height));
    
	firstNeededImageX = firstNeededImageX > 0 ? firstNeededImageX : 0;
	firstNeededImageY = firstNeededImageY > 0 ? firstNeededImageY : 0;
	lastNeededImageX  = lastNeededImageX < ((int)_columnCount - 1) ? lastNeededImageX : ((int)_columnCount - 1);
	lastNeededImageY  = lastNeededImageY < ((int)_rowCount - 1) ? lastNeededImageY : ((int)_rowCount - 1);
	
	// Recycle no-longer-visible thumbs
	for (GridViewCell* thumb in _visibleThumbs)
	{
		if (thumb.x < firstNeededImageX || thumb.x > lastNeededImageX || thumb.y < firstNeededImageY || thumb.y > lastNeededImageY)
		{
			[_reusableThumbs addObject:thumb];
			[thumb removeFromSuperview];
		}
	}
	[_visibleThumbs minusSet:_reusableThumbs];
	
	// Add missing thumbs
	for (int x = firstNeededImageX; x <= lastNeededImageX; ++x)
	{
		for (int y = firstNeededImageY; y <= lastNeededImageY; ++y)
		{
			GridIndex* index = [GridIndex indexWithX:x Y:y];
			if ([self cellAtIndex:index] == nil)
			{
				GridViewCell* thumb = [_dataSource gridView:self cellForIndex:index];
				if (thumb != nil)
				{
					[self configThumb:thumb atX:x Y:y];
					[self addSubview:thumb];
					[_visibleThumbs addObject:thumb];
				}
			}
		}
	}
}

-(void) configThumb:(GridViewCell*)thumb atX:(NSUInteger)x Y:(NSUInteger)y
{
	thumb.x = x;
	thumb.y = y;
	CGFloat originX = x * (_thumbSize.width + _thumbSpace.width) + _gridsInsets.left;
	CGFloat originY = y * (_thumbSize.height + _thumbSpace.height) + _gridsInsets.top;
	thumb.frame = CGRectMake(originX, originY, _thumbSize.width, _thumbSize.height);
	
	if ([_selectedIndex containsObject:[GridIndex indexWithX:x Y:y]])
	{
		[self selectThumb:thumb];
	}
	else
	{
		[self deselectThumb:thumb];
	}
}

-(void) didEndScrolling
{
	if ([_dataSource respondsToSelector:@selector(didStopScrolling:)])
	{
		[_dataSource didStopScrolling:self];
	}
}


#pragma UIView

-(void) didMoveToWindow
{
	if (self.window)
		[self reloadCells];
}


#pragma UIScrollViewDelegate

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self scrolling];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self didEndScrolling];
}

-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if (!decelerate)
		[self didEndScrolling];
	else
	{
		if ([_dataSource respondsToSelector:@selector(gridViewDidEndDragging:)])
			[_dataSource gridViewDidEndDragging:self];
	}
}

@end
