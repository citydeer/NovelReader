//
//  DirectoryViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-14.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"


@class XLBookModel, ReaderViewController;

@interface DirectoryViewController : CDViewController

@property (nonatomic, weak) ReaderViewController* parent;
@property (nonatomic, strong) XLBookModel* bookModel;

@end

