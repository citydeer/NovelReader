//
//  AppDelegate.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-16.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "AppDelegate.h"
#import "Properties.h"
#import "MainTabViewController.h"
#import "Models.h"



@interface AppDelegate ()
{
	CDNavigationController* _navigationController;
}

-(void) loadProperties;
-(void) createControllers;

@end



@implementation AppDelegate

void uncaughtExceptionHandler(NSException *exception)
{
	NSLog(@"CRASH: %@", exception);
	NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[self loadProperties];
	[self createControllers];
	
	[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	return YES;
}

-(void) loadProperties
{
//	Properties* prop = [Properties appProperties];
//	[GlodonAPIGetter setHost:prop.apiHost];
//	CDSetProp(PropUserToken, nil);
//	
//	if (CDProp(PropSettingShowImage).length <= 0)
//		CDSetProp(PropSettingShowImage, @"0");
//	if (CDProp(PropSettingNoticeNoDisturbing).length <= 0)
//		CDSetProp(PropSettingNoticeNoDisturbing, @"1");
//	if (CDProp(PropSettingNoticeRemindNew).length <= 0)
//		CDSetProp(PropSettingNoticeRemindNew, @"1");
//	if (CDProp(PropSettingNoticeShake).length <= 0)
//		CDSetProp(PropSettingNoticeShake, @"1");
//	if (CDProp(PropSettingNoticeSound).length <= 0)
//		CDSetProp(PropSettingNoticeSound, @"1");
//	if (CDProp(PropSettingServiceURL).length <= 0)
//		CDSetProp(PropSettingServiceURL, @"http://shang.qq.com/open_webaio.html?sigt=d6bb9bf29db37b7bc825052f86310d9432e1d54058b75e7ab90a2f7de51af91fa7d990623c3102d3fa09bc7b729fa23b&sigu=8008a3079f5e4afbd44a3b4364529ae53a0a286f9465a25eaafbcf5d2cdd646f9e33012fc11a7890&tuin=1779399820");
//	if (CDProp(PropSettingServicePhone).length <= 0)
//		CDSetProp(PropSettingServicePhone, @"tel://4000166166");
}

-(void) createControllers
{
	MainTabViewController* vc = [[MainTabViewController alloc] init];
	_navigationController = [[CDNavigationController alloc] initWithRootViewController:vc];
	
	self.window.rootViewController = _navigationController;
	[self.window makeKeyAndVisible];
	
	_navigationController.view.frame = self.window.bounds;
}

-(void) logoutWithMsg:(NSString*)msg
{
//	CDSetProp(PropUserToken, nil);
//	CDSetProp(PropUserPassword, nil);
//	[GlodonAPIGetter setUserToken:nil];
//	
//	LoginViewController* vc = [[LoginViewController alloc] init];
//	vc.popMsg = msg;
//	vc.activeKeyboard = YES;
//	[_navigationController setRootViewController:vc];
}

//-(void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
//{
//	NSString* temp = [NSString stringWithString:deviceToken.description];
//	//去掉引号和空格
//	temp = [[temp substringWithRange:NSMakeRange(1, temp.length - 2)] stringByReplacingOccurrencesOfString:@" " withString:@""];
//	//全局中保存deviceToken
//	CDSetProp(PropDeviceToken, temp);
//}

NSString* const kApplicationResumeNotice = @"notice.application.resume";
NSString* const kApplicationPauseNotice = @"notice.application.pause";

- (void)applicationWillResignActive:(UIApplication *)application
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationPauseNotice object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationPauseNotice object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationResumeNotice object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//	[[NSNotificationCenter defaultCenter] postNotificationName:kApplicationResumeNotice object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
