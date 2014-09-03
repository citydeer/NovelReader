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



@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, GetterControllerOwner>
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
}

-(void) updateViews;
-(void) loginAction:(id)sender;
-(void) rechargeAction:(id)sender;

@end



@implementation UserViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		_getterController = [[GetterController alloc] initWithOwner:self];
	}
	return self;
}

-(void) dealloc
{
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
	
//	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
//	getter.params = @{@"c" : @"book", @"a" : @"getinfo", @"bookid" : @"1000215"};
//	[_getterController launchGetter:getter];
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
		_xunleiMemberIcon.hidden = NO;
		
		_avatarView.imageURL = CDProp(PropUserImage);
		_balanceLabel.text = @"0书豆";
		_favNumLabel.text = @"0";
		_commentNumLabel.text = @"0";
		_purchasedNumLabel.text = @"0";
	}
}

-(void) handleGetter:(id<Getter>)getter
{
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
	
	UIViewController* vc = nil;
	if (indexPath.section == 0 && indexPath.row == 0)
		vc = [[XLRechargeViewController alloc] init];
	else if (indexPath.section == 0 && indexPath.row == 1)
		vc = [[XLJoinVIPViewController alloc] init];
	else if (indexPath.section == 1 && indexPath.row == 0)
	{
		XLWebViewController* wvc = [[XLWebViewController alloc] init];
		wvc.pageTitle = @"消费记录";
		wvc.pageURL = [NSString stringWithFormat:@"%@buyrecord.html", [Properties appProperties].XLWebHost];
		vc = wvc;
	}
	else if (indexPath.section == 1 && indexPath.row == 1)
	{
		XLWebViewController* wvc = [[XLWebViewController alloc] init];
		wvc.pageTitle = @"充值记录";
		wvc.pageURL = [NSString stringWithFormat:@"%@payrecord.html", [Properties appProperties].XLWebHost];
		vc = wvc;
	}
	else if (indexPath.section == 2 && indexPath.row == 0)
		vc = [[SettingViewController alloc] init];
	if (vc != nil)
		[_parent.cdNavigationController pushViewController:vc];
}

-(void) loginAction:(id)sender
{
	XLLoginViewController* vc = [[XLLoginViewController alloc] init];
	[_parent.cdNavigationController pushViewController:vc];
}

-(void) rechargeAction:(id)sender
{
	[_parent.cdNavigationController pushViewController:[[XLRechargeViewController alloc] init]];
}

@end

