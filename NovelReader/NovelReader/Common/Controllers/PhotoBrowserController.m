//
//  PhotoBrowserController.m
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-30.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "PhotoBrowserController.h"
#import "GridView.h"
#import "KYPageControl.h"
#import "CDRemoteImageView.h"
#import "KYTipsView.h"



@interface PhotoZoomCell : UIScrollView <UIScrollViewDelegate, CDRemoteImageViewDelegate>
{
	CDRemoteImageView* _zoomImage;
}

@property (nonatomic, strong) NSString* imgUrl;
@property (readonly) UIImage* image;

-(void) applyImage:(UIImage*)image;
-(void) adjustViewParams:(UIImage*)image;
-(void) centerImage;

@end



@implementation PhotoZoomCell

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.bouncesZoom = YES;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.delegate = self;
		
		_zoomImage = [[CDRemoteImageView alloc] initWithFrame:self.bounds];
		_zoomImage.placeholderImage = CDImage(@"main/loading");
		_zoomImage.placeHolderContetMode = UIViewContentModeScaleAspectFit;
		_zoomImage.failHolderImage = CDImage(@"main/thumb_big");
		_zoomImage.failHolderContentMode = UIViewContentModeScaleAspectFit;
		_zoomImage.backgroundColor = [UIColor blackColor];
		_zoomImage.delegate = self;
		[self addSubview:_zoomImage];
	}
	return self;
}

- (UIImage*)image
{
	return _zoomImage.image;
}

- (void)setImgUrl:(NSString *)imgUrl
{
	_imgUrl = imgUrl;
	_zoomImage.imageURL = imgUrl;
	[self adjustViewParams:_zoomImage.image];
}

-(void) applyImage:(UIImage *)image
{
	_zoomImage.image = image;
	[self adjustViewParams:image];
}

-(void) adjustViewParams:(UIImage *)image
{
	self.zoomScale = 1.0f;
	CGSize sz = self.bounds.size;
	CGSize viewSize = sz;
	if (image != nil)
		viewSize = image.size;
	
	CGFloat minScale = 1.0f;
	CGFloat maxScale = 1.0f;
	if (viewSize.width > 0.0f && viewSize.height > 0.0f)
	{
		CGFloat widthFactor = sz.width / viewSize.width;
		CGFloat heightFactor = sz.height / viewSize.height;
		minScale = MIN(widthFactor, heightFactor);
		if (minScale > 1.0f) minScale = 1.0f;
		maxScale = 3.0f;
	}
	
	_zoomImage.frame = CGRectMake(0, 0, viewSize.width, viewSize.height);
	self.contentSize = CGSizeMake(viewSize.width, viewSize.height);
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
	
	[self centerImage];
}

-(void) centerImage
{
	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = _zoomImage.frame;
	
	// center horizontally
	if (frameToCenter.size.width < boundsSize.width)
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
	else
		frameToCenter.origin.x = 0;
	
	// center vertically
	if (frameToCenter.size.height < boundsSize.height)
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
	else
		frameToCenter.origin.y = 0;
	
	_zoomImage.frame = frameToCenter;
}

-(void) layoutSubviews
{
	[super layoutSubviews];
	[self centerImage];
}

-(UIView*) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return _zoomImage;
}

-(void) didFinishLoading:(CDRemoteImageView *)imageView
{
	[self adjustViewParams:_zoomImage.image];
}

@end




@interface _CustomView : UIView

@property (nonatomic, weak) id owner;

@end



@interface PhotoBrowserController() <GridViewDataSource>
{
	BrowserType _browserType;
	GridView* _gridView;
	KYPageControl* _pageIndicator;
	CGSize _oldViewSize;
	
	BOOL _doubleTapDetecting;
}

-(void) adjustGridView;
-(void) dismiss;

@end



@implementation PhotoBrowserController

-(id) initWithChannelType:(BrowserType)type;
{
	self = [super init];
	if (self != nil)
	{
		_browserType = type;
		self.wantsFullScreenLayout = YES;
		self.imageIndex = 0;
	}
	return self;
}

-(void) loadView
{
	_CustomView* aView = [[_CustomView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	aView.owner = self;
	aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.view = aView;
	
	CGRect rect = self.view.bounds;
	
	_gridView = [[GridView alloc] initWithFrame:rect];
	_gridView.dataSource = self;
	_gridView.backgroundColor = [UIColor blackColor];
	_gridView.showsVerticalScrollIndicator = NO;
	_gridView.showsHorizontalScrollIndicator = NO;
	_gridView.bounces = YES;
	_gridView.alwaysBounceHorizontal = YES;
	_gridView.directionalLockEnabled = YES;
	_gridView.pagingEnabled = YES;
	_gridView.thumbSize = rect.size;
	_gridView.thumbSpace = CGSizeZero;
	_gridView.rowCount = 1;
	_gridView.selectedAlpha = 1.0f;
	_gridView.columnCount = self.imgUrlArr.count == 0 ? 1 : self.imgUrlArr.count;
	[self.view addSubview:_gridView];
	
	if (_browserType == BrowserTypeRead)
	{
		_pageIndicator = [[KYPageControl alloc] initWithFrame:CGRectMake(36.0f, rect.size.height-44.0f+16.0f, rect.size.width-36*2, 4)];
		_pageIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
		_pageIndicator.hidesForSinglePage = YES;
		_pageIndicator.spaceWidth = 2.0f;
		_pageIndicator.numberOfPages = self.imgUrlArr.count;
		_pageIndicator.singleWidth = (_pageIndicator.bounds.size.width - _pageIndicator.spaceWidth * (self.imgUrlArr.count - 1))/self.imgUrlArr.count;
		[self.view addSubview:_pageIndicator];
		
	}
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	
	if (self.imageIndex >= 0 && self.imageIndex < self.imgUrlArr.count)
	{
		[_gridView reloadCellsWithVisible:[GridIndex indexWithX:self.imageIndex Y:0]];
	}
	else
	{
		[_gridView reloadCells];
	}
	_pageIndicator.currentPage = self.imageIndex;

	[[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	_gridView.frame = self.view.bounds;
	[_gridView reloadCells];
}

-(void) adjustGridView
{
	CGRect rect = self.view.bounds;
	if (CGSizeEqualToSize(_oldViewSize, rect.size))
		return;
	_oldViewSize = rect.size;
	
	_gridView.frame = rect;
	_gridView.thumbSize = rect.size;
	if (self.imageIndex >= 0 && self.imageIndex < self.imgUrlArr.count)
	{
		[_gridView reloadCellsWithVisible:[GridIndex indexWithX:self.imageIndex Y:0]];
	}
	else
	{
		[_gridView reloadCells];
	}
}

-(void) dismiss
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO];
	[self.cdNavigationController popViewControllerWithInStyle:ASNone outStyle:ASFadeOut];
}


#pragma GridViewDataSource

#define PhotoBrowserCellTag 555

-(GridViewCell*) gridView:(GridView *)gridView cellForIndex:(GridIndex *)index
{
	if (self.imgUrlArr.count > 0 && index.x >= self.imgUrlArr.count)
		return nil;
	
	GridViewCell* cell = [gridView dequeueReusableCell];
	if (cell == nil)
	{
		cell = [[GridViewCell alloc] initWithFrame:self.view.bounds];
		
		PhotoZoomCell* pzc = [[PhotoZoomCell alloc] initWithFrame:cell.bounds];
		pzc.tag = PhotoBrowserCellTag;
		pzc.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[cell addSubview:pzc];
	}
	cell.frame = self.view.bounds;
	
	if (self.imgUrlArr.count > 0)
	{
		((PhotoZoomCell*)[cell viewWithTag:PhotoBrowserCellTag]).imgUrl = [self.imgUrlArr objectAtIndex:index.x];
	}
	else
	{
		[((PhotoZoomCell*)[cell viewWithTag:PhotoBrowserCellTag]) applyImage:self.singleImage];
	}
	return cell;
}

-(void) gridView:(GridView *)gridView didSelectCellAtIndex:(GridIndex *)index
{
	if (_doubleTapDetecting)
	{
		_doubleTapDetecting = NO;
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
		
		// Double tap
		PhotoZoomCell* cell = (PhotoZoomCell*)[[gridView cellAtIndex:index] viewWithTag:PhotoBrowserCellTag];
		if (cell)
		{
			if (cell.zoomScale < cell.maximumZoomScale)
			{
				[cell setZoomScale:cell.maximumZoomScale animated:YES];
			}
			else
			{
				[cell setZoomScale:cell.minimumZoomScale animated:YES];
			}
		}
	}
	else
	{
		_doubleTapDetecting = YES;
		[self performSelector:@selector(dismiss) withObject:nil afterDelay:0.35];
	}
}

-(void) didStopScrolling:(GridView *)gridView
{
	CGRect rect = gridView.bounds;
	CGFloat width = CGRectGetWidth(rect);
	if (width <= 0)
		return;
	
	CGFloat middle = (CGRectGetMinX(rect) + CGRectGetMaxX(rect)) / 2.0f;
	int page = floorf(middle / width);
	_pageIndicator.currentPage = page;
}

@end



@implementation _CustomView

@synthesize owner;

-(void) layoutSubviews
{
	[super layoutSubviews];
	[owner adjustGridView];
}

@end

