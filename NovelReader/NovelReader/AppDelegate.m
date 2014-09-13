//
//  AppDelegate.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-16.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "AppDelegate.h"
#import "Properties.h"
#import "LaunchViewController.h"
#import "RestfulAPIGetter.h"
#import "xlmember/XlMemberIosAdapter.h"
#import "DaemonWorker.h"



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
	
//	[application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	return YES;
}

-(void) loadProperties
{
	Properties* prop = [Properties appProperties];
	[RestfulAPIGetter setDefaultHost:prop.APIHost];
	[RestfulAPIGetter setUserID:CDIDProp(PropUserID)];
	[RestfulAPIGetter setSession:CDProp(PropUserSession)];
	
	if (CDProp(PropReaderNightMode).length <= 0)
		CDSetProp(PropReaderNightMode, @"0");
	if (CDProp(PropReaderFontSize).length <= 0)
		CDSetProp(PropReaderFontSize, @"15");
	if (CDProp(PropReaderBrightness).length <= 0)
		CDSetProp(PropReaderBrightness, @"1.0");
	
	[[DaemonWorker worker] checkAppUpdateInfo:NO];
	[[DaemonWorker worker] getRecommendBooks];
}

-(void) createControllers
{
	if ([CDProp(PropAppLaunchedFlag) boolValue])
	{
		UIViewController* vc = [[LaunchViewController alloc] init];
		_navigationController = [[CDNavigationController alloc] initWithRootViewController:vc];
	}
	else
	{
		CDSetProp(PropAppLaunchedFlag, @"1");
		UIViewController* vc = [[FirstLaunchViewController alloc] init];
		_navigationController = [[CDNavigationController alloc] initWithRootViewController:vc];
	}
	
	self.window.rootViewController = _navigationController;
	[self.window makeKeyAndVisible];
	
	_navigationController.view.frame = self.window.bounds;
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
	[[XlMemberIosAdapter instance] heartBeat:false];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
