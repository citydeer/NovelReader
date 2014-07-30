//
//  MainTabViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "MainTabViewController.h"
#import "BookShelfViewController.h"
#import "BookStoreViewController.h"
#import "UserViewController.h"
#import "UIHelper.h"



@interface MainTabViewController ()
{
	UIViewController* _currentVC;
	UIView* _containerView;
	
	UIButton* _shelfButton;
	UIButton* _storeButton;
	UIButton* _userButton;
}

-(void) switchAction:(id)sender;
-(void) updateTabButtons;

@end



@implementation MainTabViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		_naviBarHeight = 0;
	}
	return self;
}

- (void)dealloc
{
}

- (void)loadView
{
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	CGRect rect = self.view.bounds;
	CGFloat navibarHeight = 44.0f;
	CGFloat tabbarHeight = 50.0f;
	
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, _statusBarHeight + navibarHeight, rect.size.width, rect.size.height - navibarHeight - tabbarHeight - _statusBarHeight)];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_containerView.backgroundColor = CDColor(nil, @"e7e7e7");
	[self.view addSubview:_containerView];
	
	UIView* tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - tabbarHeight, rect.size.width, tabbarHeight)];
	tabbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	tabbarView.backgroundColor = CDColor(nil, @"ffffffe5");
	
	UIView* av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5)];
	av.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	av.backgroundColor = CDColor(nil, @"a5a5a5");
	[tabbarView addSubview:av];
	
	_shelfButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320.0f/3.0f, tabbarHeight)];
	[_shelfButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 17, 0)];
	[_shelfButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	UILabel* label = [UIHelper label:@"本地书库" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, tabbarHeight-21, 320.0f/3.0f, 20)];
	[_shelfButton addSubview:label];
	[tabbarView addSubview:_shelfButton];
	
	_storeButton = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/3.0f, 0, 320.0f/3.0f, tabbarHeight)];
	[_storeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 17, 0)];
	[_storeButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	label = [UIHelper label:@"书城" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, tabbarHeight-21, 320.0f/3.0f, 20)];
	[_storeButton addSubview:label];
	[tabbarView addSubview:_storeButton];
	
	_userButton = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/3.0f*2.0f, 0, 320.0f/3.0f, tabbarHeight)];
	[_userButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 17, 0)];
	[_userButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	label = [UIHelper label:@"个人中心" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, tabbarHeight-21, 320.0f/3.0f, 20)];
	[_userButton addSubview:label];
	[tabbarView addSubview:_userButton];
	
	[self.view addSubview:tabbarView];
	
	[self switchAction:_shelfButton];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	[_currentVC willPresentView:duration];
}

-(void) didPresentView
{
	[super didPresentView];
	[_currentVC didPresentView];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	[_currentVC willDismissView:duration];
}

-(void) didDismissView
{
	[super didDismissView];
	[_currentVC didDismissView];
}

-(void) switchAction:(id)sender
{
	if (sender == _shelfButton && ![_currentVC isKindOfClass:[BookShelfViewController class]])
	{
		BookShelfViewController* vc = [[BookShelfViewController alloc] init];
		vc.parent = self;
		[self switchToController:vc];
	}
	else if (sender == _storeButton && ![_currentVC isKindOfClass:[BookStoreViewController class]])
	{
		BookStoreViewController* vc = [[BookStoreViewController alloc] init];
		vc.parent = self;
		[self switchToController:vc];
	}
	else if (sender == _userButton && ![_currentVC isKindOfClass:[UserViewController class]])
	{
		UserViewController* vc = [[UserViewController alloc] init];
		vc.parent = self;
		[self switchToController:vc];
	}
}

-(void) switchToController:(UIViewController*)newController
{
	if (newController == nil)
		return;
	
	if (_currentVC != newController)
	{
		CGRect rect = _containerView.bounds;
		newController.view.frame = rect;
		
		UIViewController* oldVC = _currentVC;
		_currentVC = newController;
		
		[oldVC willDismissView:0];
		[newController willPresentView:0];
		
		[_containerView addSubview:newController.view];
		[oldVC.view removeFromSuperview];
		newController.view.frame = rect;
		
		[newController didPresentView];
		[oldVC didDismissView];
		
		[self updateTabButtons];
	}
}

-(void) updateTabButtons
{
	UIImage* selectedBG = [CDImage(@"main/bar_selected") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
	
	if ([_currentVC isKindOfClass:[BookShelfViewController class]])
	{
		[_shelfButton setImage:CDImage(@"main/shelf2") forState:UIControlStateNormal];
		[_shelfButton setImage:CDImage(@"main/shelf2") forState:UIControlStateHighlighted];
		[_shelfButton setBackgroundImage:selectedBG forState:UIControlStateNormal];
		[_shelfButton setBackgroundImage:selectedBG forState:UIControlStateHighlighted];
	}
	else
	{
		[_shelfButton setImage:CDImage(@"main/shelf1") forState:UIControlStateNormal];
		[_shelfButton setImage:CDImage(@"main/shelf1") forState:UIControlStateHighlighted];
		[_shelfButton setBackgroundImage:nil forState:UIControlStateNormal];
		[_shelfButton setBackgroundImage:nil forState:UIControlStateHighlighted];
	}
	
	if ([_currentVC isKindOfClass:[BookStoreViewController class]])
	{
		[_storeButton setImage:CDImage(@"main/store2") forState:UIControlStateNormal];
		[_storeButton setImage:CDImage(@"main/store2") forState:UIControlStateHighlighted];
		[_storeButton setBackgroundImage:selectedBG forState:UIControlStateNormal];
		[_storeButton setBackgroundImage:selectedBG forState:UIControlStateHighlighted];
	}
	else
	{
		[_storeButton setImage:CDImage(@"main/store1") forState:UIControlStateNormal];
		[_storeButton setImage:CDImage(@"main/store1") forState:UIControlStateHighlighted];
		[_storeButton setBackgroundImage:nil forState:UIControlStateNormal];
		[_storeButton setBackgroundImage:nil forState:UIControlStateHighlighted];
	}
	
	if ([_currentVC isKindOfClass:[UserViewController class]])
	{
		[_userButton setImage:CDImage(@"main/user2") forState:UIControlStateNormal];
		[_userButton setImage:CDImage(@"main/user2") forState:UIControlStateHighlighted];
		[_userButton setBackgroundImage:selectedBG forState:UIControlStateNormal];
		[_userButton setBackgroundImage:selectedBG forState:UIControlStateHighlighted];
	}
	else
	{
		[_userButton setImage:CDImage(@"main/user1") forState:UIControlStateNormal];
		[_userButton setImage:CDImage(@"main/user1") forState:UIControlStateHighlighted];
		[_userButton setBackgroundImage:nil forState:UIControlStateNormal];
		[_userButton setBackgroundImage:nil forState:UIControlStateHighlighted];
	}
}

@end

