//
//  ReaderPageViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "ReaderLayoutInfo.h"


@class XLChapterModel, XLBookModel;

@interface ReaderPageViewController : UIViewController

@property (readonly) BOOL isViewReady;

@property (nonatomic, strong) XLBookModel* bookModel;
@property (nonatomic, strong) XLChapterModel* chapterModel;

@property (nonatomic, strong) TextRenderContext* textContext;
@property (nonatomic, strong) ReaderLayoutInfo* layoutInfo;
@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, strong) UIColor* bgColor;
@property (nonatomic, assign) BOOL defaultLastIndex;

@end


