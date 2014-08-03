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





@implementation ReaderPageViewController

-(id) init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

-(void) loadView
{
	ReaderPageView* pv = [[ReaderPageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	pv.backgroundColor = CDColor(nil, @"f6e6cd");
	[pv applyInfo:_layoutInfo lines:[_layoutInfo.pages objectAtIndex:_pageIndex]];
	self.view = pv;
}

@end


