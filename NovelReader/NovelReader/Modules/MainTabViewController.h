//
//  MainTabViewController.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDViewController.h"


@interface MainTabViewController : CDViewController

@property (nonatomic, assign) NSUInteger currentIndex;

-(void) switchToController:(UIViewController*)newController;

@end

