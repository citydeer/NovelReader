//
//  KYCustomViews.m
//  Kuyun
//
//  Created by Pang Zhenyu on 11-10-7.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "KYCustomViews.h"
#import "GraphicUtils.h"
#import "Theme.h"


#define PI 3.14159265358979323846 

@implementation KYProgressView

@synthesize progress = _progress;
@synthesize progressColor = _progressColor;

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

-(void) setProgress:(float)progress
{
	_progress = progress;
	if (_progress > 1.0f) _progress = 1.0f;
	if (_progress < 0.0f) _progress = 0.0f;
	
	[self setNeedsDisplay];
}

-(void) setProgressColor:(UIColor *)progressColor
{
	_progressColor = progressColor;
	
	[self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	
	CGRect r = CGRectMake(0, 0, self.bounds.size.width * _progress, self.bounds.size.height);
	[_progressColor set];
	CGContextFillRect(context, r);
	
	UIGraphicsPopContext();
}

@end




@implementation KYProgressView2

@synthesize progress = _progress;
@synthesize edgeColor = _edgeColor;
@synthesize fillColor = _fillColor;

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.contentMode = UIViewContentModeRedraw;
		self.backgroundColor = [UIColor whiteColor];
		_fillColor = [UIColor greenColor];
		_edgeColor = [UIColor blackColor];
	}
	return self;
}

-(void) setProgress:(float)progress
{
	_progress = progress;
	if (_progress > 1.0f) _progress = 1.0f;
	if (_progress < 0.0f) _progress = 0.0f;
	
	[self setNeedsDisplay];
}

-(void)setEdgeColor:(UIColor *)edgeColor
{
	_edgeColor = edgeColor;
	[self setNeedsDisplay];
}

-(void)setFillColor:(UIColor *)fillColor
{
	_fillColor = fillColor;
	[self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [_fillColor CGColor]);
	
	//填充
	CGRect r = CGRectMake(0, 0, self.bounds.size.width * _progress, self.bounds.size.height);
	CGContextFillRect(context, r);
}

@end




@implementation KYScrollIndicator

@synthesize totalLength = _totalLength, screenLength = _screenLength, screenOffset = _screenOffset;
@synthesize progressColor = _progressColor, minThumbLength = _minThumbLength, lineColor = _lineColor;

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.contentMode = UIViewContentModeRedraw;
	}
	return self;
}

-(void) setTotalLength:(CGFloat)totalLength
{
	_totalLength = totalLength;
	if (_totalLength <= 0.0f)
	{
		self.hidden = YES;
	}
	else
	{
		self.hidden = NO;
		[self setNeedsDisplay];
	}
}

-(void) setScreenLength:(CGFloat)screenLength
{
	_screenLength = screenLength;
	[self setNeedsDisplay];
}

-(void) setScreenOffset:(CGFloat)screenOffset
{
	_screenOffset = screenOffset;
	[self setNeedsDisplay];
}

-(void) setMinThumbLength:(CGFloat)minThumbLength
{
	_minThumbLength = minThumbLength;
	[self setNeedsDisplay];
}

-(void) setProgressColor:(UIColor *)progressColor
{
	_progressColor = progressColor;
	
	[self setNeedsDisplay];
}

-(void) setLineColor:(UIColor *)lineColor
{
	_lineColor = lineColor;
	[self setNeedsDisplay];
}

#define MIN_THUMB_LENGTH 5.0f

-(void) drawRect:(CGRect)rect
{
	if (_totalLength <= 0.0f || _screenLength <= 0.0f)
		return;
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	
	CGSize size = self.bounds.size;
	
	CGFloat thumb = size.width * _screenLength / _totalLength;
	if (thumb < _minThumbLength) thumb = _minThumbLength;
	
	if (_screenOffset < 0.0f)
		thumb += thumb * _screenOffset / _screenLength;
	if (_screenOffset + _screenLength > _totalLength)
		thumb -= thumb * (_screenOffset + _screenLength - _totalLength) / _screenLength;
	
	if (thumb < MIN_THUMB_LENGTH) thumb = MIN_THUMB_LENGTH;
	if (thumb > size.width) thumb = size.width;
	
	float percent = 0.0f;
	if (_screenOffset < 0.0f)
		percent = 0.0f;
	else if (_screenOffset + _screenLength > _totalLength)
		percent = 1.0f;
	else
		percent = _screenOffset / (_totalLength - _screenLength);
	
	CGFloat origin = (size.width - thumb) * percent;
	
	if (origin > 1 ) {
		[_lineColor set];
		CGContextFillRect(context, CGRectMake(0, 0, origin - 1, size.height - 1 ));
		[[UIColor clearColor] set];
		CGContextFillRect(context, CGRectMake(origin - 1, 0, 1, size.height - 1));
	}
	
	[_progressColor set];
	CGContextFillRect(context, CGRectMake(origin, 0, thumb, size.height - 1));
	[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f] set];
	CGContextFillRect(context, CGRectMake(origin, size.height - 1, thumb, 0.5));
	[[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.4f] set];
	CGContextFillRect(context, CGRectMake(origin, size.height - 0.5 , thumb, 0.5));
	
	if (origin + thumb + 1 < size.width) {
		[[UIColor clearColor] set];
		CGContextFillRect(context, CGRectMake(origin + thumb , 0, 1, size.height - 1));
		[_lineColor set];
		CGContextFillRect(context, CGRectMake(origin + thumb + 1, 0, size.width - origin - thumb - 2, size.height - 1));
	}
	
	UIGraphicsPopContext();
}

@end



@implementation KYChannelSelectedView

@synthesize viewColor = _viewColor;

-(void) setViewColor:(UIColor *)viewColor
{
	_viewColor = viewColor;
	[self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIGraphicsPushContext(context);
	[_viewColor set];
	CGContextFillRect(context, rect);
	
	UIGraphicsPopContext();
}

@end

@implementation KYFeedImageView

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = CDColor(@"image_default_bg", @"0000");
		_kuyunIcon = [[UIImageView alloc] initWithImage:CDKeyImage(@"common_default")];
		_kuyunIcon.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
		[self addSubview:_kuyunIcon];
	}
	return self;
}

-(void) layoutSubviews
{
	[super layoutSubviews];
	_kuyunIcon.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
}

-(void) setImage:(UIImage *)image
{
	[super setImage:image];
	if (image == nil)
	{
		_kuyunIcon.hidden = NO;
		self.backgroundColor = CDColor(@"image_default_bg", @"0000");
	}
	else
	{
		_kuyunIcon.hidden = YES;
		self.backgroundColor = [UIColor clearColor];
	}
}

@end

//大图浏览时背景黑色,且logo的alpha = 0.3
@implementation KYFeedImageView1

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [GraphicUtils colorWithString:@"#000000"];
		;
//		_kuyunIcon = [[UIImageView alloc] initWithImage:[Context sharedContext].theme.imageReaderBlankFeedIcon];
		_kuyunIcon = [[UIImageView alloc] init];
		_kuyunIcon.alpha = 0.3f;
		_kuyunIcon.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
		[self addSubview:_kuyunIcon];
	}
	return self;
}

-(void) layoutSubviews
{
	[super layoutSubviews];
	_kuyunIcon.center = CGPointMake(self.bounds.size.width / 2.0f, self.bounds.size.height / 2.0f);
}

-(void) setImage:(UIImage *)image
{
	[super setImage:image];
	if (image == nil)
	{
		_kuyunIcon.hidden = NO;
		self.backgroundColor = [GraphicUtils colorWithString:@"#000000"];
	}
	else
	{
		_kuyunIcon.hidden = YES;
		self.backgroundColor = [UIColor clearColor];
	}
}

@end



@interface KYRateCircleView ()
-(CGFloat) radians:(CGFloat) degrees;
@end
@implementation KYRateCircleView
@synthesize rate = _rate;

-(void) setRate:(NSInteger)rate
{
	_rate = rate;
	[self setNeedsDisplay];
}

-(void) drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//UIImage* image = [[Context sharedContext].theme getMedalImage:@"sns_medal_gray_24"];
	[[UIColor whiteColor] set];
	//CGImageRef imageRef = [[Context sharedContext].theme getMedalImage:@"sns_medal_gray_24"].CGImage;
	//CGContextClipToMask(context, rect, imageRef);
	UIGraphicsPushContext(context);
	//CGSize size = image.size;
	//[image drawInRect:rect];
	//CGContextDrawImage(context, rect, imageRef);
	//CGContextTranslateCTM(context, 0, self.bounds.size.height);  //画布的高度
    //CGContextScaleCTM(context, 1.0, -1.0);
	NSInteger circleRate = _rate;
	if (circleRate < 0)
		circleRate = 0;
	else if (circleRate > 100)
		circleRate = 100;
	CGPoint centerPoint = CGPointMake(rect.origin.x + rect.size.width / 2, rect.origin.y + rect.size.height / 2);
	NSInteger radius = self.frame.size.width >= self.frame.size.height ? self.frame.size.height / 2 : self.frame.size.width / 2;
	
	CGFloat start, end;
	start = [self radians:270];
	end = [self radians:(270 - 360.0 * (100 - circleRate) / 100)];
	CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
	CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, start, end, 1);
	//CGContextClip(context);
	//CGContextClearRect(context, rect); 
	CGContextFillPath(context);
	
	UIGraphicsPopContext();
}

-(CGFloat) radians:(CGFloat) degrees
{
	return degrees * PI / 180;
}
@end

@implementation KYUILabel
@synthesize insetsWidth,insetsHeight;
-(id)init
{
	self = [super init];
	if (self) {
		self.insetsWidth = 5.0f;
		self.insetsHeight = 0.0f;
	}
	return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {self.insetsHeight, self.insetsWidth,  self.insetsHeight,self.insetsWidth};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end


@implementation PrivacyLockView
-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	UIView* lockBG = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 124, 86)];
	lockBG.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	lockBG.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
	lockBG.backgroundColor = [UIColor darkGrayColor];
	lockBG.layer.masksToBounds = YES;
	lockBG.layer.cornerRadius = 4.0f;
	[self addSubview:lockBG];
	
//	UIImageView* lockView = [[UIImageView alloc] initWithImage:[Context sharedContext].theme.imageSNSPrivacyLock];
	UIImageView* lockView = [[UIImageView alloc] init];
	lockView.center = CGPointMake(lockBG.frame.size.width / 2, lockView.frame.size.height / 2 + 12);
	lockView.backgroundColor = [UIColor clearColor];
	[lockBG addSubview:lockView];
	
	UILabel* privacyNotice = [[UILabel alloc] initWithFrame:CGRectMake(10, lockView.frame.origin.y + lockView.frame.size.height + 8, lockBG.frame.size.width - 20, 20)];
	privacyNotice.backgroundColor = [UIColor clearColor];
	privacyNotice.textAlignment = NSTextAlignmentCenter;
	privacyNotice.textColor = [UIColor whiteColor];
	privacyNotice.font = [UIFont boldSystemFontOfSize:10.0f];
	privacyNotice.text = @"对方已设置隐私保护";
	[lockBG addSubview:privacyNotice];

	return self;
}
@end


@implementation KYGuideView
@synthesize name;
-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		self.userInteractionEnabled = YES;
		UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressAction)];
		gestureRecognizer.numberOfTapsRequired = 1;
		gestureRecognizer.numberOfTouchesRequired = 1;
		[self addGestureRecognizer:gestureRecognizer];
	}
	
	return self;
}

-(void)pressAction
{
	if (self.name.length > 0)
	{
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:self.name];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	[self removeFromSuperview];
}

@end



@implementation KYSegmentedControl
@synthesize currentSelectIndex = _currentSelectIndex, delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withCount:(NSInteger)count
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_currentSelectIndex = NSNotFound;
		_count = count;
		NSMutableArray* btnTempArr = [NSMutableArray array];
		CGFloat itemWidth = frame.size.width / count;
		for (int i = 0; i < count; i++)
		{
			CGRect rect = CGRectMake(i * itemWidth, 0, itemWidth, frame.size.height);
			UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
			[button addTarget:self action:@selector(segmentSelected:) forControlEvents:UIControlEventTouchUpInside];
			button.titleLabel.font = [UIFont systemFontOfSize:13.0f];
			button.frame = rect;
			button.tag = i;
			[self addSubview:button];
			[btnTempArr addObject:button];
		}
		_buttonsArr = [btnTempArr copy];
	}
	return self;
}

- (void)setCurrentSelectIndex:(NSInteger)currentSelectIndex
{
	for (int i = 0; i < _count; i++)
	{
		UIButton* button = [_buttonsArr objectAtIndex:i];
		if (i == currentSelectIndex)
		{
			if (_selImageArr.count >= i)
			{
				[button setBackgroundImage:[_selImageArr objectAtIndex:i] forState:UIControlStateNormal];
				[button setBackgroundImage:[_selImageArr objectAtIndex:i] forState:UIControlStateHighlighted];
			}
		}
		else if (_imageArr.count >= i)
		{
			[button setBackgroundImage:[_imageArr objectAtIndex:i] forState:UIControlStateNormal];
			[button setBackgroundImage:[_imageArr objectAtIndex:i] forState:UIControlStateHighlighted];
		}
	}
	
	_currentSelectIndex = currentSelectIndex;
}

- (void)setTitle:(NSString*)title forIndex:(NSInteger)index
{
	UIButton* button = (UIButton*)[_buttonsArr objectAtIndex:index];
	[button setTitle:title forState:UIControlStateNormal];
}


- (void)setImage:(NSArray*)imageArr
{
	_imageArr = imageArr;
}

- (void)setSelectedImage:(NSArray*)imageArr
{
	_selImageArr = imageArr;
}

- (void)segmentSelected:(id)sender
{
	UIButton* button = (UIButton*)sender;
	if (_currentSelectIndex == button.tag)
		return;
	
	self.currentSelectIndex = button.tag;
	[_delegate segmentValueChanged:self];
}
@end

@implementation KYLabFrameView
@synthesize backImageView = _backImageView, iconImageView = _iconImageView; 
@synthesize title = _title, subTitle = _subTitle, timeLable = _timeLable;
@synthesize isPortrait = _isPortrait;

- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isPortrait
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		self.image = [[UIImage imageNamed:@"lab_fram_view_shadow"] stretchableImageWithLeftCapWidth:50 topCapHeight:50];
		CGRect rect = self.bounds;
		rect.size.width -= 3;
		rect.size.height -= 5;
		_backImageView = [[UIImageView alloc] initWithFrame:rect];
		_backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_backImageView.clipsToBounds = YES;
		_backImageView.layer.cornerRadius = 4.0f;
		_backImageView.contentMode = UIViewContentModeTopLeft;
		_backImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:_backImageView];
		
		UIView* bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - 2, rect.size.width, 2)];
		bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		bottomLine.backgroundColor = [UIColor blackColor];
		bottomLine.alpha = 0.3f;
		[_backImageView addSubview:bottomLine];
		
		_iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
		_iconImageView.contentMode = UIViewContentModeCenter;
		_iconImageView.backgroundColor = [UIColor clearColor];
		[_backImageView addSubview:_iconImageView];
		
		_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 240, 30)];
		_title.backgroundColor = [UIColor clearColor];
		_title.font = [UIFont boldSystemFontOfSize:28.0f];
		_title.textAlignment = NSTextAlignmentLeft;
		_title.textColor = [UIColor whiteColor];
		_title.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_title.shadowOffset = CGSizeMake(0, 1);
		[_backImageView addSubview:_title];
		
		_subTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 25)];
		_subTitle.backgroundColor = [UIColor clearColor];
		_subTitle.font = [UIFont boldSystemFontOfSize:24.0f];
		_subTitle.textAlignment = NSTextAlignmentCenter;
		_subTitle.textColor = [UIColor whiteColor];
		_subTitle.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_subTitle.shadowOffset = CGSizeMake(0, 1);
		_subTitle.hidden = YES;
		[_backImageView addSubview:_subTitle];
		
		_timeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 15)];
		_timeLable.backgroundColor = [UIColor clearColor];
		_timeLable.font = [UIFont systemFontOfSize:14.0f];
		_timeLable.textAlignment = NSTextAlignmentLeft;
		_timeLable.textColor = [UIColor whiteColor];
		_timeLable.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_timeLable.shadowOffset = CGSizeMake(0, 1);
		[_backImageView addSubview:_timeLable];
		
//		[[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
//		[[self layer] setShadowOffset:CGSizeMake(2, 3)];
//		[[self layer] setShadowOpacity:0.4];
//		[[self layer] setShadowRadius:2];
		
		
		self.isPortrait = isPortrait;
	}
	return self;
}

- (void)setIsPortrait:(BOOL)isPortrait
{
	_isPortrait = isPortrait;
	CGRect rect = self.bounds;
	if (_isPortrait)
	{
		_backImageView.frame = CGRectMake(0, 0, rect.size.width - 3, rect.size.height - 4);
		_iconImageView.center = CGPointMake(rect.size.width / 2, 90);
		_title.center = CGPointMake(rect.size.width / 2, 235);
		_title.textAlignment = NSTextAlignmentCenter;
		
		_subTitle.center = CGPointMake(rect.size.width / 2, 185);
		
		_timeLable.center = CGPointMake(rect.size.width / 2, rect.size.height - 25);
		_timeLable.textAlignment = NSTextAlignmentCenter;
	}
	else 
	{
		_backImageView.frame = CGRectMake(0, 0, rect.size.width - 3, rect.size.height - 5);
		_iconImageView.center = CGPointMake(rect.size.width / 2, 125);
		
		_title.frame = CGRectMake(32, rect.size.height - 86, _title.frame.size.width, _title.frame.size.height);
		_title.textAlignment = NSTextAlignmentLeft;
		
		_subTitle.center = CGPointMake(rect.size.width / 2, 225);
		
		_timeLable.frame = CGRectMake(32, rect.size.height - 38, _title.frame.size.width, _title.frame.size.height);
		_timeLable.textAlignment = NSTextAlignmentLeft;
	}
}

@end

@implementation KYLabFrameView2
@synthesize backImageView = _backImageView, iconImageView = _iconImageView; 
@synthesize topLabel = _topLabel, bottomLabel = _bottomLabel, title = _title, countLabel = _countLabel, descripLabel = _descripLabel;
@synthesize isPortrait = _isPortrait;

- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isPortrait
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
		self.image = [[UIImage imageNamed:@"lab_fram_view_shadow"] stretchableImageWithLeftCapWidth:50 topCapHeight:50];
		CGRect rect = self.bounds;
		_backImageView = [[UIImageView alloc] initWithFrame:rect];
		_backImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_backImageView.clipsToBounds = YES;
		_backImageView.layer.cornerRadius = 4.0f;
		_backImageView.contentMode = UIViewContentModeTopRight;
		_backImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:_backImageView];
		
		UIView* bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - 2, rect.size.width, 2)];
		bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		bottomLine.backgroundColor = [UIColor blackColor];
		bottomLine.alpha = 0.3f;
		[_backImageView addSubview:bottomLine];
		
		_iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 120)];
		_iconImageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
		_iconImageView.contentMode = UIViewContentModeCenter;
		_iconImageView.backgroundColor = [UIColor clearColor];
		[_backImageView addSubview:_iconImageView];
		
		_topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
		_topLabel.backgroundColor = [UIColor clearColor];
		_topLabel.font = [UIFont boldSystemFontOfSize:24.0f];
		_topLabel.textAlignment = NSTextAlignmentLeft;
		_topLabel.textColor = [UIColor whiteColor];
		_topLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_topLabel.shadowOffset = CGSizeMake(0, 1);
		[_backImageView addSubview:_topLabel];
		
		_bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
		_bottomLabel.backgroundColor = [UIColor clearColor];
		_bottomLabel.font = [UIFont boldSystemFontOfSize:24.0f];
		_bottomLabel.textAlignment = NSTextAlignmentRight;
		_bottomLabel.textColor = [UIColor whiteColor];
		_bottomLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_bottomLabel.shadowOffset = CGSizeMake(0, 1);
		[_backImageView addSubview:_bottomLabel];
		
		_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
		_title.backgroundColor = [UIColor clearColor];
		_title.font = [UIFont boldSystemFontOfSize:28.0f];
		_title.textAlignment = NSTextAlignmentCenter;
		_title.textColor = [UIColor whiteColor];
		_title.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_title.shadowOffset = CGSizeMake(0, 1);
		[_backImageView addSubview:_title];
		
		_countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
		_countLabel.backgroundColor = [UIColor clearColor];
		_countLabel.font = [UIFont systemFontOfSize:14.0f];
		_countLabel.textAlignment = NSTextAlignmentCenter;
		_countLabel.textColor = [UIColor whiteColor];
		_countLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_countLabel.shadowOffset = CGSizeMake(0, 1);
		//_countLabel.hidden = YES;
		[_backImageView addSubview:_countLabel];
		
		_descripLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 15)];
		_descripLabel.backgroundColor = [UIColor clearColor];
		_descripLabel.font = [UIFont systemFontOfSize:14.0f];
		_descripLabel.textAlignment = NSTextAlignmentLeft;
		_descripLabel.textColor = [UIColor whiteColor];
		_descripLabel.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
		_descripLabel.shadowOffset = CGSizeMake(0, 1);
		[_backImageView addSubview:_descripLabel];
		
//		[[self layer] setShadowColor:[[UIColor blackColor] CGColor]];
//		[[self layer] setShadowOffset:CGSizeMake(2, 3)];
//		[[self layer] setShadowOpacity:0.4];
//		[[self layer] setShadowRadius:2];
		
		
		self.isPortrait = isPortrait;
	}
	return self;
}

- (void)setIsPortrait:(BOOL)isPortrait
{
	_isPortrait = isPortrait;
	CGRect rect = self.bounds;
	if (_isPortrait)
	{
		_backImageView.frame = CGRectMake(0, 0, rect.size.width - 3, rect.size.height - 5);
		_iconImageView.center = CGPointMake(rect.size.width / 2, 125);
		
		_topLabel.frame = CGRectMake(16, 270, _topLabel.frame.size.width, _topLabel.frame.size.height);
		
		_bottomLabel.frame = CGRectMake(224, rect.size.height - 74, _bottomLabel.frame.size.width, _bottomLabel.frame.size.height);
		
		_title.center = CGPointMake(rect.size.width / 2, rect.size.height - 112);
		
		_descripLabel.center = CGPointMake(rect.size.width / 2, rect.size.height - 25);
		_descripLabel.textAlignment = NSTextAlignmentCenter;
		
		_countLabel.frame = CGRectMake(120, _descripLabel.frame.origin.y, 30, _descripLabel.frame.size.height);
	}
	else 
	{
		_backImageView.frame = CGRectMake(0, 0, rect.size.width - 3, rect.size.height - 4);
		_iconImageView.center = CGPointMake(rect.size.width - 129, 115);
		
		_topLabel.frame = CGRectMake(32, 35, _topLabel.frame.size.width, _topLabel.frame.size.height);
		
		_bottomLabel.frame = CGRectMake(110, rect.size.height - 95, _bottomLabel.frame.size.width, _bottomLabel.frame.size.height);
		
		_title.center = CGPointMake(97, 112);
		
		_descripLabel.frame = CGRectMake(32, rect.size.height - 38, _descripLabel.frame.size.width, _descripLabel.frame.size.height);
		_descripLabel.textAlignment = NSTextAlignmentLeft;
		
		_countLabel.frame = CGRectMake(101, _descripLabel.frame.origin.y, 30, _descripLabel.frame.size.height);
	}
}
@end


#define DEGREES_TO_RADIANS(x) (M_PI * (x) / 180.0f)

@implementation KYCircleView

@synthesize circleColor = _circleColor;

-(id) initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
        self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCircleColor:(UIColor *)circleColor
{
	_circleColor = circleColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGPoint centerPoint = CGPointMake(rect.size.height / 2.0, rect.size.width / 2.0);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2.0 - 5.0;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    [_circleColor setFill];
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, 0, 2*M_PI, NO);
    CGContextFillPath(context);
    
    UIGraphicsPopContext();
}

@end

@interface KYProgressCircleView ()

@end

@implementation KYProgressCircleView

@synthesize progress = _progress;
@synthesize progressBarColor = _progressBarColor,progressBackgroundColor = _progressBackgroundColor;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(KYProgressCircleViewStyle)aStyle
{
    self = [super initWithFrame:frame];
	if (self)
	{
        self.backgroundColor = [UIColor clearColor];
        _style = aStyle;
	}
	return self;
}

-(void) setProgress:(float)progress
{
	_progress = progress;
	[self setNeedsDisplay];
}

- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor
{
	_progressBackgroundColor = progressBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setProgressBarColor:(UIColor *)progressBarColor
{
	_progressBarColor = progressBarColor;
    [self setNeedsDisplay];
}

- (void)updateProgress:(id)obj
{
    float tempProgress = self.progress+0.01;
    if (tempProgress > 1.0f) 
    {
        UIColor *tempColor = self.progressBackgroundColor;
        self.progressBackgroundColor = self.progressBarColor;
        self.progressBarColor = tempColor;

        tempProgress = 0.0f;
    }
    self.progress = tempProgress;
}

- (void)startAnimating
{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress:)];
    _displayLink.frameInterval = 1;
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)stopAnimating
{
    [_displayLink invalidate];
}

-(void) drawRect:(CGRect)rect
{
    CGPoint centerPoint = CGPointMake(rect.size.height / 2.0, rect.size.width / 2.0);
    CGFloat radius = MIN(rect.size.height, rect.size.width) / 2.0 - 5.0;
    float interval = 3.0;
    
    CGFloat minusRadians = DEGREES_TO_RADIANS((self.progress*360.0-interval)-90);
    CGFloat plusRadians = DEGREES_TO_RADIANS((self.progress*360.0+interval)-90);
    
    if ((self.progress*360.0-interval)-90 < -90+interval) 
        minusRadians = DEGREES_TO_RADIANS(-90+interval);
    if ((self.progress*360.0+interval)-90 > 270-interval) 
        plusRadians = DEGREES_TO_RADIANS(270-interval);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //    UIGraphicsPushContext(context);
    
    //    [self.layer renderInContext:context];
    //    self.layer.contentsScale = [UIScreen mainScreen].scale;
    //    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetAllowsAntialiasing(context, TRUE);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, DEGREES_TO_RADIANS(270-interval), DEGREES_TO_RADIANS(270+interval), 0);
    [[UIColor blackColor] setFill];
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, plusRadians, DEGREES_TO_RADIANS(270-interval), 0);
    [self.progressBackgroundColor setFill];
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, minusRadians, plusRadians, 0);
    [[UIColor blackColor] setFill];
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, centerPoint.x, centerPoint.y);
    CGContextAddArc(context, centerPoint.x, centerPoint.y, radius, DEGREES_TO_RADIANS(-90+interval), minusRadians, 0);
    [self.progressBarColor setFill];
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    CGContextBeginPath(context);
    if (_style == KYProgressCircleViewStyleProgress) 
        [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0] setFill];
    else
        CGContextSetBlendMode(context, kCGBlendModeClear);
    
    CGFloat innerRadius = radius * 0.75;
	CGPoint newCenterPoint = CGPointMake(centerPoint.x - innerRadius, centerPoint.y - innerRadius);    
	CGContextAddEllipseInRect(context, CGRectMake(newCenterPoint.x, newCenterPoint.y, innerRadius*2, innerRadius*2));
	CGContextClosePath(context);
    CGContextFillPath(context);
    
    if (_style == KYProgressCircleViewStyleProgress) 
    {
        [[UIColor grayColor] setFill];
        NSString *progressString = [[NSString alloc] initWithFormat:@"%d",(int)(self.progress*100)];
        UIFont *textFont = [UIFont boldSystemFontOfSize:13];
        CGSize textSize = [progressString sizeWithFont:textFont constrainedToSize:CGSizeMake(innerRadius*2, innerRadius*2) lineBreakMode:NSLineBreakByWordWrapping];
        [progressString drawInRect:CGRectMake(centerPoint.x-textSize.width/2.0, centerPoint.y-textSize.height/2.0, textSize.width, textSize.height) withFont:textFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];
    }
}



@end



@interface KYRunLabel()
- (void)noticeDelegate;
@end

@implementation KYRunLabel
@synthesize speed = _speed, repeat = _repeat, repeatTime = _repeatTime, textAlignment = _textAlignment, minTime = _minTime, finishDelayTime = _finishDelayTime, text = _text, font = _font, textColor = _textColor, delegate = _delegate, shadowColor = _shadowColor, shadowOffset = _shadowOffset, startWithOffset = _startWithOffset;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		self.clipsToBounds = YES;
		_startWithOffset = YES;
		_shouldRun = NO;
		_repeat = NO;
		_speed = 1.0f;
		_repeatTime = 1;
		_finishDelayTime = 1;
		_label = [[UILabel alloc] initWithFrame:self.bounds];
		_label.textAlignment = NSTextAlignmentLeft;
		_label.backgroundColor = [UIColor clearColor];
		[self addSubview:_label];
		self.textColor = [UIColor blackColor];
		self.font = [UIFont systemFontOfSize:18.0f];
	}
	return self;
}

- (void)dealloc
{
	_delegate = nil;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)setText:(NSString *)text
{
	NSString* temp = [text copy];
	_text = temp;
	[_label.layer removeAnimationForKey:@"notice_animate"];
	_label.frame = self.bounds;
	_label.textAlignment = self.textAlignment;
	
	_label.text = _text;
	CGFloat width = [_text sizeWithFont:_font constrainedToSize:CGSizeMake(CGFLOAT_MAX, self.bounds.size.height)].width;
	if (width > self.bounds.size.width)
	{
		_shouldRun = YES;
		_label.frame = CGRectMake(0, 0, width, _label.frame.size.height);
	}
	else
		_shouldRun = NO;
}

- (void)setTextAlignment:(UITextAlignment)textAlignment
{
	_textAlignment = textAlignment;
	_label.textAlignment = _textAlignment;
}

- (void)setFont:(UIFont *)font
{
	_font = font;
	_label.font = font;
}

- (void)setShadowColor:(UIColor *)shadowColor
{
	_shadowColor = shadowColor;
	_label.shadowColor = shadowColor;
}

- (void)setShadowOffset:(CGSize)shadowOffset
{
	_shadowOffset = shadowOffset;
	_label.shadowOffset = shadowOffset;
}

- (void)setTextColor:(UIColor *)textColor
{
	_textColor = textColor;
	_label.textColor = textColor;
}

- (void)startAnimate
{
	if (!_shouldRun)
	{
		[self performSelector:@selector(noticeDelegate) withObject:nil afterDelay:self.minTime];
		return;
	}
	
	CGFloat startPos = self.bounds.size.width / 5.0f;
	if (!_startWithOffset)
		startPos = 0;
	_duration = (_label.bounds.size.width - self.bounds.size.width + startPos) / (_speed * 50.0f);
	
	_label.textAlignment = NSTextAlignmentLeft;
	_label.frame = CGRectMake(0, 0, _label.frame.size.width, _label.frame.size.height);
	CGFloat offset = self.bounds.size.width - _label.bounds.size.width;
	
	CABasicAnimation *theAnimation;
	theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
	theAnimation.delegate = self;
	theAnimation.duration = _duration;
	theAnimation.repeatCount = 0;
	theAnimation.removedOnCompletion = FALSE;
	theAnimation.fillMode = kCAFillModeForwards;
	theAnimation.autoreverses = NO;
	theAnimation.fromValue = [NSNumber numberWithFloat:startPos];
	theAnimation.toValue = [NSNumber numberWithFloat:offset];
	[_label.layer addAnimation:theAnimation forKey:@"notice_animate"];
	
	_begin = [NSDate timeIntervalSinceReferenceDate];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
	if (_repeat)
	{
		[self performSelector:@selector(startAnimate) withObject:nil afterDelay:_repeatTime];
		return;
	}
		
	NSTimeInterval past = [NSDate timeIntervalSinceReferenceDate] - _begin;
	NSTimeInterval delay = _minTime - past;
	if (delay < _finishDelayTime)
		delay = _finishDelayTime;
	
	[self performSelector:@selector(noticeDelegate) withObject:nil afterDelay:delay];
}

- (void)noticeDelegate
{
	if ([_delegate respondsToSelector:@selector(runFinished)])
		[_delegate runFinished];
}
@end

