//
//  ReaderPageViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "ReaderLayoutInfo.h"


@interface ReaderPageViewController : UIViewController

@property (nonatomic, strong) ReaderLayoutInfo* layoutInfo;
@property (nonatomic, assign) NSUInteger pageIndex;

@end

