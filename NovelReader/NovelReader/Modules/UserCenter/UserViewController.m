//
//  UserViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "UserViewController.h"
#import "MainTabViewController.h"



@interface UserViewController ()
{
}

@end



@implementation UserViewController

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
	
	self.titleLabel.text = @"个人中心";
}

@end

