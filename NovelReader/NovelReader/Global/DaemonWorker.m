//
//  DaemonWorker.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-8.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "DaemonWorker.h"
#import "RestfulAPIGetter.h"
#import "Models.h"
#import "Properties.h"
#import "CDNavigationController.h"
#import "XLLoginViewController.h"



@interface DaemonWorker () <GetterControllerOwner, UIAlertViewDelegate>

@property (nonatomic, copy) NSString* updateURL;

@end



@implementation DaemonWorker

+(DaemonWorker*) worker
{
	static DaemonWorker* _instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[DaemonWorker alloc] init];
	});
	return _instance;
}

-(id) init
{
	self = [super init];
	if (self)
	{
		_getterController = [[GetterController alloc] initWithOwner:self];
	}
	return self;
}

#define GetUpdateInfoTag 1
#define GetRecommendBookTag 2

-(void) checkAppUpdateInfo:(BOOL)showAlert
{
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"site", @"a" : @"upgrade", @"os" : @"2", @"channel" : @""};
	getter.tag = GetUpdateInfoTag;
	getter.userData = (showAlert ? @"1" : @"0");
	[_getterController enqueueGetter:getter];
}

-(void) getRecommendBooks
{
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"site", @"a" : @"apprecommend"};
	getter.tag = GetRecommendBookTag;
	[_getterController enqueueGetter:getter];
}

-(void) handleGetter:(id<Getter>)getter
{
	if (getter.tag == GetUpdateInfoTag)
	{
		if ([Model checkGetter:getter onView:getNaviController().view showMsg:nil])
		{
			AppInfoModel* model = [[AppInfoModel alloc] initWithDictionary:((RestfulAPIGetter*)getter).result[@"data"]];
			CDSetProp(PropAppCommentURL, model.commurl);
			if ([@"1" isEqualToString:(NSString*)getter.userData])
			{
				if (model.isupdate)
				{
					self.updateURL = model.downurl;
					UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"检测到新版本，是否更新?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
					[alert show];
				}
				else
				{
					UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"已经是最新版本了" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
					[alert show];
				}
			}
		}
	}
	else if (getter.tag == GetRecommendBookTag)
	{
		if (getter.resultCode == KYResultCodeSuccess)
		{
			NSArray* books = ((RestfulAPIGetter*)getter).result[@"data"];
			CDSetProp(PropAppStartBooks, books);
		}
	}
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateURL]];
	}
}

-(void) checkLoginStatus:(void (^)(void))block
{
	BOOL isLogined = (CDProp(PropUserID) != nil);
	if (isLogined)
	{
		if (block != NULL)
			block();
	}
	else
	{
		XLLoginViewController* vc = [[XLLoginViewController alloc] init];
		[vc setSuccessBlock:block];
		[getNaviController() pushViewController:vc];
	}
}

@end

