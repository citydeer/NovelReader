//
//  BookStoreViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"


@class MainTabViewController;

@interface BookStoreViewController : CDViewController

@property (nonatomic, weak) MainTabViewController* parent;

@end

