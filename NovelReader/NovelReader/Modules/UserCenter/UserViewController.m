//
//  UserViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "UserViewController.h"
#import "MainTabViewController.h"
#import "UIHelper.h"
#import "Models.h"
#import "Properties.h"
#import "CDRemoteImageView.h"
#import "XLLoginViewController.h"
#import "XLRechargeViewController.h"
#import "XLJoinVIPViewController.h"
#import "SettingViewController.h"
#import "RestfulAPIGetter.h"
#import "XLWebViewController.h"
#import "xlmember/XlMemberIosAdapter.h"
#import "DaemonWorker.h"



@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, GetterControllerOwner, XlMemberEvents, UIActionSheetDelegate>
{
	UITableView* _tableView;
	
	UIView* _guestView;
	UIView* _userView;
	
	CDRemoteImageView* _avatarView;
	UIImageView* _xunleiMemberIcon;
	UILabel* _userNameLabel;
	UILabel* _balanceLabel;
	UILabel* _favNumLabel;
	UILabel* _commentNumLabel;
	UILabel* _purchasedNumLabel;
	
	GetterController* _getterController;
	XlMemberIosAdapter* _xlMember;
}

-(void) updateViews;
-(void) requestData;
-(void) loginAction:(id)sender;
-(void) logoutAction:(id)sender;
-(void) rechargeAction:(id)sender;

-(void) processLogout:(NSNotification*)notice;

@end



@implementation UserViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		_getterController = [[GetterController alloc] initWithOwner:self];
		_xlMember = [XlMemberIosAdapter instance];
		[_xlMember addObserver:self];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLogout:) name:kUserLogoutNotification object:nil];
	}
	return self;
}

-(void) dealloc
{
	[_xlMember removeObserver:self];
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = @"个人中心";
	
	CGRect rect = self.view.bounds;
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight) style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = CDColor(nil, @"e7e7e7");
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.bounces = NO;
	_tableView.rowHeight = 38;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
	_tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0);
	
	UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 123.5+25)];
	headerView.backgroundColor = [UIColor clearColor];
	_tableView.tableHeaderView = headerView;
	
	UIImageView* iv = [[UIImageView alloc] initWithImage:CDImage(@"user/header_bg")];
	[headerView addSubview:iv];
	
	NSString* str = @"你可以升级为VIP会员，全场书籍免费阅读";
	UILabel* label = [UIHelper label:str tc:CDColor(nil, @"757575") fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, 123.5, rect.size.width, 25)];
	[headerView addSubview:label];
	
	_guestView = [[UIView alloc] initWithFrame:iv.frame];
	[headerView addSubview:_guestView];
	UIImageView* imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/avatar_guest")];
	imageView.center = CGPointMake(160, 29+12);
	[_guestView addSubview:imageView];
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(320/2.0f-121.5/2.0f, 24+58, 121.5, 25)];
	[button setBackgroundImage:CDImage(@"user/button_login1") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"user/button_login2") forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:15];
	[button setTitle:@"登 录" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(loginAction:) forControlEvents:UIControlEventTouchUpInside];
	[_guestView addSubview:button];
	
	_userView = [[UIView alloc] initWithFrame:iv.frame];
	UIView* infoBGView = [UIHelper addRect:_userView color:CDColor(nil, @"66000000") x:0 y:_userView.bounds.size.height-47 w:_userView.bounds.size.width h:47 resizing:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	[UIHelper addRect:infoBGView color:CDColor(nil, @"d8af97") x:rect.size.width/3.0f y:10 w:0.5f h:27 resizing:0];
	[UIHelper addRect:infoBGView color:CDColor(nil, @"d8af97") x:rect.size.width/3.0f*2.0f y:10 w:0.5f h:27 resizing:0];
	[headerView addSubview:_userView];
	
	_avatarView = [[CDRemoteImageView alloc] initWithFrame:CGRectMake(10, 10, 58, 58)];
	_avatarView.placeholderImage = CDImage(@"user/avatar_defualt");
	_avatarView.placeHolderContetMode = UIViewContentModeCenter;
	_avatarView.imageContentMode = UIViewContentModeScaleAspectFill;
	[_avatarView setTarget:self action:@selector(logoutAction:)];
	[_userView addSubview:_avatarView];
	
	_userNameLabel = [UIHelper addLabel:_userView t:nil tc:[UIColor whiteColor] fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(22+58, 15, 100, 20)];
	_balanceLabel = [UIHelper addLabel:_userView t:nil tc:[UIColor whiteColor] fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(22+58, 42, 130, 20)];
	_favNumLabel = [UIHelper addLabel:infoBGView t:nil tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, 7, 320.0f/3.0f, 16)];
	[UIHelper addLabel:infoBGView t:@"收藏" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, 24, 320.0f/3.0f, 16)];
	_commentNumLabel = [UIHelper addLabel:infoBGView t:nil tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(320.0/3, 7, 320.0/3, 16)];
	[UIHelper addLabel:infoBGView t:@"评论" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(320.0/3, 24, 320.0/3.0, 16)];
	_purchasedNumLabel = [UIHelper addLabel:infoBGView t:nil tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(320.0/3*2, 7, 320.0/3, 16)];
	[UIHelper addLabel:infoBGView t:@"已购" tc:[UIColor whiteColor] fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(320.0/3*2, 24, 320.0f/3.0f, 16)];
	
	_xunleiMemberIcon = [[UIImageView alloc] initWithImage:CDImage(@"user/vip")];
	[UIHelper moveView:_xunleiMemberIcon toY:19];
	[_userView addSubview:_xunleiMemberIcon];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width-84-10, 27, 84, 25)];
	[button setBackgroundImage:CDImage(@"user/button_recharge1") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"user/button_recharge2") forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:12];
	[button setTitle:@"充值" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
	[_userView addSubview:button];
	
	[self.view addSubview:_tableView];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	[self updateViews];
}

-(void) updateViews
{
	BOOL isLogined = (CDProp(PropUserID) != nil);
	_guestView.hidden = isLogined;
	_userView.hidden = !isLogined;
	if (isLogined)
	{
		NSString* name = CDProp(PropUserName);
		if (name.length <= 0)
			name = CDProp(PropUserAccount);
		_userNameLabel.text = name;
		
		CGFloat width = [name sizeWithFont:_userNameLabel.font].width;
		if (width > _userNameLabel.frame.size.width) width = _userNameLabel.frame.size.width;
		[UIHelper moveView:_xunleiMemberIcon toX:_userNameLabel.frame.origin.x+width+5];
		_xunleiMemberIcon.hidden = !CDProp(PropUserVIP).boolValue;
		
		_avatarView.imageURL = CDProp(PropUserImage);
		_balanceLabel.text = [NSString stringWithFormat:@"%d书豆", [CDIDProp(PropUserBalance) intValue]];
		_favNumLabel.text = [CDIDProp(PropUserFavCount) stringValue];
		_commentNumLabel.text = @"0";
		_purchasedNumLabel.text = [CDIDProp(PropUserBuyCount) stringValue];
	}
}

-(void) requestData
{
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"user", @"a" : @"getinfo"};
	[_getterController launchGetter:getter];
}

-(void) handleGetter:(id<Getter>)getter
{
	if (getter.resultCode == KYResultCodeSuccess)
	{
		UserInfoModel* model = [[UserInfoModel alloc] initWithDictionary:((RestfulAPIGetter*)getter).result[@"data"]];
		CDSetProp(PropUserVIP, (model.yueduvip ? @"1" : @"0"));
		CDSetProp(PropUserBalance, [NSNumber numberWithInteger:model.coin]);
		CDSetProp(PropUserFavCount, [NSNumber numberWithInteger:model.bookmark]);
		CDSetProp(PropUserBuyCount, [NSNumber numberWithInteger:model.buynum]);
		if (self.isViewLoaded)
			[self updateViews];
	}
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
	return 3;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return (section >= 2 ? 1 : 2);
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	if (section < 2)
		return 10.0f;
	return 0.0f;
}

-(UIView*) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 10)];
	v.backgroundColor = [UIColor clearColor];
	return v;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* cid = @"CellID";
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cid];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		CGFloat width = cell.bounds.size.width;
		
		UILabel* label = [UIHelper label:nil tc:CDColor(nil, @"282828") fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 300, 38)];
		label.tag = 1;
		[cell addSubview:label];
		
		[UIHelper addRect:cell color:CDColor(nil, @"d1d1d1") x:10 y:0 w:width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth].tag = 2;
		
		UIImageView* iv = [[UIImageView alloc] initWithImage:CDImage(@"user/arrow")];
		iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[UIHelper moveView:iv toX:width-15-10.5 andY:9];
		[cell addSubview:iv];
	}
	[cell viewWithTag:2].hidden = (indexPath.row <= 0);
	
	UILabel* label = (UILabel*)[cell viewWithTag:1];
	if (indexPath.section == 0 && indexPath.row == 0)
		label.text = @"快速充值";
	else if (indexPath.section == 0 && indexPath.row == 1)
		label.text = @"VIP会员";
	else if (indexPath.section == 1 && indexPath.row == 0)
		label.text = @"消费记录";
	else if (indexPath.section == 1 && indexPath.row == 1)
		label.text = @"充值记录";
	else if (indexPath.section == 2 && indexPath.row == 0)
		label.text = @"设置";
	else
		label.text = nil;
	
	return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	cell.backgroundColor = [UIColor whiteColor];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	if (indexPath.section == 0 && indexPath.row == 0)
	{
		[[DaemonWorker worker] checkLoginStatus:^{
			[_parent.cdNavigationController setViewController:[[XLRechargeViewController alloc] init] afterController:_parent];
		}];
	}
	else if (indexPath.section == 0 && indexPath.row == 1)
	{
		[[DaemonWorker worker] checkLoginStatus:^{
			[_parent.cdNavigationController setViewController:[[XLJoinVIPViewController alloc] init] afterController:_parent];
		}];
	}
	else if (indexPath.section == 1 && indexPath.row == 0)
	{
		[[DaemonWorker worker] checkLoginStatus:^{
			XLWebViewController* wvc = [[XLWebViewController alloc] init];
			wvc.pageTitle = @"消费记录";
			wvc.pageURL = [NSString stringWithFormat:@"%@buyrecord.html", [Properties appProperties].XLWebHost];
			[_parent.cdNavigationController setViewController:wvc afterController:_parent];
		}];
	}
	else if (indexPath.section == 1 && indexPath.row == 1)
	{
		[[DaemonWorker worker] checkLoginStatus:^{
			XLWebViewController* wvc = [[XLWebViewController alloc] init];
			wvc.pageTitle = @"充值记录";
			wvc.pageURL = [NSString stringWithFormat:@"%@payrecord.html", [Properties appProperties].XLWebHost];
			[_parent.cdNavigationController setViewController:wvc afterController:_parent];
		}];
	}
	else if (indexPath.section == 2 && indexPath.row == 0)
	{
		[_parent.cdNavigationController setViewController:[[SettingViewController alloc] init] afterController:_parent];
	}
}

-(void) loginAction:(id)sender
{
	XLLoginViewController* vc = [[XLLoginViewController alloc] init];
	[_parent.cdNavigationController pushViewController:vc];
}

-(void) logoutAction:(id)sender
{
	UIActionSheet* as = [[UIActionSheet alloc] initWithTitle:@"您确定要注销吗？" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
	[as showInView:self.view];
}

-(void) rechargeAction:(id)sender
{
	[_parent.cdNavigationController pushViewController:[[XLRechargeViewController alloc] init]];
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0)
	{
		[_xlMember logout];
	}
}


-(void) checkLoginInfo
{
	NSNumber* uid = CDIDProp(PropUserID);
	if (uid)
	{
		[_xlMember initXlMember:[Properties appProperties].XLMemberAppID clientVersion:[Properties appProperties].APPVersion peerId:@"peerid"];
		[_xlMember loginByUserId:uid.unsignedLongLongValue];
	}
}

-(void) processLogout:(NSNotification*)notice
{
	CDSetProp(PropUserID, nil);
	CDSetProp(PropUserName, nil);
	CDSetProp(PropUserSession, nil);
	CDSetProp(PropUserImage, nil);
	CDSetProp(PropUserVIP, nil);
	CDSetProp(PropUserBalance, nil);
	CDSetProp(PropUserFavCount, nil);
	CDSetProp(PropUserBuyCount, nil);
	
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
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
		[alert show];
	}
	
	if (self.isViewLoaded)
		[self updateViews];
}

/**
 * @brief 登陆操作完成， 通知结果
 * @param code @see XlMemberResultCode
 */
-(void) onLoginResult:(enum XlMemberResultCode)code
{
	if (code == XLMEMBER_SUCCESS)
	{
		[_xlMember requestUserInfo];
		
		NSNumber* uid = [NSNumber numberWithUnsignedLongLong:_xlMember.userId];
		CDSetProp(PropUserID, uid);
		CDSetProp(PropUserAccount, _xlMember.userName);
		CDSetProp(PropUserName, _xlMember.nickName);
		CDSetProp(PropUserSession, _xlMember.sessionId);
		
		[RestfulAPIGetter setUserID:CDIDProp(PropUserID)];
		[RestfulAPIGetter setSession:CDProp(PropUserSession)];
		[RestfulAPIGetter setUserName:CDProp(PropUserName)];
		[RestfulAPIGetter setUserAccount:CDProp(PropUserAccount)];
		
		[self requestData];
	}
	
	if (self.isViewLoaded)
		[self updateViews];
}

/**
 * @brief 请求用户信息完成， 通知结果
 * @param code @see XlMemberResultCode
 */
-(void) onUserInfoResult:(enum XlMemberResultCode)code
{
	CDSetProp(PropUserImage, _xlMember.pictureUrl);
	_avatarView.imageURL = CDProp(PropUserImage);
}

/**
 * @brief 注销登录完成，或者 用户被迫重新登录回调
 * @param code @see XlMemberResultCode
 * @param type @see XlLogoutType
 */
-(void) onLogoutResult:(enum XlMemberResultCode)code logoutType:(enum XlLogoutType) type
{
}

@end

