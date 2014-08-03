//
//  ReaderPageViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "ReaderPageViewController.h"
#import "Theme.h"


@implementation ReaderPageViewController

-(id) init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

-(void) loadView
{
	[super loadView];
	
	self.view.backgroundColor = CDColor(nil, @"f6e6cd");
}

@end

