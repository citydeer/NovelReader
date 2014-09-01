//
//  CDViewController.m
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-15.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "CDViewController.h"


NSString* const kCDChangeSkinNotification = @"CDShouldChangeSkinNotice";

#define DefaultNaviBarHeight 44.0f

@interface CDViewController ()
@property (nonatomic, strong) UIButton*	retryBtn;
@property (nonatomic, strong) UIView*	retryMaskView;
@end


@implementation CDViewController

@synthesize leftButton = _leftButton;
@synthesize rightButton = _rightButton;
@synthesize titleLabel = _titleLabel;
@synthesize blurColor = _blurColor;
@synthesize viewFrame = _viewFrame;

-(id) init
{
	self = [super init];
	if (self)
	{
		_blurColor = CDColor(nil, @"f5c068");
		if (iOS7)
			_statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
		else
			_statusBarHeight = 0.0;
		_naviBarHeight = DefaultNaviBarHeight + _statusBarHeight;
		_viewFrame = [UIScreen mainScreen].applicationFrame;
		_viewFrame.size.height += _statusBarHeight;
		_viewFrame.origin.y = 0;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldChangeSkin:) name:kCDChangeSkinNotification object:nil];
	}
	return self;
}

-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	NSLog(@"%@ released!", NSStringFromClass(self.class));
}

-(void) loadView
{
	self.view = [[UIView alloc] initWithFrame:_viewFrame];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	CGRect rect = self.view.bounds;
	
	if (_naviBarHeight > 0.0f)
	{
		_naviBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, _naviBarHeight)];
		_naviBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
//		_naviBarView.layer.contents = (id)CDImage(@"navi_background").CGImage;
		_naviBarView.backgroundColor = CDColor(nil, @"#ec6400");
		
//		CGFloat height = 2;
//		_naviBarShadowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_naviBarView.frame), CGRectGetWidth(_naviBarView.frame), height)];
//		_naviBarShadowView.image = CDImage(@"Home/home_cell_seperator");
//		_naviBarShadowView.hidden = NO;
//		[_naviBarView addSubview:_naviBarShadowView];
		
		[self.view addSubview:_naviBarView];
		_naviBarView.hidden = _naviBarHidden;
	}
	
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
		[self setNeedsStatusBarAppearanceUpdate];
}

- (void)setBlurColor:(UIColor *)blurColor
{
	_blurColor = blurColor;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	if (_naviBarHeight > 0.0)
		[self.view bringSubviewToFront:_naviBarView];
}

-(void) viewDidUnload
{
	LOG_debug(@"View did unload on: %@.", [[self class] description]);
	_rightButton = nil;
	_leftButton = nil;
	_titleLabel = nil;
	_naviBarView = nil;
	_naviBarShadowView = nil;
	[super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
//	_rightButton = nil;
//	_leftButton = nil;
//	_titleLabel = nil;
//	_naviBarView = nil;
//	_naviBarShadowView = nil;
	[super didReceiveMemoryWarning];
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

-(UIButton*) leftButton
{
	if (_leftButton == nil)
	{
		if (_naviBarHeight > 0.0f)
		{
			_leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _statusBarHeight, 60.0f, _naviBarHeight - _statusBarHeight)];
			_leftButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
			_leftButton.showsTouchWhenHighlighted = YES;
			[_leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			[self.naviBarView addSubview:_leftButton];
		}
	}
	return _leftButton;
}

-(UIButton*) rightButton
{
	if (_rightButton == nil)
	{
		if (_naviBarHeight > 0.0f)
		{
			CGRect rect = self.naviBarView.bounds;
			_rightButton = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width - 60.0f, _statusBarHeight, 60.0f, _naviBarHeight - _statusBarHeight)];
			_rightButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
			_rightButton.showsTouchWhenHighlighted = YES;
			[_rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
			[self.naviBarView addSubview:_rightButton];
		}
	}
	return _rightButton;
}

-(UILabel*) titleLabel
{
	if (_titleLabel == nil)
	{
		if (_naviBarHeight > 0.0f)
		{
			CGRect rect = self.naviBarView.bounds;
			_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, _statusBarHeight, rect.size.width - 100, _naviBarHeight - _statusBarHeight)];
			_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth ;
			_titleLabel.backgroundColor = [UIColor clearColor];
			_titleLabel.textColor = [UIColor whiteColor];
			_titleLabel.textAlignment = NSTextAlignmentCenter;
			_titleLabel.font = [UIFont systemFontOfSize:18.0f];
			[self.naviBarView addSubview:_titleLabel];
		}
	}
	return _titleLabel;
}

-(void) setNaviBarHidden:(BOOL)naviBarHidden
{
	[self setNaviBarHidden:naviBarHidden animated:NO];
}

-(void) setNaviBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	if (hidden != _naviBarHidden)
	{
        if (![self isViewLoaded] || _naviBarHeight <= 0.0f) {
            return;
        }
        
        CGFloat width = self.view.bounds.size.width;
        
        if (animated) {
            if (hidden) {
                [UIView animateWithDuration:0.35f
                                 animations:^ {
                                     _naviBarView.frame = CGRectMake(0, 0 -_naviBarHeight, width, _naviBarHeight);
                                 }
                                 completion:^ (BOOL finished) {
                                     _naviBarHidden = finished;
                                 }];

            } else {
                [UIView animateWithDuration:0.35f
                                 animations:^ {
                                     _naviBarView.frame = CGRectMake(0, 0, width, _naviBarHeight);
                                 }
                                 completion:^ (BOOL finished) {
                                     _naviBarHidden = !finished;
                                 }];
            }
        } else {
            if (hidden) {
                _naviBarView.frame = CGRectMake(0, 0 - _naviBarHeight, width, _naviBarHeight);
                _naviBarHidden = YES;
            } else {
                _naviBarView.frame = CGRectMake(0, 0, width, _naviBarHeight);
                _naviBarHidden = NO;
            }
        }
	}
}

-(void) shouldChangeSkin:(id)sender
{
	if (self.isViewLoaded)
	{
		if (self.view.window == nil)
		{
			self.view = nil;
		}
		else
		{
			// Change naviBarView and titleLabel
		}
	}
	[self didChangeSkin];
}

-(void) leftButtonAction:(id)sender
{
	if (self.cdNavigationController)
		[self.cdNavigationController popViewController];
	else
		[self.navigationController popViewControllerAnimated:YES];
}

-(void) rightButtonAction:(id)sender
{
}

-(void) didChangeSkin
{
}

-(void) showRetryBtnOnMaskViewWithMsg:(NSString *)msg
{
	CGSize msgSize = [msg sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(180, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
	msgSize.height += 20;
	if (_retryMaskView == nil)
	{
		_retryMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, _naviBarHeight, CGRectGetWidth(self.view.frame),CGRectGetHeight(self.view.frame) - _naviBarHeight)];
		_retryMaskView.backgroundColor = CDColor(nil, @"00000000");
		[self.view addSubview:_retryMaskView];
	}
	
	if (_retryBtn == nil)
	{
		_retryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_retryBtn.frame = CGRectMake(CGRectGetWidth(_retryMaskView.frame)/2.0 - 180/2.0, CGRectGetHeight(_retryMaskView.frame)/2.0 - msgSize.height/2.0, 180, msgSize.height);
		_retryBtn.backgroundColor = CDColor(@"common_retry_btn", @"efb252");
		_retryBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
		_retryBtn.titleLabel.font = [UIFont systemFontOfSize:14];
		_retryBtn.titleLabel.numberOfLines = 0;
		[_retryBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_retryBtn addTarget:self action:@selector(_retryAction) forControlEvents:UIControlEventTouchUpInside];
		[_retryMaskView addSubview:_retryBtn];
	}
	_retryBtn.frame = CGRectMake(CGRectGetWidth(_retryMaskView.frame)/2.0 - 180/2.0, CGRectGetHeight(_retryMaskView.frame)/2.0 - msgSize.height/2.0, 180, msgSize.height);
	[_retryBtn setTitle:msg forState:UIControlStateNormal];
	_retryBtn.hidden = NO;
	[self.view bringSubviewToFront:_retryMaskView];
	
	_retryMaskView.alpha = 0.0;
	_retryMaskView.hidden = NO;
	[UIView animateWithDuration:0.2 animations:^{
		_retryMaskView.alpha = 1.0;
	} completion:^(BOOL finished) {}];
}

-(void) hideMaskView
{
	if (_retryMaskView)
	{
		[_retryBtn removeFromSuperview];
		self.retryBtn = nil;
		[_retryMaskView removeFromSuperview];
		self.retryMaskView = nil;
	}
}

-(void) _retryAction
{
}

@end
