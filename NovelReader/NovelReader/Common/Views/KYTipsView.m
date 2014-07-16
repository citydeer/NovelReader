//
//  KYTipsView.m
//  Nemo
//
//  Created by zhihui zhao on 13-10-12.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "KYTipsView.h"
#import "Theme.h"



#define KYTipsMaxWidth  180
#define KYTipsShortDuration 0.2


static CGFloat const KYTipsViewTitleBottomSpace = 6;
static CGFloat const KYTipsViewSpace = 6;
static NSString* const KYTipsViewShowString = @"__show__";
static NSString* const KYTipsViewDismissString = @"__dismiss__";


@interface KYTipsView ()

@property (nonatomic, strong) KYTipsWindow*			window;
@property (nonatomic, strong) KYTipsContentView*	contentView;
@property (nonatomic, strong) NSString*				title;
@property (nonatomic, strong) NSString*				message;
@property (nonatomic, strong) KYBgIndicator*		indicator;
@property (nonatomic, assign) BOOL					visible;
@property (nonatomic, assign) CGRect				showRect;

- (void)createTipsWindow;
- (void)fillAndFitContentView;
- (void)show;
- (void)dismiss;
- (void)prepareForReuse;
- (void)handleNavigationSwitchNotification:(NSNotification *)notification;

@end



@implementation KYTipsView

@synthesize contentView = _contentView;

+ (instancetype)sharedTips
{
	static KYTipsView* __instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__instance = [[KYTipsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		__instance.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	});
	return __instance;
}

+ (void)showWithMessage:(NSString *)message timeout:(NSTimeInterval)timeout
{
	[[self class] showWithTitle:nil message:message timeout:timeout];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout
{
	KYTipsView* tipsView = [[KYTipsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	tipsView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
	tipsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tipsView.title = title;
	tipsView.message = message;
	tipsView.showRect = [UIScreen mainScreen].bounds;
	[tipsView show];
	
	[tipsView performSelector:@selector(dismiss) withObject:nil afterDelay:timeout];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message
{
	[[self class] showWithTitle:title message:message showRect:[UIScreen mainScreen].bounds];
}

+ (void)showWithTitle:(NSString *)title message:(NSString *)message showRect:(CGRect)rect
{
	if (!iOS7)
		rect.origin.y += 20;
	KYTipsView* tipsView = [KYTipsView sharedTips];
	tipsView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6];
	tipsView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	tipsView.title = title;
	tipsView.message = message;
	tipsView.indicator = nil;
	tipsView.showRect = rect;
	[tipsView show];
}

+ (void)showColorIndicator
{
	[[self class] showColorIndicatorWithTitle:nil message:nil];
}

+ (void)showColorIndicatorWithShowRect:(CGRect)rect
{
	[[self class] showColorIndicatorWithTitle:nil message:nil showRect:rect];
}

+ (void)showColorIndicatorWithTitle:(NSString *)title message:(NSString *)message
{
	[[self class] showColorIndicatorWithTitle:title message:message showRect:[UIScreen mainScreen].bounds];
}

+ (void)showColorIndicatorWithTitle:(NSString *)title message:(NSString *)message showRect:(CGRect)rect
{
	if (!iOS7)
		rect.origin.y += 20;
	KYTipsView* tipsView = [KYTipsView sharedTips];
	tipsView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
	tipsView.title = title;
	tipsView.message = message;
	tipsView.indicator = [[KYBgIndicator alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
	tipsView.contentView.backgroundColor = [UIColor clearColor];
	tipsView.showRect = rect;
	[tipsView show];
}

+ (void)dismiss
{
	[[KYTipsView sharedTips] dismiss];
}

+ (BOOL)isVisible
{
	return [[KYTipsView sharedTips] visible];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
	{
    }
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)createTipsWindow
{
	if (_window == nil)
	{
		_window = [[KYTipsWindow alloc] init];
//		_window.clipsToBounds = YES;
	}
	CGRect rect = self.showRect;
	self.frame = CGRectMake(0, 0, self.showRect.size.width, self.showRect.size.height);
	_window.frame = rect;
	_window.backgroundColor = [UIColor clearColor];
//	if (self.superview == nil)
//		[_window addSubview:self];
//	[_window makeKeyAndVisible];
	KYTipsViewController* tipsController = [[KYTipsViewController alloc] init];
	tipsController.view = self;
	_window.rootViewController = tipsController;
	_window.hidden = NO;
}

- (KYTipsContentView *)contentView
{
	if (_contentView == nil)
	{
		_contentView = [[KYTipsContentView alloc] init];
		_contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
		_contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		_contentView.layer.cornerRadius = 6.0;
		_contentView.layer.masksToBounds = YES;
	}
	return _contentView;
}

- (void)fillAndFitContentView
{
	if (self.contentView.superview == nil)
		[self addSubview:self.contentView];
	_contentView.title = self.title;
	_contentView.message = self.message;
	_contentView.indicator = self.indicator;
	[_contentView framesFitSize:self.bounds.size];
}

- (void)show
{
	[self createTipsWindow];
	[self fillAndFitContentView];
	_visible = YES;

	_contentView.layer.opacity = 0.0f;
	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.duration = KYTipsShortDuration;
	[_contentView.layer addAnimation:animation forKey:KYTipsViewShowString];
	
	[CATransaction commit];
	_contentView.layer.opacity = 1.0f;
	
	if (_contentView.indicator)
		[_contentView.indicator startAnimating];
}

- (void)dismiss
{
	_visible = NO;
	if (_contentView.indicator)
		[_contentView.indicator stopAnimating];

	[CATransaction begin];
	[CATransaction setDisableActions:YES];
	
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	animation.fromValue = @(1.0f);
    animation.toValue = @(0.0f);
    animation.duration = KYTipsShortDuration;
	[_contentView.layer addAnimation:animation forKey:KYTipsViewDismissString];
	
	[CATransaction commit];
	
//	NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
//	[windows removeObject:_window];
//	
//	[windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
//		if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
//			[window makeKeyWindow];
//			*stop = YES;
//		}
//	}];
	
	[self prepareForReuse];
}

- (void)prepareForReuse
{
	self.title = @"";
	self.message = @"";
	_contentView.title = @"";
	_contentView.message = @"";
	_contentView.indicator = nil;
	[_contentView.layer removeAllAnimations];
	_window.hidden = YES;
	_window = nil;
}

- (void)handleNavigationSwitchNotification:(NSNotification *)notification
{
	if (_visible)
		[self dismiss];
}

@end


#define kTipsMsgContentTag 912408
#define kTipsContentTag 912409
#define CGPointNull CGPointMake(0, 0)

@implementation UIView(UIViewExTips)

- (void)showPopTitle:(NSString *)title msg:(NSString *)msg
{
	[self showPopTitle:title msg:msg center:CGPointNull];
}

- (void)showPopTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center;
{
	[self showPopTitle:title msg:msg center:center shouldFreezeUI:NO];
}

- (void)showPopTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center shouldFreezeUI:(BOOL)freezeUI
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissMsg) object:nil];
	
	KYTipsContentView* contentView = (KYTipsContentView *)[self viewWithTag:kTipsMsgContentTag];
	if (contentView == nil)
	{
		contentView = [[KYTipsContentView alloc] init];
		contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
		contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		contentView.layer.cornerRadius = 6.0;
		contentView.layer.masksToBounds = YES;
		contentView.tag = kTipsMsgContentTag;
		contentView.userInteractionEnabled = NO;
		[self addSubview:contentView];
	}
	contentView.alpha = 1.0;
	contentView.title = title;
	contentView.message = msg;
	contentView.indicator = nil;
	[contentView framesFitSize:self.bounds.size];
	if (!CGPointEqualToPoint(center, CGPointNull))
		contentView.center = center;
	else
		contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
	
	self.userInteractionEnabled = !freezeUI;
}

- (void)showColorIndicatorWithTitle:(NSString *)title message:(NSString *)message
{
	[self showColorIndicatorWithTitle:title msg:message center:CGPointNull];
}

- (void)showColorIndicatorWithTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center
{
	[self showColorIndicatorWithTitle:title msg:msg center:center shouldFreezeUI:NO];
}

- (void)showColorIndicatorWithTitle:(NSString *)title msg:(NSString *)msg center:(CGPoint)center shouldFreezeUI:(BOOL)freezeUI
{
	KYTipsContentView* contentView = (KYTipsContentView *)[self viewWithTag:kTipsContentTag];
	if (contentView == nil)
	{
		contentView = [[KYTipsContentView alloc] init];
		contentView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0];
		contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
		contentView.layer.cornerRadius = 6.0;
		contentView.layer.masksToBounds = YES;
		contentView.tag = kTipsContentTag;
		[self addSubview:contentView];
	}
	contentView.alpha = 1.0;
	contentView.title = title;
	contentView.message = msg;
	contentView.indicator = [[KYBgIndicator alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
	CGSize size = [contentView framesFitSize:self.bounds.size];
	contentView.frame = CGRectMake(self.bounds.size.width/2.0 - size.width/2.0, self.bounds.size.height/2.0 - size.height/2.0, size.width, size.height);
	if (!CGPointEqualToPoint(center, CGPointNull))
		contentView.center = center;
	else
		contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
	
	[contentView.indicator startAnimating];
	self.userInteractionEnabled = !freezeUI;
}

- (void)showColorIndicatorFreezeUI:(BOOL)freezeUI
{
	[self showColorIndicatorWithTitle:nil msg:nil center:CGPointNull shouldFreezeUI:freezeUI];
}

- (void)showColorIndicatorWithCenter:(CGPoint)center
{
	[self showColorIndicatorWithTitle:nil msg:nil center:center];
}

- (void)dismissMsg
{
	KYTipsContentView* contentView = (KYTipsContentView *)[self viewWithTag:kTipsMsgContentTag];
	if (contentView != nil)
	{
		if (contentView.indicator)
		{
			[contentView.indicator stopAnimating];
			contentView.indicator = nil;
		}
		[contentView removeFromSuperview];
		self.userInteractionEnabled = YES;
	}
}

- (void)dismiss
{
	KYTipsContentView* contentView = (KYTipsContentView *)[self viewWithTag:kTipsContentTag];
	if (contentView != nil)
	{
		if (contentView.indicator)
		{
			[contentView.indicator stopAnimating];
			contentView.indicator = nil;
		}
		[contentView removeFromSuperview];
		self.userInteractionEnabled = YES;
	}
}

- (void)showPopTitle:(NSString *)title msg:(NSString *)msg timeout:(NSTimeInterval)timeout
{
	[self showPopTitle:title msg:msg];
	[self performSelector:@selector(dismissMsg) withObject:nil afterDelay:timeout];
}

- (void)showPopMsg:(NSString *)msg atY:(CGFloat)y timeout:(NSTimeInterval)timeout
{
	[self showPopTitle:nil msg:msg center:CGPointMake(self.bounds.size.width / 2.0f, y)];
	[self performSelector:@selector(dismissMsg) withObject:nil afterDelay:timeout];
}

- (void)showPopMsg:(NSString *)msg timeout:(NSTimeInterval)timeout
{
	[self showPopTitle:nil msg:msg timeout:timeout];
}

@end


@interface KYTipsContentView ()
@property (nonatomic, strong) UILabel*		titleLabel;
@property (nonatomic, strong) UILabel*		msgLabel;
@property (nonatomic, assign) UIEdgeInsets	edgeInsets;
- (CGFloat)maxWidth;
- (CGSize)sizeFitsLabel:(UILabel *)label;
@end

@implementation KYTipsContentView

- (id)init
{
	self = [super init];
	if (self) {
		_edgeInsets = UIEdgeInsetsMake(20, 18, 20, 18);
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_edgeInsets = UIEdgeInsetsMake(20, 18, 20, 18);
	}
	return self;
}

- (void)layoutSubviews
{
	
}

- (void)setTitle:(NSString *)title
{
	_title = title;
	if (title.length > 0)
	{
		if (_titleLabel == nil)
		{
			_titleLabel = [[UILabel alloc] init];
			_titleLabel.backgroundColor = [UIColor clearColor];
			_titleLabel.textAlignment = NSTextAlignmentCenter;
			_titleLabel.textColor = CDColor(@"UIViewPopTitleColor", @"ffffff");
			_titleLabel.font = [UIFont boldSystemFontOfSize:18];
			_titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
			_titleLabel.numberOfLines = 0;
			[self addSubview:_titleLabel];
		}
		_titleLabel.text = title;
	}
	else
	{
		if ([_titleLabel superview])
			[_titleLabel removeFromSuperview];
		_titleLabel = nil;
	}
}

- (void)setMessage:(NSString *)message
{
	_message = message;
	if (message.length > 0)
	{
		if (_msgLabel == nil)
		{
			_msgLabel = [[UILabel alloc] init];
			_msgLabel.backgroundColor = [UIColor clearColor];
			_msgLabel.textAlignment = NSTextAlignmentCenter;
			_msgLabel.textColor = CDColor(@"UIViewPopMessageColor", @"ffffff");
			_msgLabel.font = [UIFont boldSystemFontOfSize:16];
			_msgLabel.lineBreakMode = NSLineBreakByWordWrapping;
			_msgLabel.numberOfLines = 0;
			[self addSubview:_msgLabel];
		}
		_msgLabel.text = message;
	}
	else
	{
		if ([_msgLabel superview])
			[_msgLabel removeFromSuperview];
		_msgLabel = nil;
	}
}

- (void)setIndicator:(KYBgIndicator *)indicator
{
	[_indicator removeFromSuperview];
	if (indicator)
		[self addSubview:indicator];
	_indicator = indicator;
}

- (CGSize)framesFitSize:(CGSize)size
{
	CGSize titleSize = [self sizeFitsLabel:_titleLabel];
	CGSize msgSize = [self sizeFitsLabel:_msgLabel];
	CGSize indicatorSize = _indicator ? _indicator.frame.size:CGSizeZero;

	CGFloat width = 0.0f, height = 0.0f;
	width = titleSize.width < msgSize.width ? msgSize.width:titleSize.width;
	width = width < indicatorSize.width ? indicatorSize.width:width;
	width += _edgeInsets.left + _edgeInsets.right;
	
	height = _edgeInsets.top;
	if (_titleLabel)
	{
		_titleLabel.frame = CGRectMake(width/2.0 - titleSize.width/2.0, _edgeInsets.top, titleSize.width, titleSize.height);
		height += titleSize.height + KYTipsViewSpace;
	}
	if (_indicator)
	{
		_indicator.frame = CGRectMake(width/2.0 - indicatorSize.width/2.0, height, indicatorSize.width, indicatorSize.height);
		height += indicatorSize.height + KYTipsViewSpace;
	}
	if (_msgLabel)
	{
		_msgLabel.frame = CGRectMake(width/2.0 - msgSize.width/2.0, height, msgSize.width, msgSize.height);
		height += msgSize.height;
	}
	if (height == _edgeInsets.top)
		height = 0.0f;
	else
		height += _edgeInsets.bottom;
	
	self.bounds = CGRectMake(0, 0, width, height);
	self.center = CGPointMake(size.width/2.0, size.height/2.0);
	return CGSizeMake(width, height);
}

- (CGFloat)maxWidth
{
	NSString* stdStr = @"我";
	CGFloat maxWidth = [stdStr sizeWithFont:_titleLabel.font].width * 10;
	if (_msgLabel)
		maxWidth = [stdStr sizeWithFont:_msgLabel.font].width * 12;
	return maxWidth;
}

- (CGSize)sizeFitsLabel:(UILabel *)label
{
	if (label == nil)
		return CGSizeZero;
	CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake([self maxWidth], 1000) lineBreakMode:label.lineBreakMode];
	return size;
}

@end



@interface KYBgIndicator ()
@property (nonatomic, strong) UIView* bgView;
@property (nonatomic, strong) UIActivityIndicatorView* indicator;
@end

@implementation KYBgIndicator

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		_bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
		_bgView.layer.cornerRadius = frame.size.width/2.0;
		[self addSubview:_bgView];
		
		_indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.size.width/2.0 - 40/2.0, frame.size.height/2.0 - 40/2.0, 40, 40)];
		_indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		[self addSubview:_indicator];
	}
	return self;
}

- (void)startAnimating
{
	[_indicator startAnimating];
}

- (void)stopAnimating
{
	[_indicator stopAnimating];
}

- (void)dealloc
{
	_indicator = nil;
	_bgView = nil;
}

@end


@implementation KYTipsWindow

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		self.windowLevel = UIWindowLevelStatusBar;
	}
	return self;
}

@end



@interface KYTipsViewController ()
{
	KYTipsView*		_tipsView;
}
@end

@implementation KYTipsViewController

- (id)initWithView:(KYTipsView *)tipsView
{
	self = [super init];
	if (self) {
		_tipsView = tipsView;
	}
	return self;
}

- (void)loadView
{
	self.view = _tipsView;
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
		[self setNeedsStatusBarAppearanceUpdate];
}

- (void)setView:(UIView *)view
{
	[super setView:view];
	if ([self respondsToSelector:@selector(wantsFullScreenLayout)])
		[self wantsFullScreenLayout];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		return NO;
    else
		return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		return NO;
    else
		return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
		return UIInterfaceOrientationMaskPortrait;
	else
		return UIInterfaceOrientationMaskLandscape;
}

@end