//
//  XLWebViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLWebViewController.h"



@interface XLWebViewController ()
{
	UIWebView* _webview;
}

@end



@implementation XLWebViewController

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
	
	self.titleLabel.text = @"书城";
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	[self.rightButton setImage:CDImage(@"shelf/navi_menu1") forState:UIControlStateNormal];
}

@end

