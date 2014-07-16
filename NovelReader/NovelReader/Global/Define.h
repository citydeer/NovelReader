//
//  Define.h
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-2.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#ifndef CostPalmGear_Define_h
#define CostPalmGear_Define_h


#import "Logger.h"


#define CDLocalizedString(key, defaultValue) [[NSBundle mainBundle] localizedStringForKey:(key) value:(defaultValue) table:nil]
#define MakeStringNotNull(str) ((str) == nil ? @"" : (str))
#define iOS7 ([[UIDevice currentDevice].systemVersion intValue] >= 7)
#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define TabBarHeight 55

#endif
