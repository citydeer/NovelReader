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



@interface ReaderViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
{
	UIPageViewController* _pageViewController;
	UIView* _containerView;
	UIView* _tabbarView;
	
	BOOL _showToolbar;
}

-(void) directoryAction:(UIButton*)sender;
-(void) progressAction:(UIButton*)sender;
-(void) fontAction:(UIButton*)sender;
-(void) brightnessAction:(UIButton*)sender;
-(void) nightModeAction:(UIButton*)sender;
-(void) tapAction:(UITapGestureRecognizer*)tgr;

-(void) adjustButton:(UIButton*)button;

@end



@implementation ReaderViewController

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
}

-(void) loadView
{
	[super loadView];
	
	self.view.backgroundColor = [UIColor yellowColor];
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	[self.rightButton setImage:CDImage(@"reader/navi_bookmark1") forState:UIControlStateNormal];
	self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15.0f);
	
	self.titleLabel.text = @"绝世神王";
	
	[UIHelper moveView:self.naviBarView toY:-_naviBarHeight];
	
	CGRect rect = self.view.bounds;
	CGFloat tabbarHeight = 50.0f;
	
	_containerView = [[UIView alloc] initWithFrame:rect];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_containerView.backgroundColor = CDColor(nil, @"f6e6cd");
	[_containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
	[self.view addSubview:_containerView];
	
	_pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
	_pageViewController.doubleSided = YES;
	[_pageViewController setViewControllers:[NSArray arrayWithObject:[[ReaderPageViewController alloc] init]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
	_pageViewController.dataSource = self;
	_pageViewController.delegate = self;
	_pageViewController.view.frame = _containerView.bounds;
	_pageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[_containerView addSubview:_pageViewController.view];
	
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

-(void) tapAction:(UITapGestureRecognizer*)tgr
{
	_showToolbar = !_showToolbar;
	double d = 0.2;
	CGRect rect = self.view.bounds;
	[UIView animateWithDuration:d animations:^
	{
		[UIHelper moveView:self.naviBarView toY:(_showToolbar ? 0 : -_naviBarHeight)];
		[UIHelper moveView:_tabbarView toY:rect.size.height-(_showToolbar ? 50.0f : 0)];
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
	return [[ReaderPageViewController alloc] init];
}

-(UIViewController*) pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	return [[ReaderPageViewController alloc] init];
}

@end

