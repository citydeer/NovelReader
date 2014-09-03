//
//  MainTabViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "MainTabViewController.h"
#import "BookShelfViewController.h"
#import "BookStoreViewController.h"
#import "UserViewController.h"
#import "UIHelper.h"
#import "Properties.h"
#import "RestfulAPIGetter.h"
#import "xlmember/XlMemberIosAdapter.h"



@interface MainTabViewController () <XlMemberEvents>
{
	UIViewController* _currentVC;
	UIView* _containerView;
	
	UIButton* _shelfButton;
	UIButton* _storeButton;
	UIButton* _userButton;
	
	BookShelfViewController* _shelfVC;
	BookStoreViewController* _storeVC;
	UserViewController* _userVC;
}

-(void) switchAction:(id)sender;
-(void) updateTabButtons;
-(void) checkLoginInfo;
-(void) processLogout:(NSNotification*)notice;
-(void) processLogin:(NSNotification*)notice;

@end



@implementation MainTabViewController

NSString* kUserDidLoginNotification = @"user.didlogin";

-(id) init
{
	self = [super init];
	if (self)
	{
		_naviBarHeight = 0;
		
		_shelfVC = [[BookShelfViewController alloc] init];
		_shelfVC.parent = self;
		_storeVC = [[BookStoreViewController alloc] init];
		_storeVC.parent = self;
		_userVC = [[UserViewController alloc] init];
		_userVC.parent = self;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLogout:) name:kUserLogoutNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLogin:) name:kUserDidLoginNotification object:nil];
	}
	return self;
}

- (void)dealloc
{
	[[XlMemberIosAdapter instance] removeObserver:self];
}

- (void)loadView
{
	[super loadView];
	
	CGRect rect = self.view.bounds;
	CGFloat tabbarHeight = 50.0f;
	
	_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_containerView.backgroundColor = CDColor(nil, @"e1e1e1");
	[self.view addSubview:_containerView];
	
	UIView* tabbarView = [[UIView alloc] initWithFrame:CGRectMake(0, rect.size.height - tabbarHeight, rect.size.width, tabbarHeight)];
	tabbarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	tabbarView.backgroundColor = CDColor(nil, @"e5ffffff");
	
	UIView* av = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 0.5f)];
	av.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	av.backgroundColor = CDColor(nil, @"a5a5a5");
	[tabbarView addSubview:av];
	
	_shelfButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320.0f/3.0f, tabbarHeight)];
	[_shelfButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 14, 0)];
	[_shelfButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	UILabel* label = [UIHelper label:@"本地书库" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, tabbarHeight-20, 320.0f/3.0f, 20)];
	label.tag = 1;
	[_shelfButton addSubview:label];
	[tabbarView addSubview:_shelfButton];
	
	_storeButton = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/3.0f, 0, 320.0f/3.0f, tabbarHeight)];
	[_storeButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 14, 0)];
	[_storeButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	label = [UIHelper label:@"书城" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, tabbarHeight-20, 320.0f/3.0f, 20)];
	label.tag = 1;
	[_storeButton addSubview:label];
	[tabbarView addSubview:_storeButton];
	
	_userButton = [[UIButton alloc] initWithFrame:CGRectMake(320.0f/3.0f*2.0f, 0, 320.0f/3.0f, tabbarHeight)];
	[_userButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 14, 0)];
	[_userButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	label = [UIHelper label:@"个人中心" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, tabbarHeight-20, 320.0f/3.0f, 20)];
	label.tag = 1;
	[_userButton addSubview:label];
	[tabbarView addSubview:_userButton];
	
	[self.view addSubview:tabbarView];
	
	[self switchAction:_shelfButton];
	
	[self checkLoginInfo];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	[_currentVC willPresentView:duration];
}

-(void) didPresentView
{
	[super didPresentView];
	[_currentVC didPresentView];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	[_currentVC willDismissView:duration];
}

-(void) didDismissView
{
	[super didDismissView];
	[_currentVC didDismissView];
}

-(void) switchAction:(id)sender
{
	if (sender == _shelfButton)
	{
		[self switchToController:_shelfVC];
	}
	else if (sender == _storeButton)
	{
		[self switchToController:_storeVC];
	}
	else if (sender == _userButton)
	{
		[self switchToController:_userVC];
	}
}

-(void) switchToController:(UIViewController*)newController
{
	if (newController == nil)
		return;
	
	if (_currentVC != newController)
	{
		CGRect rect = _containerView.bounds;
		newController.view.frame = rect;
		
		UIViewController* oldVC = _currentVC;
		_currentVC = newController;
		
		[oldVC willDismissView:0];
		[newController willPresentView:0];
		
		[_containerView addSubview:newController.view];
		[oldVC.view removeFromSuperview];
		newController.view.frame = rect;
		
		[newController didPresentView];
		[oldVC didDismissView];
		
		[self updateTabButtons];
	}
}

-(void) updateTabButtons
{
	if ([_currentVC isKindOfClass:[BookShelfViewController class]])
	{
		[_shelfButton setImage:CDImage(@"main/shelf2") forState:UIControlStateNormal];
		[_shelfButton setImage:CDImage(@"main/shelf2") forState:UIControlStateHighlighted];
		((UILabel*)[_shelfButton viewWithTag:1]).textColor = CDColor(nil, @"ec6400");
	}
	else
	{
		[_shelfButton setImage:CDImage(@"main/shelf1") forState:UIControlStateNormal];
		[_shelfButton setImage:CDImage(@"main/shelf1") forState:UIControlStateHighlighted];
		((UILabel*)[_shelfButton viewWithTag:1]).textColor = CDColor(nil, @"282828");
	}
	
	if ([_currentVC isKindOfClass:[BookStoreViewController class]])
	{
		[_storeButton setImage:CDImage(@"main/store2") forState:UIControlStateNormal];
		[_storeButton setImage:CDImage(@"main/store2") forState:UIControlStateHighlighted];
		((UILabel*)[_storeButton viewWithTag:1]).textColor = CDColor(nil, @"ec6400");
	}
	else
	{
		[_storeButton setImage:CDImage(@"main/store1") forState:UIControlStateNormal];
		[_storeButton setImage:CDImage(@"main/store1") forState:UIControlStateHighlighted];
		((UILabel*)[_storeButton viewWithTag:1]).textColor = CDColor(nil, @"282828");
	}
	
	if ([_currentVC isKindOfClass:[UserViewController class]])
	{
		[_userButton setImage:CDImage(@"main/user2") forState:UIControlStateNormal];
		[_userButton setImage:CDImage(@"main/user2") forState:UIControlStateHighlighted];
		((UILabel*)[_userButton viewWithTag:1]).textColor = CDColor(nil, @"ec6400");
	}
	else
	{
		[_userButton setImage:CDImage(@"main/user1") forState:UIControlStateNormal];
		[_userButton setImage:CDImage(@"main/user1") forState:UIControlStateHighlighted];
		((UILabel*)[_userButton viewWithTag:1]).textColor = CDColor(nil, @"282828");
	}
}

-(void) processLogin:(NSNotification*)notice
{
	XlMemberIosAdapter* xlMember = [XlMemberIosAdapter instance];
	NSNumber* uid = [NSNumber numberWithUnsignedLongLong:xlMember.userId];
	CDSetProp(PropUserID, uid);
	CDSetProp(PropUserAccount, xlMember.userName);
	CDSetProp(PropUserName, xlMember.nickName);
	CDSetProp(PropUserSession, xlMember.sessionId);
	
	[RestfulAPIGetter setUserID:CDIDProp(PropUserID)];
	[RestfulAPIGetter setSession:CDProp(PropUserSession)];
	[RestfulAPIGetter setUserName:CDProp(PropUserName)];
	[RestfulAPIGetter setUserAccount:CDProp(PropUserAccount)];
}

-(void) processLogout:(NSNotification*)notice
{
	CDSetProp(PropUserID, nil);
	CDSetProp(PropUserName, nil);
	CDSetProp(PropUserSession, nil);
	CDSetProp(PropUserImage, nil);
	
	[RestfulAPIGetter setUserID:CDIDProp(PropUserID)];
	[RestfulAPIGetter setSession:CDProp(PropUserSession)];
	[RestfulAPIGetter setUserName:CDProp(PropUserName)];
	[RestfulAPIGetter setUserAccount:CDProp(PropUserAccount)];
	
	NSUInteger type = [[notice.userInfo objectForKey:kLogoutType] intValue];
	if (type != XLLOGOUT_NORMAL)
	{
		NSString* msg = @"该账号已在其他终端登录，请重新登录";
		if (type == XLLOGOUT_SESSION_TIMEOUT)
			msg = @"您已太长时间没有登录，请重新登录";
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:nil];
		[alert show];
	}
}

-(void) checkLoginInfo
{
	NSNumber* uid = CDIDProp(PropUserID);
	if (uid)
	{
		XlMemberIosAdapter* member = [XlMemberIosAdapter instance];
		[member initXlMember:[Properties appProperties].XLMemberAppID clientVersion:[Properties appProperties].APPVersion peerId:@"peerid"];
		[member addObserver:self];
		[member loginByUserId:uid.unsignedLongLongValue];
	}
}

-(void) onLoginResult:(enum XlMemberResultCode)code
{
	XlMemberIosAdapter* member = [XlMemberIosAdapter instance];
	if (code == XLMEMBER_SUCCESS)
	{
		[member requestUserInfo];
		[[NSNotificationCenter defaultCenter] postNotificationName:kUserDidLoginNotification object:nil];
	}
	else
	{
		[member removeObserver:self];
	}
}

-(void) onUserInfoResult:(enum XlMemberResultCode)code
{
	XlMemberIosAdapter* member = [XlMemberIosAdapter instance];
	[member removeObserver:self];
	CDSetProp(PropUserImage, member.pictureUrl);
}

@end

