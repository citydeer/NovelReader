//
//  ReaderViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-2.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"

@class BookModel;

@interface ReaderViewController : CDViewController

@property (nonatomic, strong) BookModel* bookModel;

@end
