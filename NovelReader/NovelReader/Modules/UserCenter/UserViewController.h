//
//  UserViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"


@class MainTabViewController;

@interface UserViewController : CDViewController

@property (nonatomic, weak) MainTabViewController* parent;

-(void) checkLoginInfo;

@end

