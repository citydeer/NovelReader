//
//  XLRechargeViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-28.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLRechargeViewController.h"
#import "UIHelper.h"
#import "KYTipsView.h"
#import "Properties.h"
#import "Models.h"
#import "RestfulAPIGetter.h"
#import "SelectorView.h"
#import "Encodings.h"
#import "XLJoinVIPViewController.h"



@interface XLRechargeViewController () <GetterControllerOwner, SelectViewDelegate>
{
	GetterController* _getterController;
	
	UIScrollView* _scrollView;
	
	UILabel* _firstLabel;
	UILabel* _priceLabel;
	UILabel* _amountLabel;
	UILabel* _totalPriceLabel;
	
	UILabel* _payType1;
	UILabel* _payType2;
	UILabel* _payType3;
	UIImageView* _payTypeIcon;
	UIButton* _payButton;
	
	NSInteger _payType;	// 0, 1, 2
	RechargePriceModel* _model;
	NSInteger _listIndex;
	NSInteger _userBalance;
}

-(void) payAction:(id)sender;
-(void) chooseAmountAction:(id)sender;
-(void) choosePayTypeAction:(id)sender;
-(void) vipAction:(id)sender;
-(void) updatePayType;
-(void) updateView;

@end



@implementation XLRechargeViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_getterController = [[GetterController alloc] initWithOwner:self];
		_payType = [CDIDProp(PropPayLastType) intValue];
		if (_payType < 0 || _payType > 2)
			_payType = 0;
		_userBalance = [CDIDProp(PropUserBalance) intValue];
    }
    return self;
}

-(void) dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = @"快速充值";
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	
	CGRect rect = self.view.bounds;
	
	_scrollView = [[UIScrollView alloc]	initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.backgroundColor = CDColor(nil, @"e7e7e7");
	[self.view addSubview:_scrollView];
	
	UIView* v = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:10 w:rect.size.width h:40 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:39.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addLabel:v t:@"我的余额" tc:[UIColor blackColor] fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 200, 40)];
	_firstLabel = [UIHelper addLabel:v t:nil tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentRight frame:CGRectMake(rect.size.width-11-160, 0, 160, 40)];
	
	_priceLabel = [UIHelper addLabel:_scrollView t:nil tc:CDColor(nil, @"969696") fs:7 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 50, rect.size.width-20, 26)];
	
	v = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:76 w:rect.size.width h:40 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:39.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addLabel:v t:@"购买阅读点" tc:[UIColor blackColor] fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 200, 40)];
	_amountLabel = [UIHelper addLabel:v t:nil tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentRight frame:CGRectMake(rect.size.width-24-160, 0, 160, 40)];
	UIImageView* imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/arrow_small")];
	[UIHelper moveView:imageView toX:rect.size.width-30 andY:7];
	[v addSubview:imageView];
	[v addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseAmountAction:)]];
	
	v = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:126 w:rect.size.width h:40 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:39.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addLabel:v t:@"应付金额" tc:[UIColor blackColor] fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 200, 40)];
	_totalPriceLabel = [UIHelper addLabel:v t:nil tc:CDColor(nil, @"ec6226") fs:12 b:NO al:NSTextAlignmentRight frame:CGRectMake(rect.size.width-11-160, 0, 160, 40)];
	
	[UIHelper addLabel:_scrollView t:@"请选择支付方式" tc:CDColor(nil, @"969696") fs:10 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 172, 200, 20)];
	
	v = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:196 w:rect.size.width h:120 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:119.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:10 y:40 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:10 y:80 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	_payType1 = [UIHelper addLabel:v t:@"话费支付" tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 300, 40)];
	_payType2 = [UIHelper addLabel:v t:@"支付宝" tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 40, 300, 40)];
	_payType3 = [UIHelper addLabel:v t:@"网银" tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 80, 300, 40)];
	[_payType1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePayTypeAction:)]];
	[_payType2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePayTypeAction:)]];
	[_payType3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choosePayTypeAction:)]];
	_payType1.userInteractionEnabled = YES;
	_payType2.userInteractionEnabled = YES;
	_payType3.userInteractionEnabled = YES;
	_payType1.tag = 0;
	_payType2.tag = 1;
	_payType3.tag = 2;
	_payTypeIcon = [[UIImageView alloc] initWithImage:CDImage(@"user/red_dot")];
	[UIHelper moveView:_payTypeIcon toX:298];
	[v addSubview:_payTypeIcon];
	
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(10, 336, 300, 40)];
	[button setBackgroundImage:CDImage(@"user/button_bg2") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"user/button_bg1") forState:UIControlStateDisabled];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:CDColor(nil, @"d8d8d8") forState:UIControlStateDisabled];
	button.titleLabel.font = [UIFont systemFontOfSize:14];
	[button setTitle:@"去付款" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:button];
	_payButton = button;
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 396, 300, 75)];
	imageView.image = CDImage(@"user/vip_message");
	imageView.userInteractionEnabled = YES;
	[imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(vipAction:)]];
	[_scrollView addSubview:imageView];
	
	_scrollView.contentSize = CGSizeMake(rect.size.width, 396+75);
	
	[self updatePayType];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	if (_getterController.dataStatus == DataStatusUnInit)
	{
		_getterController.dataStatus = DataStatusLoadingAnimated;
		
		[self.view showColorIndicatorFreezeUI:NO];
		_payButton.enabled = NO;
		
		URLGetter* getter = [[URLGetter alloc] init];
		NSString* uid = (CDIDProp(PropUserID) ? [(CDIDProp(PropUserID)) stringValue] : @"");
		double callback = [NSDate timeIntervalSinceReferenceDate];
		getter.url = [NSString stringWithFormat:@"http://dypay.vip.xunlei.com/phonepay/yueduprice/?userid=%@&biztype=0&callback=%.0f", uid, callback];
		[_getterController launchGetter:getter];
	}
}

-(void) didPresentView
{
	[super didPresentView];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
}

-(void) updateView
{
	_firstLabel.text = [NSString stringWithFormat:@"%ld 阅读点", (long)_userBalance];
	if (_model.prize > 0.0)
		_priceLabel.text = [NSString stringWithFormat:@"1元=%.0f阅读点", 1.0/_model.prize];
	else
		_priceLabel.text = @"";
	
	if (_model.amount_list.count > 0 && _model.amount_list.count > _listIndex)
	{
		NSInteger amount = [[_model.amount_list objectAtIndex:_listIndex] intValue];
		_amountLabel.text = [NSString stringWithFormat:@"%ld个", (long)amount];
		_totalPriceLabel.text = [NSString stringWithFormat:@"%.0f元", _model.prize*amount];
	}
	else
	{
		_amountLabel.text = @"";
		_totalPriceLabel.text = @"";
	}
}

-(void) updatePayType
{
	_payType1.textColor = (_payType == 0 ? [UIColor blackColor] : CDColor(nil, @"969696"));
	_payType2.textColor = (_payType == 1 ? [UIColor blackColor] : CDColor(nil, @"969696"));
	_payType3.textColor = (_payType == 2 ? [UIColor blackColor] : CDColor(nil, @"969696"));
	[UIHelper moveView:_payTypeIcon toY:_payType*40+15];
}

-(void) payAction:(id)sender
{
	CDSetProp(PropPayLastType, [NSNumber numberWithInteger:_payType]);
}

-(void) chooseAmountAction:(id)sender
{
	SelectorView* sv = [[SelectorView alloc] initWithFrame:CGRectMake(190, _naviBarHeight + 102, 115, 150)];
	sv.delegate = self;
	NSMutableArray* strs = [NSMutableArray array];
	for (NSNumber* amount in _model.amount_list)
		[strs addObject:[NSString stringWithFormat:@"%d个", amount.intValue]];
	sv.selectedIndex = _listIndex;
	sv.items = strs;
	CGFloat totalHeight = sv.totalHeight;
	if (totalHeight > sv.cellHeight*4+sv.borderHeight)
		totalHeight = sv.cellHeight*4+sv.borderHeight;
	[UIHelper setView:sv toHeight:totalHeight];
	
	[sv showInView:self.view];
}

-(void) choosePayTypeAction:(id)sender
{
	_payType = ((UITapGestureRecognizer*)sender).view.tag;
	[self updatePayType];
}

-(void) vipAction:(id)sender
{
	XLJoinVIPViewController* vc = [[XLJoinVIPViewController alloc] init];
	[self.cdNavigationController pushViewController:vc];
}

-(void) didSelect:(SelectorView *)selectorView index:(NSUInteger)index
{
	[selectorView dismiss];
	_listIndex = index;
	[self updateView];
}

-(void) handleGetter:(id<Getter>)getter
{
	[self.view dismiss];
	if (getter.resultCode == KYResultCodeSuccess)
	{
		_model = [[RechargePriceModel alloc] initWithDictionary:[((URLGetter*)getter).data JSONValue]];
		[self updateView];
		if ([_model rawValue:@"ret"] != nil && _model.ret == 0)
			_payButton.enabled = YES;
	}
}

@end

