//
//  CDViewController.h
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-15.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//


#import "CDNavigationController.h"
#import "Theme.h"


extern NSString* const kCDChangeSkinNotification;

@interface CDViewController : UIViewController
{
@protected
	CGFloat	_statusBarHeight;
	CGFloat _naviBarHeight;
	CGRect _viewFrame;
}

@property (nonatomic, readonly) UIView* naviBarView;
@property (nonatomic, readonly) UIImageView* naviBarShadowView;
@property (nonatomic, readonly) UIButton* leftButton;
@property (nonatomic, readonly) UIButton* rightButton;
@property (nonatomic, readonly) UILabel* titleLabel;
@property (nonatomic, assign) BOOL naviBarHidden;
@property (nonatomic, strong) UIColor* blurColor;
@property (nonatomic, readonly) CGRect viewFrame;

-(void) setNaviBarHidden:(BOOL)hidden animated:(BOOL)animated;

-(void) leftButtonAction:(id)sender;
-(void) rightButtonAction:(id)sender;
-(void) didChangeSkin;

-(void) showRetryBtnOnMaskViewWithMsg:(NSString *)msg;
-(void) hideMaskView;
-(void) _retryAction;

@end
