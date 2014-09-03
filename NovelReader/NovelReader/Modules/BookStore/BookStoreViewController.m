//
//  BookStoreViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "BookStoreViewController.h"
#import "MainTabViewController.h"
#import "Properties.h"
#import "UIHelper.h"
#import "SearchBookViewController.h"



@interface BookStoreViewController ()
{
}

@end



@implementation BookStoreViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		self.pageTitle = @"书城";
		NSInteger channel = CDProp(PropStoreChannel).intValue;
		self.pageURL = [NSString stringWithFormat:@"%@?gender=%d", [Properties appProperties].XLWebHost, (channel == 1 ? 1 : 0)];
	}
	return self;
}

-(void) dealloc
{
}

-(CDNavigationController*) cdNavigationController
{
	return _parent.cdNavigationController;
}

-(void) loadView
{
	[super loadView];
	
	[UIHelper setView:self.leftButton toWidth:86];
	[self.leftButton setImage:CDImage(@"store/channel") forState:UIControlStateNormal];
	self.leftButton.titleLabel.font = [UIFont systemFontOfSize:18.0f];
	[self.leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.leftButton setTitle:(CDProp(PropStoreChannel).intValue == 1 ? @"女频" : @"男频") forState:UIControlStateNormal];
	
	[self.rightButton setImage:CDImage(@"store/search") forState:UIControlStateNormal];
	self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15.0f);
	
	_webview.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
	_webview.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0);
}

-(void) leftButtonAction:(id)sender
{
	NSInteger channel = (CDProp(PropStoreChannel).intValue == 1 ? 0 : 1);
	CDSetProp(PropStoreChannel, ([NSString stringWithFormat:@"%d", channel]));
	[self.leftButton setTitle:(channel == 1 ? @"女频" : @"男频") forState:UIControlStateNormal];
	self.pageURL = [NSString stringWithFormat:@"%@?gender=%d", [Properties appProperties].XLWebHost, channel];
	[self reloadPage];
}

-(void) rightButtonAction:(id)sender
{
	SearchBookViewController* vc = [[SearchBookViewController alloc] init];
	[self.cdNavigationController pushViewController:vc];
}

@end

