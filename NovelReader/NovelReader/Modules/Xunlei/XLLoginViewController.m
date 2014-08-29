//
//  XLLoginViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-28.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLLoginViewController.h"
#import "UIHelper.h"
#import "KYTipsView.h"
#import "CDCustomViews.h"
#import "Properties.h"
#import "xlmember/XlMemberIosAdapter.h"



@interface XLLoginViewController () <UITextFieldDelegate, XlMemberEvents>
{
	UIScrollView* _scrollView;
	CDCustomTextField* _nameField;
	CDCustomTextField* _passwordField;
	CDCustomTextField* _verifyField;
	UIImageView* _verifyImage;
	UIView* _verifyView;
	UIView* _fieldView;
	UIButton* _loginButton;
	
	XlMemberIosAdapter* _xlMember;
}

-(void) onLogin:(id)sender;
-(void) refreshVerifyCode:(id)sender;
-(void) keyboardWillShown:(NSNotification*)notification;
-(void) keyboardWillHide:(NSNotification*)notification;
-(void) showVerifyView;

@end



@implementation XLLoginViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_xlMember = [XlMemberIosAdapter instance];
		[_xlMember addObserver:self];
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
	
	self.titleLabel.text = @"登录";
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	self.rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
	[self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self.rightButton setTitle:@"注册" forState:UIControlStateNormal];
	
	CGRect rect = self.view.bounds;
	
	_scrollView = [[UIScrollView alloc]	initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.bounces = NO;
	_scrollView.backgroundColor = CDColor(nil, @"e7e7e7");
	[self.view addSubview:_scrollView];
	
	NSString* str = @"阅读会员免费阅读全站书籍";
	[UIHelper addLabel:_scrollView t:str tc:CDColor(nil, @"969696") fs:10 b:NO al:NSTextAlignmentLeft frame:CGRectMake(9, 0, rect.size.width, 37)];
	
	_fieldView = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:37 w:rect.size.width h:80 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_fieldView color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_fieldView color:CDColor(nil, @"d1d1d1") x:0 y:79.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
	[UIHelper addRect:_fieldView color:CDColor(nil, @"d1d1d1") x:10 y:40 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	
	_verifyView = [UIHelper addRect:_fieldView color:nil x:0 y:80 w:rect.size.width h:40 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_verifyView color:CDColor(nil, @"d1d1d1") x:10 y:0 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_verifyView color:CDColor(nil, @"d1d1d1") x:227 y:0 w:0.5f h:40 resizing:0];
	
	UIImageView* imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/name_icon")];
	[UIHelper moveView:imageView toX:6 andY:10];
	[_fieldView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/pwd_icon")];
	[UIHelper moveView:imageView toX:6 andY:9+40];
	[_fieldView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/pwd_icon")];
	[UIHelper moveView:imageView toX:6 andY:9];
	[_verifyView addSubview:imageView];
	
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(10, 142, 300, 40)];
	[button setBackgroundImage:CDImage(@"user/button_bg2") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"user/button_bg1") forState:UIControlStateDisabled];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:CDColor(nil, @"d8d8d8") forState:UIControlStateDisabled];
	button.titleLabel.font = [UIFont systemFontOfSize:14];
	[button setTitle:@"迅雷账号登录" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:button];
	_loginButton = button;
	
	_nameField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 4, 268, 32)];
	_nameField.returnKeyType = UIReturnKeyNext;
	_nameField.keyboardType = UIKeyboardTypeASCIICapable;
	_nameField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_nameField.placeHolderFont = [UIFont systemFontOfSize:12];
	_nameField.placeholder = @"请输入您的迅雷账号";
	_nameField.textColor = CDColor(nil, @"282828");
	_nameField.font = [UIFont systemFontOfSize:18];
	[_nameField drawPlaceholderInRect:CGRectZero];
	_nameField.autocorrectionType = UITextAutocorrectionTypeNo;
	_nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_nameField.text = CDProp(PropUserAccount);
	_nameField.delegate = self;
	[_fieldView addSubview:_nameField];
	
	_passwordField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 44, 268, 32)];
	_passwordField.returnKeyType = UIReturnKeyGo;
	_passwordField.keyboardType = UIKeyboardTypeASCIICapable;
	_passwordField.secureTextEntry = YES;
	_passwordField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_passwordField.placeHolderFont = [UIFont systemFontOfSize:12];
	_passwordField.placeholder = @"请输入您的密码";
	_passwordField.textColor = CDColor(nil, @"282828");
	_passwordField.font = [UIFont systemFontOfSize:18];
	_passwordField.delegate = self;
	[_fieldView addSubview:_passwordField];
	
	_verifyField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 4, 160, 32)];
	_verifyField.returnKeyType = UIReturnKeyGo;
	_verifyField.keyboardType = UIKeyboardTypeASCIICapable;
	_verifyField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_verifyField.placeHolderFont = [UIFont systemFontOfSize:12];
	_verifyField.placeholder = @"请输入右侧验证码";
	_verifyField.textColor = CDColor(nil, @"282828");
	_verifyField.font = [UIFont systemFontOfSize:18];
	_verifyField.autocorrectionType = UITextAutocorrectionTypeNo;
	_verifyField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_verifyField.delegate = self;
	[_verifyView addSubview:_verifyField];
	
	_verifyImage = [[UIImageView alloc] initWithFrame:CGRectMake(228, 0, rect.size.width-228, 40)];
	_verifyImage.clipsToBounds = YES;
	_verifyImage.contentMode = UIViewContentModeScaleAspectFit;
	_verifyImage.userInteractionEnabled = YES;
	[_verifyImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshVerifyCode:)]];
	[_verifyView addSubview:_verifyImage];
	
	_scrollView.contentSize = CGSizeMake(rect.size.width, 240);
	_verifyView.hidden = YES;
}

-(void) showVerifyView
{
	if (!_verifyView.hidden)
		return;
	
	_verifyView.alpha = 0.0f;
	_verifyView.hidden = NO;
	[UIView animateWithDuration:0.3 animations:^{
		_verifyView.alpha = 1.0f;
		[UIHelper setView:_fieldView toHeight:120];
		[UIHelper moveView:_loginButton dX:0 dY:40];
	}];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void) didPresentView
{
	[super didPresentView];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) keyboardWillShown:(NSNotification*)notification
{
	CGRect endRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
	_scrollView.contentInset = UIEdgeInsetsMake(0, 0, endRect.size.height, 0);
	_scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, endRect.size.height, 0);
}

-(void) keyboardWillHide:(NSNotification*)notification
{
	_scrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void) rightButtonAction:(id)sender
{
}

-(void) onLogin:(id)sender
{
	if ([_nameField canResignFirstResponder])
		[_nameField resignFirstResponder];
	if ([_passwordField canResignFirstResponder])
		[_passwordField resignFirstResponder];
	if ([_verifyField canResignFirstResponder])
		[_verifyField resignFirstResponder];
	
	if (_nameField.text.length <= 0)
	{
		[self.view showPopMsg:@"请填写迅雷账号" atY:160 timeout:3];
		[_nameField becomeFirstResponder];
		return;
	}
	
	if (_passwordField.text.length <= 0)
	{
		[self.view showPopMsg:@"请填写密码" atY:160 timeout:3];
		[_passwordField becomeFirstResponder];
		return;
	}
	
	if (!_verifyView.hidden && _verifyField.text.length <= 0)
	{
		[self.view showPopMsg:@"请填写验证码" atY:160 timeout:3];
		[_verifyField becomeFirstResponder];
		return;
	}
	
	[self.view showColorIndicatorFreezeUI:YES];
	
	NSString* appVersion = [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleVersion"];
	[_xlMember initXlMember:53 clientVersion:appVersion peerId:@"peerid"];
	if (_verifyView.hidden)
		[_xlMember loginByUserName:_nameField.text password:_passwordField.text];
	else
		[_xlMember loginByUserName:_nameField.text password:_passwordField.text verifyCode:_verifyField.text];
}

-(void) refreshVerifyCode:(id)sender
{
	[_xlMember requestVerifyCode];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _nameField)
	{
		[_passwordField becomeFirstResponder];
	}
	else if (textField == _passwordField)
	{
		if (_verifyView.hidden)
			[self onLogin:_passwordField];
		else
			[_verifyField becomeFirstResponder];
	}
	else if (textField == _verifyField)
	{
		[self onLogin:_verifyField];
	}
	return YES;
}

/**
 * @brief 登陆操作完成， 通知结果
 * @param code @see XlMemberResultCode
 */
-(void) onLoginResult:(enum XlMemberResultCode)code
{
	[self.view dismiss];
	if (code == XLMEMBER_SUCCESS)
	{
		[_xlMember requestUserInfo];
		NSNumber* uid = [NSNumber numberWithUnsignedLongLong:_xlMember.userId];
		CDSetProp(PropUserID, uid);
		CDSetProp(PropUserAccount, _xlMember.userName);
		CDSetProp(PropUserName, _xlMember.nickName);
		CDSetProp(PropUserSession, _xlMember.sessionId);
		[self.cdNavigationController popViewController];
	}
	else
	{
		NSString* str = @"登录失败，请检查用户名或密码";
		switch (code)
		{
			case XLMEMBER_ACCOUNT_LOCKED:
				str = @"账号被锁定";
				break;
				
			case XLMEMBER_SERVER_UPGRADING:
				str = @"服务器内部升级中，请稍后重试";
				break;
				
			case XLMEMBER_ACCOUNT_EXCEPTION:
			{
				if (_verifyView.hidden)
					str = @"账号异常，请输入验证码再登录";
				else
					str = @"验证码输入错误，请重新输入";
				[self showVerifyView];
				[_xlMember requestVerifyCode];
				if ([_verifyField canBecomeFirstResponder])
					[_verifyField becomeFirstResponder];
				break;
			}
			
			default:
				break;
		}
		[self.view showPopMsg:str atY:160 timeout:5];
	}
}

/**
 * @brief 请求用户信息完成， 通知结果
 * @param code @see XlMemberResultCode
 */
-(void) onUserInfoResult:(enum XlMemberResultCode)code
{
	CDSetProp(PropUserImage, _xlMember.pictureUrl);
}

/**
 * @brief 注销登录完成，或者 用户被迫重新登录回调
 * @param code @see XlMemberResultCode
 * @param type @see XlLogoutType
 */
-(void) onLogoutResult:(enum XlMemberResultCode)code logoutType:(enum XlLogoutType) type
{
}

/**
 * @brief 获取验证码完成
 * @param imagePath 验证码图片本地路径，如果获取失败，则为nil
 */
-(void) onVerfyCodeResult:(NSString *)imagePath
{
	_verifyImage.image = [UIImage imageWithContentsOfFile:imagePath];
}

@end

