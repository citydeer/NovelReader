//
//  ReaderViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-2.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"

@class XLBookModel;

@interface ReaderViewController : CDViewController

@property (nonatomic, strong) XLBookModel* bookModel;
@property (nonatomic, strong) NSString* chapterID;
@property (nonatomic, assign) NSInteger chapterLocation;

-(void) reloadContents;

@end

