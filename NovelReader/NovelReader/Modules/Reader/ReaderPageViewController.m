//
//  ReaderPageViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "ReaderPageViewController.h"
#import "Theme.h"
#import <CoreText/CoreText.h>
#import "BookManager.h"
#import "UIHelper.h"
#import "KYTipsView.h"



@interface ReaderPageView : UIView
{
	ReaderLayoutInfo* _info;
	NSArray* _lines;
}

-(void) applyInfo:(ReaderLayoutInfo*)info lines:(NSArray*)lines;

@end



@implementation ReaderPageView

-(void) applyInfo:(ReaderLayoutInfo*)info lines:(NSArray*)lines
{
	_info = info;
	_lines = lines;
	[self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
	if (_info == nil || _lines.count <= 0)
	{
		return;
	}
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, 0));
	
	NSLock* theLock = [ReaderLayoutInfo getLock];
	[theLock lock];
	
	CTTypesetterRef typesetter = _info.typesetter;
	NSUInteger allCount = _lines.count;
	for (NSUInteger i = 0; i < allCount; ++i)
	{
		RenderLine* line = [_lines objectAtIndex:i];
		CTLineRef ctLine = CTTypesetterCreateLine(typesetter, line.range);
		if (line.justified)
		{
			CTLineRef justifiedLine = CTLineCreateJustifiedLine(ctLine, 1.0f, line.width);
			CFRelease(ctLine);
			ctLine = justifiedLine;
		}
		CGFloat ascent;
		CTLineGetTypographicBounds(ctLine, &ascent, NULL, NULL);
		CGContextSetTextPosition(ctx, line.origin.x, line.origin.y + ascent);
		CTLineDraw(ctLine, ctx);
		CFRelease(ctLine);
	}
	
	[theLock unlock];
}

@end





@interface ReaderPageViewController ()
{
	ReaderPageView* _renderView;
}

@property (readonly) ReaderPageView* renderView;

-(void) showBuyView;

@end




@implementation ReaderPageViewController

-(id) init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

-(void) dealloc
{
	[_chapterModel removeObserver:self forKeyPath:@"requestFailed"];
	[_chapterModel removeObserver:self forKeyPath:@"content"];
}

-(void) setChapterModel:(XLChapterModel *)chapterModel
{
	if (_chapterModel != chapterModel)
	{
		[_chapterModel removeObserver:self forKeyPath:@"requestFailed"];
		[_chapterModel removeObserver:self forKeyPath:@"content"];
		_chapterModel = chapterModel;
		[_chapterModel addObserver:self forKeyPath:@"requestFailed" options:0 context:nil];
		[_chapterModel addObserver:self forKeyPath:@"content" options:0 context:nil];
	}
}

-(void) setBgColor:(UIColor *)bgColor
{
	_bgColor = bgColor;
	if ([self isViewLoaded])
		self.view.backgroundColor = _bgColor;
	if (_renderView != nil)
		_renderView.backgroundColor = _bgColor;
}

-(void) loadView
{
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.view.backgroundColor = _bgColor;
}

-(ReaderPageView*) renderView
{
	if (_renderView == nil)
	{
		_renderView = [[ReaderPageView alloc] initWithFrame:self.view.bounds];
		_renderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_renderView.backgroundColor = _bgColor;
		[self.view addSubview:_renderView];
	}
	return _renderView;
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	if (self.layoutInfo != nil)
	{
		[self.renderView applyInfo:_layoutInfo lines:[_layoutInfo.pages objectAtIndex:_pageIndex]];
		_isViewReady = YES;
	}
	else if (_chapterModel != nil)
	{
		if (!_chapterModel.chapter_readable)
			[self showBuyView];
		else if (_chapterModel.content.length <= 0)
		{
			[self.view showColorIndicatorFreezeUI:NO];
			[_chapterModel requestContent];
		}
		else
			[self reloadContent];
	}
}

-(void) showBuyView
{
	[UIHelper addLabel:self.view t:@"购买" tc:[UIColor blackColor] fs:20 b:YES al:NSTextAlignmentCenter frame:self.view.bounds];
	
	_isViewReady = YES;
}

-(void) reloadContent
{
	if (!_chapterModel.chapter_readable)
		return;
	
	if (_isRendering)
		return;
	_isRendering = YES;
	
	[self.view showColorIndicatorFreezeUI:NO];
	
	BOOL firstRender = (_layoutInfo == nil);
	CFIndex currentLocation = 0;
	NSUInteger currentIndex = self.pageIndex;
	if (_layoutInfo.pages.count > 0 && currentIndex > 0)
	{
		RenderLine* line = [[_layoutInfo.pages objectAtIndex:currentIndex] firstObject];
		if (line)
			currentLocation = line.range.location;
	}
	
	TextRenderContext* tctx = [TextRenderContext contextWithContext:_textContext];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@autoreleasepool {
			NSString* text = self.chapterModel.content;
			_layoutInfo = [[ReaderLayoutInfo alloc] initWithText:text inContext:tctx];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.view dismiss];
				if (_layoutInfo.pages.count > 0)
				{
					_pageIndex = 0;
					if (firstRender && _defaultLastIndex)
						_pageIndex = _layoutInfo.pages.count - 1;
					if (currentLocation > 0)
					{
						NSInteger theIndex = [_layoutInfo findIndexForLocation:currentLocation inRange:NSMakeRange(0, _layoutInfo.pages.count)];
						if (theIndex > 0)
							_pageIndex = theIndex;
					}
					[self.renderView applyInfo:_layoutInfo lines:[_layoutInfo.pages objectAtIndex:_pageIndex]];
				}
				_isViewReady = YES;
				_isRendering = NO;
			});
		}
	});
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (object != _chapterModel)
		return;
	
	if ([keyPath isEqualToString:@"content"])
	{
		[self reloadContent];
	}
	else if ([keyPath isEqualToString:@"requestFailed"] && _chapterModel.requestFailed)
	{
		[self.view dismiss];
		if (_bookModel.chapters.count <= 0 && _bookModel.errorMsg.length > 0)
			[self.view showPopMsg:_chapterModel.errorMsg timeout:5];
	}
}

@end


