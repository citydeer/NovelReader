//
//  XLJoinVIPViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-28.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLJoinVIPViewController.h"
#import "UIHelper.h"
#import "KYTipsView.h"
#import "Properties.h"
#import "Models.h"
#import "SelectorView.h"
#import "RestfulAPIGetter.h"



@interface XLJoinVIPViewController () <GetterControllerOwner, SelectViewDelegate>
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
	VIPPriceModel* _model;
	NSInteger _listIndex;
}

-(void) payAction:(id)sender;
-(void) chooseAmountAction:(id)sender;
-(void) choosePayTypeAction:(id)sender;
-(void) updatePayType;
-(void) updateView;

@end



@implementation XLJoinVIPViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_getterController = [[GetterController alloc] initWithOwner:self];
		_payType = [CDIDProp(PropPayLastType) intValue];
		if (_payType < 0 || _payType > 2)
			_payType = 0;
    }
    return self;
}

-(void) dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = @"开通阅读会员";
	
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
	[UIHelper addLabel:v t:@"阅读会员价格" tc:[UIColor blackColor] fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 200, 40)];
	_firstLabel = [UIHelper addLabel:v t:nil tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentRight frame:CGRectMake(rect.size.width-11-160, 0, 160, 40)];
	
	_priceLabel = [UIHelper addLabel:_scrollView t:nil tc:CDColor(nil, @"969696") fs:7 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 50, rect.size.width-20, 26)];
	
	v = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:76 w:rect.size.width h:40 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:v color:CDColor(nil, @"d1d1d1") x:0 y:39.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addLabel:v t:@"购买时长" tc:[UIColor blackColor] fs:12 b:NO al:NSTextAlignmentLeft frame:CGRectMake(10, 0, 200, 40)];
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
	
	_scrollView.contentSize = CGSizeMake(rect.size.width, 396);
	
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
		
		RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
		getter.host = @"http://dypay.vip.xunlei.com/";
		getter.path = @"phonepay/yueduprice/";
		getter.params = @{@"userid" : @"", @"biztype" : @"1", @"callback" : @""};
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
	_firstLabel.text = [NSString stringWithFormat:@"%.0f 阅读点", _model.monthprice];
	_priceLabel.text = @"迅雷白金、钻石会员优惠价5元/月 | 迅雷普通会员优惠价10元/月";
	
	if (_model.price_list.count > 0 && _model.price_list.count > _listIndex)
	{
		NSInteger amount = [[_model.price_list objectAtIndex:_listIndex] intValue];
		_amountLabel.text = [NSString stringWithFormat:@"%d个月", amount];
		_totalPriceLabel.text = [NSString stringWithFormat:@"%.0f元", _model.monthprice*amount];
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
	for (NSNumber* amount in _model.price_list)
		[strs addObject:[NSString stringWithFormat:@"%d个月", amount.intValue]];
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

-(void) didSelect:(SelectorView *)selectorView index:(NSUInteger)index
{
	[selectorView dismiss];
	_listIndex = index;
	[self updateView];
}

-(void) handleGetter:(id<Getter>)getter
{
	[self.view dismiss];
	_payButton.enabled = YES;
	_model = [[VIPPriceModel alloc] initWithDictionary:nil];
	[self updateView];
}

@end
