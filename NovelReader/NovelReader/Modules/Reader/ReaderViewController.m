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
	UIPageViewController* _pageViewController;
	UIView* _containerView;
	UIView* _tapGestureView;
	UIView* _tabbarView;
	
	ReaderLayoutInfo* _layoutInfo;
	TextRenderContext* _textContext;
}

-(void) directoryAction:(UIButton*)sender;
-(void) progressAction:(UIButton*)sender;
-(void) fontAction:(UIButton*)sender;
-(void) brightnessAction:(UIButton*)sender;
-(void) nightModeAction:(UIButton*)sender;
-(void) toolbarAction:(UITapGestureRecognizer*)tgr;

-(void) adjustButton:(UIButton*)button;

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
	CGFloat tabbarHeight = 50.0f;
	
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
	
	_tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height, rect.size.width, tabbarHeight)];
	_tabbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	_tabbarView.backgroundColor = CDColor(nil, @"ffffffe5");
	
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
	
	[self loadBook];
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
	double d = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
	[[UIApplication sharedApplication] setStatusBarHidden:!showToolbar withAnimation:UIStatusBarAnimationFade];
	CGRect rect = self.view.bounds;
	[UIView animateWithDuration:d animations:^
	{
		[UIHelper moveView:self.naviBarView toY:(showToolbar ? (iOS7 ? 0 : 20) : -_naviBarHeight)];
		[UIHelper moveView:_tabbarView toY:rect.size.height-(showToolbar ? 50.0f : 0)];
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
}

-(void) fontAction:(UIButton*)sender
{
}

-(void) brightnessAction:(UIButton*)sender
{
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

-(void) loadBook
{
	[self.view showPopTitle:@"" msg:@"正在加载..."];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
	{
		@autoreleasepool
		{
			NSStringEncoding enc;
			NSError* error;
			NSString* text = [NSString stringWithContentsOfFile:_bookModel.path usedEncoding:&enc error:&error];
			_layoutInfo = [[ReaderLayoutInfo alloc] initWithText:text inContext:_textContext];
			dispatch_async(dispatch_get_main_queue(), ^
			{
				[self.view dismissMsg];
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



