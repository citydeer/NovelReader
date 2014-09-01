//
//  Properties.m
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-2.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "Properties.h"


@interface Properties ()
{
	NSMutableDictionary* _dic;
}
@end


@implementation Properties

+(Properties*) appProperties
{
	static Properties* _instance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[Properties alloc] init];
	});
	return _instance;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		_dic = [[NSMutableDictionary alloc] initWithCapacity:0];
		
		_APIHost = @"http://123.150.216.141/apper";
//		_APIHost = @"http://yuedu.xunlei.com/apper";
//		_APIHost = @"http://test.yuedu.xunlei.com/apper";
		
		_XLMemberAppID = 60;
		
		_APPVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
		
		_minVerifyInterval = 60.0;
	}
	return self;
}

-(id) propertyForKey:(NSString*)key
{
	id prop = [_dic objectForKey:key];
	if (prop == nil)
	{
		prop = [[NSUserDefaults standardUserDefaults] objectForKey:key];
		if (prop != nil)
			[_dic setObject:prop forKey:key];
	}
	return prop;
}

-(void) setProperty:(id)property forKey:(NSString *)key
{
	if (property == nil)
	{
		[_dic removeObjectForKey:key];
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	else
	{
		[_dic setObject:property forKey:key];
		[[NSUserDefaults standardUserDefaults] setObject:property forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}

@end
