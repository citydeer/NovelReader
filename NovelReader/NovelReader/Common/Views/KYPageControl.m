//
//  KYPageControl.m
//  Nemo
//
//  Created by zhihui zhao on 13-11-5.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "KYPageControl.h"

@interface KYPageControl ()
@property (nonatomic, assign) KYPageControllerStyle style;
@property (nonatomic, assign) CGRect bgImageRect;
- (void)updateBgImageRect;
@end

@implementation KYPageControl

#define maxSingleWidth 40.0f
#define ORIGIN_OFFSET 5.0f
@synthesize numberOfPages = _numberOfPages;
@synthesize currentPage = _currentPage;
@synthesize singleWidth = _singleWidth;
@synthesize spaceWidth = _spaceWidth;
@synthesize currentPageColor = _currentPageColor;
@synthesize otherPageColor = _otherPageColor;
@synthesize hidesForSinglePage = _hidesForSinglePage;
@synthesize curImage = _curImage, otherImage = _otherImage;
@synthesize style = _style;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.style = KYPageControllerStyleMiddle;
		self.numberOfPages = 1;
		self.currentPage = 1;
		self.singleWidth = 40.0f;
		self.spaceWidth = 10.0f;
		self.originOffset = ORIGIN_OFFSET;
		self.currentPageColor = [UIColor whiteColor];
		self.otherPageColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.2f];
		self.bgImageRect = self.bounds;
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame style:(KYPageControllerStyle)style
{
	if (self = [self initWithFrame:frame])
	{
		self.style = style;
	}
	return self;
}

-(void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	if (self.bgImage && (!_hidesForSinglePage || _numberOfPages != 1))
		[self.bgImage drawInRect:self.bgImageRect blendMode:kCGBlendModeNormal alpha:1.0];
	if (_curImage != nil && _otherImage != nil)
	{
		CGSize imageSize = _curImage.size;
		if (imageSize.width > maxSingleWidth)
			imageSize.width = maxSingleWidth;
		CGFloat width = _numberOfPages * (imageSize.width + _spaceWidth) - _spaceWidth;
		if (!_hidesForSinglePage || _numberOfPages != 1)
		{
			float originX = _style == KYPageControllerStyleMiddle ? self.bounds.size.width/2 - width/2.0:(_style == KYPageControllerStyleLeft ? self.originOffset:self.bounds.size.width - width - self.originOffset);
			
			for (int i = 0; i < _numberOfPages; i++)
			{
				if (i == _currentPage)
				{
					CGContextDrawImage(context, CGRectMake(originX + imageSize.width * i + _spaceWidth * i, (self.bounds.size.height - imageSize.height) / 2, imageSize.width, imageSize.height), [_curImage CGImage]);
				}
				else
					CGContextDrawImage(context, CGRectMake(originX + imageSize.width * i + _spaceWidth * i, (self.bounds.size.height - imageSize.height) / 2, imageSize.width, imageSize.height), [_otherImage CGImage]);
				
			}
		}
		
	}
	else
	{
		if (_singleWidth > maxSingleWidth)
			_singleWidth = maxSingleWidth;
		CGFloat width = _numberOfPages * (_singleWidth + _spaceWidth) - _spaceWidth;
		
		if (!_hidesForSinglePage || _numberOfPages != 1)
		{
			float originX = _style == KYPageControllerStyleMiddle ? self.bounds.size.width/2 - width/2.0:(_style == KYPageControllerStyleLeft ? self.originOffset:self.bounds.size.width - width - self.originOffset);
			
			for (int i = 0; i < _numberOfPages; i++) {
				if (i == _currentPage) {
					[_currentPageColor set];
				}
				else
					[_otherPageColor set];
				CGContextFillRect(context, CGRectMake(originX + _singleWidth * i + _spaceWidth * i, 0, _singleWidth, self.bounds.size.height));
			}
		}
	}
	UIGraphicsPopContext();
}

- (void)updateBgImageRect
{
	if (_curImage && _numberOfPages > 0)
	{
		CGFloat width = _numberOfPages * (_curImage.size.width + _spaceWidth) - _spaceWidth;
		CGRect rect = self.bgImageRect;
		if (_style == KYPageControllerStyleMiddle)
		{
			rect.origin.y = self.bounds.size.width/2.0 - width/2.0;
			rect.size.width = width;
		}
		else
		{
			rect.origin.y = self.originOffset;
			rect.size.width = width;
		}
		self.bgImageRect = rect;
	}
}

-(void)setHidesForSinglePage:(BOOL)hidesForSinglePage
{
	_hidesForSinglePage = hidesForSinglePage;
	[self setNeedsDisplay];
}

-(void)setCurrentPage:(NSInteger)currentPage
{
	_currentPage = currentPage;
	[self setNeedsDisplay];
}

-(void)setNumberOfPages:(NSInteger)numberOfPages
{
	_numberOfPages = numberOfPages;
	[self updateBgImageRect];
	[self setNeedsDisplay];
}

-(void)setCurImage:(UIImage *)curImage
{
	_curImage = curImage;
	[self updateBgImageRect];
	[self setNeedsDisplay];
}

- (void)setSpaceWidth:(float)spaceWidth
{
	_spaceWidth = spaceWidth;
	[self updateBgImageRect];
	[self setNeedsDisplay];
}

- (void)setOriginOffset:(float)originOffset
{
	_originOffset = originOffset;
	[self updateBgImageRect];
	[self setNeedsDisplay];
}

- (void)setBgImage:(UIImage *)bgImage
{
	if (![_bgImage isEqual:bgImage])
	{
		_bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 7)];
		[self setNeedsDisplay];
	}
}

-(void)dealloc
{
}

@end
