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


@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, GetterControllerOwner>
{
	UITableView* _tableView;
	
	UIView* _guestView;
	UIView* _userView;
	
	UIImageView* _avatarView;
	UIImageView* _xunleiMemberIcon;
	UILabel* _userNameLabel;
	UILabel* _balanceLabel;
	UILabel* _favNumberLabel;
	UILabel* _commentNumberLabel;
	UILabel* _purchasedNumberLabel;
	
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
	[headerView addSubview:_userView];
	
	[self.view addSubview:_tableView];
	
	[self updateViews];
}

-(void) updateViews
{
	_guestView.hidden = NO;
	_userView.hidden = YES;
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
	return 10.0f;
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
		cell.backgroundColor = [UIColor whiteColor];
		
		CGFloat width = cell.bounds.size.width;
		
		UILabel* label = [UIHelper label:nil tc:CDColor(nil, @"282828") fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 300, 38)];
		label.tag = 1;
		[cell addSubview:label];
		
		UIView* sepLine = [[UIView alloc] initWithFrame:CGRectMake(10, 0, width-10, 0.5)];
		sepLine.tag = 2;
		sepLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		sepLine.backgroundColor = CDColor(nil, @"d1d1d1");
		[cell addSubview:sepLine];
		
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

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) loginAction:(id)sender
{
}

-(void) rechargeAction:(id)sender
{
}

@end

