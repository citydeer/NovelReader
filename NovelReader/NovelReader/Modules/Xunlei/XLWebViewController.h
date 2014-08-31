//
//  XLWebViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"


@interface XLWebViewController : CDViewController

@property (nonatomic, copy) NSString* headerTitle;
@property (nonatomic, copy) NSString* pageURL;
@property (nonatomic, strong) NSURLRequest* request;

@end

