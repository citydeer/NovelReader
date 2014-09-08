//
//  SettingViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-29.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "SettingViewController.h"
#import "UIHelper.h"
#import "Models.h"
#import "Properties.h"
#import "XLWebViewController.h"
#import "DaemonWorker.h"



@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, GetterControllerOwner>
{
	UITableView* _tableView;
	
	GetterController* _getterController;
}

@end



@implementation SettingViewController

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
	
	self.titleLabel.text = @"设置";
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	
	CGRect rect = self.view.bounds;
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight) style:UITableViewStylePlain];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.dataSource = self;
	_tableView.delegate = self;
	_tableView.backgroundColor = CDColor(nil, @"e7e7e7");
	_tableView.showsVerticalScrollIndicator = NO;
	_tableView.bounces = NO;
	_tableView.rowHeight = 48;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
}

-(void) handleGetter:(id<Getter>)getter
{
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
	return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
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
		
		CGFloat width = cell.bounds.size.width;
		
		[UIHelper addLabel:cell t:nil tc:CDColor(nil, @"282828") fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(45, 0, 200, 48)].tag = 1;
		
		[UIHelper addRect:cell color:CDColor(nil, @"d1d1d1") x:10 y:0 w:width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth].tag = 2;
		
		UIImageView* iv = [[UIImageView alloc] initWithImage:CDImage(@"user/arrow")];
		iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[UIHelper moveView:iv toX:width-15-10.5 andY:14];
		[cell addSubview:iv];
		
		iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 48)];
		iv.contentMode = UIViewContentModeCenter;
		iv.tag = 3;
		[cell addSubview:iv];
	}
	[cell viewWithTag:2].hidden = (indexPath.row <= 0);
	
	UILabel* label = (UILabel*)[cell viewWithTag:1];
	UIImageView* imageView = (UIImageView*)[cell viewWithTag:3];
	if (indexPath.section == 0 && indexPath.row == 0)
	{
		label.text = @"检查更新";
		imageView.image = CDImage(@"user/setting_check");
	}
	else if (indexPath.section == 0 && indexPath.row == 1)
	{
		label.text = @"评分";
		imageView.image = CDImage(@"user/setting_rate");
	}
	else if (indexPath.section == 0 && indexPath.row == 2)
	{
		label.text = @"反馈";
		imageView.image = CDImage(@"user/setting_feedback");
	}
	else
	{
		label.text = nil;
		imageView.image = nil;
	}
	
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
		[[DaemonWorker worker] checkAppUpdateInfo:YES];
	}
	else if (indexPath.section == 0 && indexPath.row == 1)
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:CDProp(PropAppCommentURL)]];
	}
	else if (indexPath.section == 0 && indexPath.row == 2)
	{
		XLWebViewController* vc = [[XLWebViewController alloc] init];
		vc.pageTitle = @"反馈";
		vc.pageURL = [NSString stringWithFormat:@"%@feedback.html", [Properties appProperties].XLWebHost];
		[self.cdNavigationController pushViewController:vc];
	}
}

@end
