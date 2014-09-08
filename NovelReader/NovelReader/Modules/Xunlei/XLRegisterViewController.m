//
//  XLRegisterViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-28.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "XLRegisterViewController.h"
#import "UIHelper.h"
#import "KYTipsView.h"
#import "CDCustomViews.h"
#import "Properties.h"
#import "RegexKitLite.h"
#import "xlmember/XlMemberIosAdapter.h"
#import "xlmember/XlMemberRegistorIosAdapter.h"
#import "XLWebViewController.h"



@interface XLRegisterViewController () <UITextFieldDelegate, XlMemberRegisteEvents, XlMemberEvents>
{
	UIScrollView* _scrollView;
	
	UIButton* _phoneButton;
	UIButton* _emailButton;
	
	UIView* _phoneView;
	CDCustomTextField* _phoneField;
	CDCustomTextField* _phonePasswordField;
	CDCustomTextField* _phoneVerifyField;
	CDCustomTextField* _phoneNickField;
	UIButton* _verifyButton;
	NSTimer* _verifyTimer;
	
	UIView* _emailView;
	CDCustomTextField* _emailField;
	CDCustomTextField* _emailPasswordField;
	CDCustomTextField* _emailVerifyField;
	CDCustomTextField* _emailNickField;
	UIImageView* _verifyImage;
	
	void (^_successBlock)(void);
}

-(void) switchAction:(UIButton*)sender;
-(void) onRegister:(id)sender;
-(void) refreshVerifyCode:(id)sender;
-(void) showEULAAction:(id)sender;
-(void) verifyPhone:(id)sender;
-(void) keyboardWillShown:(NSNotification*)notification;
-(void) keyboardWillHide:(NSNotification*)notification;
-(void) updateTabButton;
-(void) resignAllField;
-(void) updateVerifyButton:(NSTimer*)timer;

@end



@implementation XLRegisterViewController

-(id) init
{
    self = [super init];
    if (self)
	{
    }
    return self;
}

-(void) dealloc
{
	[[XlMemberIosAdapter instance] removeObserver:self];
}

-(void) setSuccessBlock:(void (^)(void))block
{
	_successBlock = [block copy];
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = @"注册";
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	self.rightButton.titleLabel.font = [UIFont systemFontOfSize:12];
	
	CGRect rect = self.view.bounds;
	
	_scrollView = [[UIScrollView alloc]	initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.bounces = NO;
	_scrollView.backgroundColor = CDColor(nil, @"e7e7e7");
	[self.view addSubview:_scrollView];
	
	_phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 8.5, 140, 30)];
	_phoneButton.titleLabel.font = [UIFont systemFontOfSize:12];
	[_phoneButton setTitle:@"手机号注册" forState:UIControlStateNormal];
	[_phoneButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_phoneButton];
	
	_emailButton = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width-10-140, 8.5, 140, 30)];
	_emailButton.titleLabel.font = [UIFont systemFontOfSize:12];
	[_emailButton setTitle:@"邮箱注册" forState:UIControlStateNormal];
	[_emailButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:_emailButton];
	
	_phoneView = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:47 w:rect.size.width h:160 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_phoneView color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_phoneView color:CDColor(nil, @"d1d1d1") x:0 y:159.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_phoneView color:CDColor(nil, @"d1d1d1") x:10 y:40 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_phoneView color:CDColor(nil, @"d1d1d1") x:10 y:80 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_phoneView color:CDColor(nil, @"d1d1d1") x:10 y:120 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_phoneView color:CDColor(nil, @"d1d1d1") x:220 y:0 w:0.5f h:40 resizing:0];
	
	UIImageView* imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/name_icon")];
	[UIHelper moveView:imageView toX:6 andY:10];
	[_phoneView addSubview:imageView];
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/pwd_icon")];
	[UIHelper moveView:imageView toX:6 andY:9+40];
	[_phoneView addSubview:imageView];
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/pwd_icon")];
	[UIHelper moveView:imageView toX:6 andY:9+80];
	[_phoneView addSubview:imageView];
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/name_icon")];
	[UIHelper moveView:imageView toX:6 andY:10+120];
	[_phoneView addSubview:imageView];
	
	_phoneField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 4, 150, 32)];
	_phoneField.returnKeyType = UIReturnKeyNext;
	_phoneField.keyboardType = UIKeyboardTypeNumberPad;
	_phoneField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_phoneField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_phoneField.placeHolderFont = [UIFont systemFontOfSize:12];
	_phoneField.placeholder = @"11位手机号";
	_phoneField.textColor = CDColor(nil, @"282828");
	_phoneField.font = [UIFont systemFontOfSize:18];
	_phoneField.autocorrectionType = UITextAutocorrectionTypeNo;
	_phoneField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_phoneField.delegate = self;
	[_phoneView addSubview:_phoneField];
	
	_phoneVerifyField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 44, 268, 32)];
	_phoneVerifyField.returnKeyType = UIReturnKeyNext;
	_phoneVerifyField.keyboardType = UIKeyboardTypeNumberPad;
	_phoneVerifyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_phoneVerifyField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_phoneVerifyField.placeHolderFont = [UIFont systemFontOfSize:12];
	_phoneVerifyField.placeholder = @"手机验证码";
	_phoneVerifyField.textColor = CDColor(nil, @"282828");
	_phoneVerifyField.font = [UIFont systemFontOfSize:18];
	_phoneVerifyField.delegate = self;
	[_phoneView addSubview:_phoneVerifyField];
	
	_phonePasswordField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 84, 268, 32)];
	_phonePasswordField.returnKeyType = UIReturnKeyNext;
	_phonePasswordField.keyboardType = UIKeyboardTypeASCIICapable;
	_phonePasswordField.secureTextEntry = YES;
	_phonePasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_phonePasswordField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_phonePasswordField.placeHolderFont = [UIFont systemFontOfSize:12];
	_phonePasswordField.placeholder = @"6-32位密码";
	_phonePasswordField.textColor = CDColor(nil, @"282828");
	_phonePasswordField.font = [UIFont systemFontOfSize:18];
	_phonePasswordField.delegate = self;
	[_phoneView addSubview:_phonePasswordField];
	
	_phoneNickField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 124, 268, 32)];
	_phoneNickField.returnKeyType = UIReturnKeyGo;
	_phoneNickField.keyboardType = UIKeyboardTypeDefault;
	_phoneNickField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_phoneNickField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_phoneNickField.placeHolderFont = [UIFont systemFontOfSize:12];
	_phoneNickField.placeholder = @"昵称";
	_phoneNickField.textColor = CDColor(nil, @"282828");
	_phoneNickField.font = [UIFont systemFontOfSize:18];
	_phoneNickField.delegate = self;
	[_phoneView addSubview:_phoneNickField];
	
	_verifyButton = [[UIButton alloc] initWithFrame:CGRectMake(220, 0, 100, 40)];
	[_verifyButton setTitleColor:CDColor(nil, @"ec6327") forState:UIControlStateNormal];
	[_verifyButton setTitleColor:CDColor(nil, @"c9c9c9") forState:UIControlStateDisabled];
	_verifyButton.titleLabel.font = [UIFont systemFontOfSize:12];
	[_verifyButton setTitle:@"验证" forState:UIControlStateNormal];
	[_verifyButton addTarget:self action:@selector(verifyPhone:) forControlEvents:UIControlEventTouchUpInside];
	[_phoneView addSubview:_verifyButton];
	
	
	_emailView = [UIHelper addRect:_scrollView color:[UIColor whiteColor] x:0 y:47 w:rect.size.width h:160 resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_emailView color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_emailView color:CDColor(nil, @"d1d1d1") x:0 y:159.5f w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_emailView color:CDColor(nil, @"d1d1d1") x:10 y:40 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_emailView color:CDColor(nil, @"d1d1d1") x:10 y:80 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_emailView color:CDColor(nil, @"d1d1d1") x:10 y:120 w:rect.size.width-10 h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	[UIHelper addRect:_emailView color:CDColor(nil, @"d1d1d1") x:227 y:80 w:0.5f h:40 resizing:0];
	
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/name_icon")];
	[UIHelper moveView:imageView toX:6 andY:10];
	[_emailView addSubview:imageView];
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/pwd_icon")];
	[UIHelper moveView:imageView toX:6 andY:9+40];
	[_emailView addSubview:imageView];
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/pwd_icon")];
	[UIHelper moveView:imageView toX:6 andY:9+80];
	[_emailView addSubview:imageView];
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"user/name_icon")];
	[UIHelper moveView:imageView toX:6 andY:10+120];
	[_emailView addSubview:imageView];
	
	_emailField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 4, 268, 32)];
	_emailField.returnKeyType = UIReturnKeyNext;
	_emailField.keyboardType = UIKeyboardTypeEmailAddress;
	_emailField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_emailField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_emailField.placeHolderFont = [UIFont systemFontOfSize:12];
	_emailField.placeholder = @"请输入邮箱";
	_emailField.textColor = CDColor(nil, @"282828");
	_emailField.font = [UIFont systemFontOfSize:18];
	_emailField.autocorrectionType = UITextAutocorrectionTypeNo;
	_emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_emailField.delegate = self;
	[_emailView addSubview:_emailField];
	
	_emailPasswordField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 44, 268, 32)];
	_emailPasswordField.returnKeyType = UIReturnKeyNext;
	_emailPasswordField.keyboardType = UIKeyboardTypeASCIICapable;
	_emailPasswordField.secureTextEntry = YES;
	_emailPasswordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_emailPasswordField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_emailPasswordField.placeHolderFont = [UIFont systemFontOfSize:12];
	_emailPasswordField.placeholder = @"6-32位密码";
	_emailPasswordField.textColor = CDColor(nil, @"282828");
	_emailPasswordField.font = [UIFont systemFontOfSize:18];
	_emailPasswordField.delegate = self;
	[_emailView addSubview:_emailPasswordField];
	
	_emailVerifyField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 84, 160, 32)];
	_emailVerifyField.returnKeyType = UIReturnKeyNext;
	_emailVerifyField.keyboardType = UIKeyboardTypeASCIICapable;
	_emailVerifyField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_emailVerifyField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_emailVerifyField.placeHolderFont = [UIFont systemFontOfSize:12];
	_emailVerifyField.placeholder = @"请输入右边验证码";
	_emailVerifyField.textColor = CDColor(nil, @"282828");
	_emailVerifyField.font = [UIFont systemFontOfSize:18];
	_emailVerifyField.autocorrectionType = UITextAutocorrectionTypeNo;
	_emailVerifyField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_emailVerifyField.delegate = self;
	[_emailView addSubview:_emailVerifyField];
	
	_emailNickField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(36, 124, 268, 32)];
	_emailNickField.returnKeyType = UIReturnKeyGo;
	_emailNickField.keyboardType = UIKeyboardTypeDefault;
	_emailNickField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_emailNickField.placeHolderColor = CDColor(nil, @"c9c9c9");
	_emailNickField.placeHolderFont = [UIFont systemFontOfSize:12];
	_emailNickField.placeholder = @"昵称";
	_emailNickField.textColor = CDColor(nil, @"282828");
	_emailNickField.font = [UIFont systemFontOfSize:18];
	_emailNickField.delegate = self;
	[_emailView addSubview:_emailNickField];
	
	_verifyImage = [[UIImageView alloc] initWithFrame:CGRectMake(228, 80, rect.size.width-228, 40)];
	_verifyImage.clipsToBounds = YES;
	_verifyImage.contentMode = UIViewContentModeScaleAspectFit;
	_verifyImage.userInteractionEnabled = YES;
	[_verifyImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(refreshVerifyCode:)]];
	[_emailView addSubview:_verifyImage];
	
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(10, 232, 300, 40)];
	[button setBackgroundImage:CDImage(@"user/button_bg2") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"user/button_bg1") forState:UIControlStateDisabled];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setTitleColor:CDColor(nil, @"d8d8d8") forState:UIControlStateDisabled];
	button.titleLabel.font = [UIFont systemFontOfSize:14];
	[button setTitle:@"注册" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(onRegister:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:button];
	
	NSMutableAttributedString* s = [[NSMutableAttributedString alloc] initWithString:@"已阅读并同意《迅雷网络服务使用协议》"];
	[s addAttribute:NSForegroundColorAttributeName value:CDColor(nil, @"098ad9") range:NSMakeRange(6, 12)];
	[UIHelper addLabel:_scrollView t:nil tc:CDColor(nil, @"969696") fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, 281, rect.size.width, 25)].attributedText = s;
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(128, 281, 141, 25)];
	[button addTarget:self action:@selector(showEULAAction:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:button];
	
	_scrollView.contentSize = CGSizeMake(rect.size.width, 312);
	
	_emailView.hidden = YES;
	[self updateTabButton];
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	[[XlMemberRegistorIosAdapter instance] initXLMemberRegiste];
}

-(void) updateTabButton
{
	BOOL phone = _emailView.hidden;
	[_phoneButton setBackgroundImage:(phone ? CDImage(@"user/tab_bg") : nil) forState:UIControlStateNormal];
	[_phoneButton setBackgroundImage:(phone ? CDImage(@"user/tab_bg") : nil) forState:UIControlStateHighlighted];
	[_phoneButton setTitleColor:(phone ? [UIColor whiteColor] : [UIColor blackColor]) forState:UIControlStateNormal];
	[_phoneButton setTitleColor:(phone ? [UIColor whiteColor] : [UIColor blackColor]) forState:UIControlStateHighlighted];
	[_emailButton setBackgroundImage:(!phone ? CDImage(@"user/tab_bg") : nil) forState:UIControlStateNormal];
	[_emailButton setBackgroundImage:(!phone ? CDImage(@"user/tab_bg") : nil) forState:UIControlStateHighlighted];
	[_emailButton setTitleColor:(!phone ? [UIColor whiteColor] : [UIColor blackColor]) forState:UIControlStateNormal];
	[_emailButton setTitleColor:(!phone ? [UIColor whiteColor] : [UIColor blackColor]) forState:UIControlStateHighlighted];
}

-(void) resignAllField
{
	if (_phoneField.canResignFirstResponder)
		[_phoneField resignFirstResponder];
	if (_phoneVerifyField.canResignFirstResponder)
		[_phoneVerifyField resignFirstResponder];
	if (_phonePasswordField.canResignFirstResponder)
		[_phonePasswordField resignFirstResponder];
	if (_phoneNickField.canResignFirstResponder)
		[_phoneNickField resignFirstResponder];
	if (_emailField.canResignFirstResponder)
		[_emailField resignFirstResponder];
	if (_emailPasswordField.canResignFirstResponder)
		[_emailPasswordField resignFirstResponder];
	if (_emailVerifyField.canResignFirstResponder)
		[_emailVerifyField resignFirstResponder];
	if (_emailNickField.canResignFirstResponder)
		[_emailNickField resignFirstResponder];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	[XlMemberRegistorIosAdapter instance].registe_delegate = self;
	[self updateVerifyButton:nil];
}

-(void) didPresentView
{
	[super didPresentView];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[XlMemberRegistorIosAdapter instance].registe_delegate = nil;
	[_verifyTimer invalidate];
	_verifyTimer = nil;
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

-(void) switchAction:(UIButton*)sender
{
	if (sender == _phoneButton && !_emailView.hidden)
	{
		[self resignAllField];
		_emailView.hidden = YES;
		_phoneView.hidden = NO;
		[self updateTabButton];
	}
	else if (sender == _emailButton && _emailView.hidden)
	{
		[self resignAllField];
		_emailView.hidden = NO;
		_phoneView.hidden = YES;
		[self updateTabButton];
		[[XlMemberRegistorIosAdapter instance] getVerifyCode];
	}
}

-(void) onRegister:(id)sender
{
	[self resignAllField];
	
	if (_emailView.hidden)
	{
		if (_phoneField.text.length != 11)
		{
			[self.view showPopMsg:@"请填写11位手机号" atY:200 timeout:3];
			[_phoneField becomeFirstResponder];
			return;
		}
		
		if (_phoneVerifyField.text.length <= 0)
		{
			[self.view showPopMsg:@"请填写收到的验证码" atY:200 timeout:3];
			[_phoneVerifyField becomeFirstResponder];
			return;
		}
		
		if (_phonePasswordField.text.length < 6 || _phonePasswordField.text.length > 32)
		{
			[self.view showPopMsg:@"密码长度应该在6-32位之间" atY:200 timeout:3];
			[_phonePasswordField becomeFirstResponder];
			return;
		}
		
		if (_phoneNickField.text.length <= 0)
		{
			[self.view showPopMsg:@"请填写昵称" atY:200 timeout:3];
			[_phoneNickField becomeFirstResponder];
			return;
		}
		
		[self.view showColorIndicatorFreezeUI:YES];
		[[XlMemberRegistorIosAdapter instance] registe:_phoneField.text :_phonePasswordField.text :_phoneNickField.text :_phoneVerifyField.text :@""];
	}
	else
	{
		if (_emailField.text.length <= 0)
		{
			[self.view showPopMsg:@"请填写邮箱地址" atY:200 timeout:3];
			[_emailField becomeFirstResponder];
			return;
		}
		
		if (_emailPasswordField.text.length < 6 || _emailPasswordField.text.length > 32)
		{
			[self.view showPopMsg:@"密码长度应该在6-32位之间" atY:200 timeout:3];
			[_emailPasswordField becomeFirstResponder];
			return;
		}
		
		if (_emailVerifyField.text.length <= 0)
		{
			[self.view showPopMsg:@"请填写验证码" atY:200 timeout:3];
			[_emailVerifyField becomeFirstResponder];
			return;
		}
		
		if (_emailNickField.text.length <= 0)
		{
			[self.view showPopMsg:@"请填写昵称" atY:200 timeout:3];
			[_emailNickField becomeFirstResponder];
			return;
		}
		
		if (![_emailField.text isMatchedByRegex:@"^[\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+$"])
		{
			[self.view showPopMsg:@"邮箱地址格式不正确" atY:200 timeout:3];
			return;
		}
		
		[self.view showColorIndicatorFreezeUI:YES];
		[[XlMemberRegistorIosAdapter instance] registe:_emailField.text :_emailPasswordField.text :_emailNickField.text :@"" :_emailVerifyField.text];
	}
}

-(void) refreshVerifyCode:(id)sender
{
	[[XlMemberRegistorIosAdapter instance] getVerifyCode];
}

-(void) showEULAAction:(id)sender
{
	XLWebViewController* vc = [[XLWebViewController alloc] init];
	vc.pageURL = [NSString stringWithFormat:@"%@agreement.html", [Properties appProperties].XLWebHost];
	[self.cdNavigationController pushViewController:vc];
}

-(void) verifyPhone:(id)sender
{
	[self resignAllField];
	
	if (_phoneField.text.length != 11)
	{
		[self.view showPopMsg:@"请填写11位手机号" atY:200 timeout:3];
		[_phoneField becomeFirstResponder];
		return;
	}
	
	[[XlMemberRegistorIosAdapter instance] sendSms:_phoneField.text];
	[Properties appProperties].lastVerifyDate = [NSDate date];
	[self updateVerifyButton:nil];
}

-(void) updateVerifyButton:(NSTimer*)timer
{
	Properties* prop = [Properties appProperties];
	NSTimeInterval interval = fabs([[NSDate date] timeIntervalSinceDate:prop.lastVerifyDate]);
	if (prop.lastVerifyDate == nil || interval > prop.minVerifyInterval)
	{
		[_verifyTimer invalidate];
		_verifyTimer = nil;
		_verifyButton.enabled = YES;
	}
	else
	{
		_verifyButton.enabled = NO;
		[_verifyButton setTitle:[NSString stringWithFormat:@"重新发送(%.0f)", prop.minVerifyInterval-interval] forState:UIControlStateDisabled];
		if (_verifyTimer == nil)
			_verifyTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateVerifyButton:) userInfo:nil repeats:YES];
	}
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _phoneField)
	{
		[_phoneVerifyField becomeFirstResponder];
	}
	else if (textField == _phoneVerifyField)
	{
		[_phonePasswordField becomeFirstResponder];
	}
	else if (textField == _phonePasswordField)
	{
		[_phoneNickField becomeFirstResponder];
	}
	else if (textField == _phoneNickField)
	{
		[self onRegister:nil];
	}
	else if (textField == _emailField)
	{
		[_emailPasswordField becomeFirstResponder];
	}
	else if (textField == _emailPasswordField)
	{
		[_emailVerifyField becomeFirstResponder];
	}
	else if (textField == _emailVerifyField)
	{
		[_emailNickField becomeFirstResponder];
	}
	else if (textField == _emailNickField)
	{
		[self onRegister:nil];
	}
	return YES;
}

/**
 * @brief 检测绑定完成
 * @Param result 检测绑定的结果
 * @Param error_msg 错误信息
 */
-(void) onCheckBindResult:(int)result :(NSString*)error_msg
{
}

/**
 * @brief 检测密码完成
 * @param result 返回结果
 * @param error_msg 错误信息
 */
-(void) onCheckPassWordResult:(int)result :(NSString*)error_msg
{
}

/**
 * @brief 获取图像验证码完成
 * @param path 图像验证码的存储路径
 */
-(void) onVerifyProtocolResult:(NSString*)path
{
	_verifyImage.image = [UIImage imageWithContentsOfFile:path];
}

/**
 * @brief 发送手机验证码完成
 * @param result 返回结果
 * @param error_msg 错误信息
 */
-(void) onSendSmsResult:(int)result :(NSString*)error_msg
{
	if (result != 0)
		[self.view showPopMsg:error_msg atY:200 timeout:5];
}

/**
 * @brief 注册账号完成
 * @param result 返回结果
 * @param errorinfo 错误信息
 * @param rrinfo 服务器返回的信息：
 * 使用 "username“  "nickname" "uid" "usernewno" "sessionid" 作为键，来获取相应的值
 */
-(void) onRegisteResult:(int)result :(NSMutableDictionary*)rrinfo :(NSString*)errorinfo
{
	if (result == 0)
	{
		NSString* account = [rrinfo objectForKey:@"username"];
		CDSetProp(PropUserAccount, account);
		NSString* pwd = _emailPasswordField.text;
		if (_emailView.hidden)
			pwd = _phoneField.text;
		
		XlMemberIosAdapter* xlMember = [XlMemberIosAdapter instance];
		[xlMember initXlMember:[Properties appProperties].XLMemberAppID clientVersion:[Properties appProperties].APPVersion peerId:@"peerid"];
		[xlMember addObserver:self];
		[xlMember loginByUserName:account password:pwd];
	}
	else
	{
		[self.view dismiss];
		[self.view showPopMsg:errorinfo atY:200 timeout:5];
	}
}

-(void) onLoginResult:(enum XlMemberResultCode)code
{
	[self.view dismiss];
	if (code == XLMEMBER_SUCCESS)
	{
		if (_successBlock != NULL)
			_successBlock();
		else
			[self.cdNavigationController popToRootViewController];
	}
	else
	{
		[self.view showPopMsg:@"注册成功，请重新登录" atY:200 timeout:5];
	}
}

@end

