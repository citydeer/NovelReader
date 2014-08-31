//
//  BookStoreViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLWebViewController.h"


@class MainTabViewController;

@interface BookStoreViewController : XLWebViewController

@property (nonatomic, weak) MainTabViewController* parent;

@end

