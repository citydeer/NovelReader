//
//  XLLoginViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-28.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"


@interface XLLoginViewController : CDViewController

-(void) setSuccessBlock:(void (^)(void))block;

@end
