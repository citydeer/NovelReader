//
//  ReaderViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-2.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "ReaderViewController.h"
#import "UIHelper.h"
#import "Models.h"
#import "Properties.h"
#import "ReaderPageViewController.h"
#import "KYTipsView.h"



@interface ReaderViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
	double _duration;
	
	UIPageViewController* _pageViewController;
	UIView* _containerView;
	UIView* _tapGestureView;
	UIView* _tabbarView;
	
	ReaderLayoutInfo* _layoutInfo;
	TextRenderContext* _textContext;
	
	UIView* _brightnessToolbar;
	UISlider* _brightnessSlider;
	UIView* _brightnessView;
	
	UIView* _fontToolbar;
	
	UIView* _progressToolbar;
	UISlider* _progressSlider;
	UILabel* _progressLabel;
}

@property (readonly) ReaderPageViewController* currentPageController;

-(void) toolbarAction:(UITapGestureRecognizer*)tgr;

-(void) adjustButton:(UIButton*)button;
-(void) createToolbar;
-(void) createBrightnessToolbar;
-(void) createFontToolbar;
-(void) createProgressToolbar;

-(void) loadBook;

@end



@interface _TouchCancelView : UIView

@property (nonatomic, unsafe_unretained) id parent;

@end



@implementation ReaderViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		_textContext = [[TextRenderContext alloc] init];
		_duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

-(void) dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	[self.rightButton setImage:CDImage(@"reader/navi_bookmark1") forState:UIControlStateNormal];
	self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15.0f);
	
	self.titleLabel.text = _bookModel.name;
	
	[UIHelper moveView:self.naviBarView toY:-_naviBarHeight];
	
	CGRect rect = self.view.bounds;
	
	_textContext.pageSize = CGSizeMake(rect.size.width, rect.size.height - 20);
	
	_containerView = [[UIView alloc] initWithFrame:rect];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_containerView.backgroundColor = CDColor(nil, @"f6e6cd");
	[_containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarAction:)]];
	[self.view addSubview:_containerView];
	
	_pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	_pageViewController.doubleSided = NO;
	_pageViewController.dataSource = self;
	_pageViewController.delegate = self;
	_pageViewController.view.frame = _containerView.bounds;
	_pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_containerView addSubview:_pageViewController.view];
	
	_tapGestureView = [[_TouchCancelView alloc] initWithFrame:rect];
	_tapGestureView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	((_TouchCancelView*)_tapGestureView).parent = self;
	[self.view addSubview:_tapGestureView];
	_tapGestureView.hidden = YES;
	
	[self createToolbar];
	[self createProgressToolbar];
	[self createBrightnessToolbar];
	[self createFontToolbar];
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	_brightnessView = [[UIView alloc] initWithFrame:self.view.bounds];
	_brightnessView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_brightnessView.userInteractionEnabled = NO;
	_brightnessView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0f-CDProp(PropReaderBrightness).floatValue];
	[self.view addSubview:_brightnessView];
	
	[self loadBook];
}

-(void) createToolbar
{
	CGRect rect = self.view.bounds;
	CGFloat tabbarHeight = 50.0f;
	_tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, rect.size.width, tabbarHeight)];
	_tabbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_tabbarView.backgroundColor = CDColor(nil, @"e5ffffff");
	
	UIView* av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5f)];
	av.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	av.backgroundColor = CDColor(nil, @"a5a5a5");
	[_tabbarView addSubview:av];
	
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320.0f/5.0f, tabbarHeight)];
	[button addTarget:self action:@selector(directoryAction:) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:CDImage(@"reader/tabbar_directory1") forState:UIControlStateNormal];
	[button setImage:CDImage(@"reader/tabbar_directory2") forState:UIControlStateHighlighted];
	[button setTitle:@"目录" forState:UIControlStateNormal];
	[self adjustButton:button];
	[_tabbarView addSubview:button];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/5.0f, 0, 320.0f/5.0f, tabbarHeight)];
	[button addTarget:self action:@selector(progressAction:) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:CDImage(@"reader/tabbar_progress1") forState:UIControlStateNormal];
	[button setImage:CDImage(@"reader/tabbar_progress2") forState:UIControlStateHighlighted];
	[button setTitle:@"进度" forState:UIControlStateNormal];
	[self adjustButton:button];
	[_tabbarView addSubview:button];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/5.0f*2, 0, 320.0f/5.0f, tabbarHeight)];
	[button addTarget:self action:@selector(fontAction:) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:CDImage(@"reader/tabbar_font1") forState:UIControlStateNormal];
	[button setImage:CDImage(@"reader/tabbar_font2") forState:UIControlStateHighlighted];
	[button setTitle:@"字体" forState:UIControlStateNormal];
	[self adjustButton:button];
	[_tabbarView addSubview:button];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/5.0f*3, 0, 320.0f/5.0f, tabbarHeight)];
	[button addTarget:self action:@selector(brightnessAction:) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:CDImage(@"reader/tabbar_brightness1") forState:UIControlStateNormal];
	[button setImage:CDImage(@"reader/tabbar_brightness2") forState:UIControlStateHighlighted];
	[button setTitle:@"亮度" forState:UIControlStateNormal];
	[self adjustButton:button];
	[_tabbarView addSubview:button];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/5.0f*4, 0, 320.0f/5.0f, tabbarHeight)];
	[button addTarget:self action:@selector(nightModeAction:) forControlEvents:UIControlEventTouchUpInside];
	[button setImage:CDImage(@"reader/tabbar_night1") forState:UIControlStateNormal];
	[button setImage:CDImage(@"reader/tabbar_night2") forState:UIControlStateHighlighted];
	[button setTitle:@"夜间" forState:UIControlStateNormal];
	[self adjustButton:button];
	[_tabbarView addSubview:button];
	
	[self.view addSubview:_tabbarView];
}

-(void) createBrightnessToolbar
{
	CGRect rect = self.view.bounds;
	_brightnessToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, rect.size.width, 75)];
	_brightnessToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_brightnessToolbar.backgroundColor = CDColor(nil, @"e5ffffff");
	
	UIView* av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5f)];
	av.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	av.backgroundColor = CDColor(nil, @"a5a5a5");
	[_brightnessToolbar addSubview:av];
	
	_brightnessSlider = [[UISlider alloc] initWithFrame:CGRectMake(35, 0, 250, 10)];
	_brightnessSlider.center = CGPointMake(160, 37.5f);
	[_brightnessSlider setThumbImage:CDImage(@"reader/progressbar_thumb") forState:UIControlStateNormal];
	[_brightnessSlider setMinimumValueImage:CDImage(@"reader/brightdown")];
	[_brightnessSlider setMaximumValueImage:CDImage(@"reader/brightrise")];
	[_brightnessSlider setMinimumTrackTintColor:CDColor(nil, @"ec6400")];
	[_brightnessSlider setMaximumTrackTintColor:CDColor(nil, @"757575")];
	[_brightnessSlider addTarget:self action:@selector(onBrightnessChanged:) forControlEvents:UIControlEventValueChanged];
	[_brightnessSlider addTarget:self action:@selector(onBrightnessEnd:) forControlEvents:UIControlEventTouchUpInside];
	_brightnessSlider.maximumValue = 1.0f;
	_brightnessSlider.minimumValue = 0.3f;
	[_brightnessToolbar addSubview:_brightnessSlider];
	
	[self.view addSubview:_brightnessToolbar];
}

-(void) createFontToolbar
{
}

-(void) createProgressToolbar
{
	CGRect rect = self.view.bounds;
	_progressToolbar = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, rect.size.width, 75)];
	_progressToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_progressToolbar.backgroundColor = CDColor(nil, @"e5ffffff");
	
	UIView* av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5f)];
	av.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	av.backgroundColor = CDColor(nil, @"a5a5a5");
	[_progressToolbar addSubview:av];
	
	_progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(35, 0, 250, 10)];
	_progressSlider.center = CGPointMake(160, 37.5f);
	[_progressSlider setThumbImage:CDImage(@"reader/progressbar_thumb") forState:UIControlStateNormal];
	[_progressSlider setMinimumTrackTintColor:CDColor(nil, @"ec6400")];
	[_progressSlider setMaximumTrackTintColor:CDColor(nil, @"757575")];
	[_progressSlider addTarget:self action:@selector(onProgressChanged:) forControlEvents:UIControlEventValueChanged];
	[_progressSlider addTarget:self action:@selector(onProgressEnd:) forControlEvents:UIControlEventTouchUpInside];
	[_progressToolbar addSubview:_progressSlider];
	
	_progressLabel = [UIHelper label:nil tc:CDColor(nil, @"757575") fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, 0, rect.size.width, 28)];
	[_progressToolbar addSubview:_progressLabel];
	
	[self.view addSubview:_progressToolbar];
}

-(void) adjustButton:(UIButton*)button
{
	[button setTitleColor:CDColor(nil, @"5e5e5e") forState:UIControlStateNormal];
	[button setTitleColor:CDColor(nil, @"ec6400") forState:UIControlStateHighlighted];
	button.titleLabel.font = [UIFont systemFontOfSize:12.0f];
	
	CGSize sz = button.imageView.frame.size;
	button.titleEdgeInsets = UIEdgeInsetsMake(0, -sz.width, -sz.height-17, 0);
	sz = button.titleLabel.frame.size;
	button.imageEdgeInsets = UIEdgeInsetsMake(-sz.height+4, 0, 0, -sz.width);
}

-(void) toolbarAction:(UITapGestureRecognizer*)tgr
{
	BOOL showToolbar = (tgr != nil);
	_tapGestureView.hidden = !showToolbar;
	[[UIApplication sharedApplication] setStatusBarHidden:!showToolbar withAnimation:UIStatusBarAnimationFade];
	CGRect rect = self.view.bounds;
	[UIView animateWithDuration:_duration animations:^
	{
		if (showToolbar)
		{
			[UIHelper moveView:self.naviBarView toY:(iOS7 ? 0 : 20)];
			[UIHelper moveView:_tabbarView toY:rect.size.height-_tabbarView.frame.size.height];
		}
		else
		{
			[UIHelper moveView:self.naviBarView toY:-_naviBarHeight];
			[UIHelper moveView:_tabbarView toY:rect.size.height];
			[UIHelper moveView:_brightnessToolbar toY:rect.size.height];
			[UIHelper moveView:_fontToolbar toY:rect.size.height];
			[UIHelper moveView:_progressToolbar toY:rect.size.height];
		}
	}];
}

-(void) rightButtonAction:(id)sender
{
}

-(void) directoryAction:(UIButton*)sender
{
}

-(void) progressAction:(UIButton*)sender
{
	NSUInteger currentIndex = self.currentPageController.pageIndex;
	NSUInteger allPage = _layoutInfo.pages.count;
	_progressLabel.text = [NSString stringWithFormat:@"%d/%d", currentIndex+1, allPage];
	_progressSlider.value = (allPage <= 1 ? 1.0f : ((float)currentIndex / (float)(allPage - 1)));
	CGRect rect = self.view.bounds;
	[UIView animateWithDuration:_duration animations:^
	 {
		 [UIHelper moveView:_progressToolbar toY:rect.size.height-_progressToolbar.frame.size.height];
		 [UIHelper moveView:_tabbarView toY:rect.size.height];
	 }];
}

-(void) onProgressChanged:(UISlider*)sender
{
	NSUInteger allPage = _layoutInfo.pages.count;
	if (allPage <= 1)
		return;
	
	NSUInteger currentIndex = self.currentPageController.pageIndex;
	NSUInteger newIndex = roundf((allPage - 1) * sender.value);
	if (currentIndex == newIndex)
		return;
	
	_progressLabel.text = [NSString stringWithFormat:@"%d/%d", newIndex+1, allPage];
	
	UIPageViewControllerNavigationDirection d = currentIndex < newIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
	ReaderPageViewController* pvc = [[ReaderPageViewController alloc] init];
	pvc.layoutInfo = _layoutInfo;
	pvc.pageIndex = newIndex;
	[_pageViewController setViewControllers:[NSArray arrayWithObject:pvc] direction:d animated:YES completion:NULL];
}

-(void) onProgressEnd:(UISlider*)sender
{
}

-(void) fontAction:(UIButton*)sender
{
}

-(void) brightnessAction:(UIButton*)sender
{
	_brightnessSlider.value = CDProp(PropReaderBrightness).floatValue;
	CGRect rect = self.view.bounds;
	[UIView animateWithDuration:_duration animations:^
	{
		[UIHelper moveView:_brightnessToolbar toY:rect.size.height-_brightnessToolbar.frame.size.height];
		[UIHelper moveView:_tabbarView toY:rect.size.height];
	}];
}

-(void) onBrightnessChanged:(UISlider*)sender
{
	_brightnessView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0f-sender.value];
}

-(void) onBrightnessEnd:(UISlider*)sender
{
	_brightnessView.backgroundColor = [UIColor colorWithWhite:0 alpha:1.0f-sender.value];
	NSString* v = [NSString stringWithFormat:@"%f", sender.value];
	CDSetProp(PropReaderBrightness, v);
}

-(void) nightModeAction:(UIButton*)sender
{
}

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	NSUInteger index = ((ReaderPageViewController*)viewController).pageIndex;
	if (index > 0)
	{
		ReaderPageViewController* pvc = [[ReaderPageViewController alloc] init];
		pvc.layoutInfo = _layoutInfo;
		pvc.pageIndex = index - 1;
		return pvc;
	}
	return nil;
}

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	NSUInteger index = ((ReaderPageViewController*)viewController).pageIndex;
	if (index + 1 < _layoutInfo.pages.count)
	{
		ReaderPageViewController* pvc = [[ReaderPageViewController alloc] init];
		pvc.layoutInfo = _layoutInfo;
		pvc.pageIndex = index + 1;
		return pvc;
	}
	return nil;
}

-(ReaderPageViewController*) currentPageController
{
	if (_pageViewController.viewControllers.count > 0)
		return [_pageViewController.viewControllers objectAtIndex:0];
	return nil;
}

-(void) loadBook
{
	[self.view showColorIndicatorFreezeUI:NO];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@autoreleasepool {
			NSStringEncoding enc;
			NSError* error;
			NSString* text = [NSString stringWithContentsOfFile:_bookModel.path usedEncoding:&enc error:&error];
			_layoutInfo = [[ReaderLayoutInfo alloc] initWithText:text inContext:_textContext];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.view dismiss];
				if (_layoutInfo.pages.count > 0)
				{
					ReaderPageViewController* pvc = [[ReaderPageViewController alloc] init];
					pvc.layoutInfo = _layoutInfo;
					pvc.pageIndex = 0;
					[_pageViewController setViewControllers:[NSArray arrayWithObject:pvc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
				}
			});
		}
	});
}

@end




@implementation _TouchCancelView

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_parent toolbarAction:nil];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[_parent toolbarAction:nil];
}

@end



