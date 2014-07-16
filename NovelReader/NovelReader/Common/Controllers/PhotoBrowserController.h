//
//  PhotoBrowserController.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-30.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "CDViewController.h"


typedef enum
{
	BrowserTypeRead = 0,
	BrowserTypeWeibo
}
BrowserType;


@interface PhotoBrowserController : CDViewController

@property (nonatomic, strong) NSArray* imgUrlArr;
@property (nonatomic, assign) NSInteger imageIndex;
@property (nonatomic, assign) CGRect originFrame;
@property (nonatomic, strong) NSString* referUrl;
@property (nonatomic, strong) UIImage* singleImage;

-(id) initWithChannelType:(BrowserType)type;

@end

