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
#import "Models.h"
#import "Properties.h"



@interface XLLoginViewController () <GetterControllerOwner, UITextFieldDelegate>
{
	GetterController* _getterController;
	
	UIScrollView* _scrollView;
	UITextField* _nameField;
	UITextField* _passwordField;
	UITextField* _verifyField;
}

-(void) onLogin:(id)sender;
-(void) keyboardWillShown:(NSNotification*)notification;
-(void) keyboardWillHide:(NSNotification*)notification;

@end



@implementation XLLoginViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_getterController = [[GetterController alloc] initWithOwner:self];
    }
    return self;
}

- (void)dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	CGRect rect = self.view.bounds;
	
	_scrollView = [[UIScrollView alloc]	initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.bounces = NO;
	_scrollView.backgroundColor = CDColor(nil, @"e7e7e7");
	[self.view addSubview:_scrollView];
	
	UIImageView* imageView = [[UIImageView alloc] initWithImage:CDImage(@"login/small_logo")];
	[UIHelper moveView:imageView toX:10 andY:8];
	[_scrollView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"login/title_logo")];
	[UIHelper moveView:imageView toX:13 andY:75];
	[_scrollView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 153, 280, 44)];
	imageView.image = CDImage(@"login/input_border");
	[_scrollView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 153+44+14, 280, 44)];
	imageView.image = CDImage(@"login/input_border");
	[_scrollView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"login/user_icon")];
	imageView.center = CGPointMake(40, 153+22);
	[_scrollView addSubview:imageView];
	
	imageView = [[UIImageView alloc] initWithImage:CDImage(@"login/password_icon")];
	imageView.center = CGPointMake(40, 153+44+14+22);
	[_scrollView addSubview:imageView];
	
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(20, 153+44+14+44+25, 280, 82)];
	[button setBackgroundImage:CDImage(@"login/login_button") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"login/login_button_hightlight") forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(onLogin:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:button];
	
	_nameField = [[UITextField alloc] initWithFrame:CGRectMake(62, 153+9, 320-72-30, 32)];
	_nameField.returnKeyType = UIReturnKeyNext;
	_nameField.keyboardType = UIKeyboardTypeASCIICapable;
	_nameField.placeholder = @"用户名";
	_nameField.textColor = [UIColor whiteColor];
	_nameField.autocorrectionType = UITextAutocorrectionTypeNo;
	_nameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	_nameField.text = CDProp(PropUserAccount);
	_nameField.delegate = self;
	[_scrollView addSubview:_nameField];
	
	_passwordField = [[UITextField alloc] initWithFrame:CGRectMake(62, 153+9+44+14, 320-72-30, 32)];
	_passwordField.returnKeyType = UIReturnKeyGo;
	_passwordField.keyboardType = UIKeyboardTypeASCIICapable;
	_passwordField.secureTextEntry = YES;
	_passwordField.placeholder = @"密码";
	_passwordField.textColor = [UIColor whiteColor];
	_passwordField.text = CDProp(PropUserPassword);
	_passwordField.delegate = self;
	[_scrollView addSubview:_passwordField];
	
	button = [[UIButton alloc] initWithFrame:CGRectMake(rect.size.width - 73 - 20, _scrollView.bounds.size.height - 70, 73, 38)];
	[button setBackgroundImage:CDImage(@"register/register") forState:UIControlStateNormal];
	[button setBackgroundImage:CDImage(@"register/register_pushed") forState:UIControlStateHighlighted];
	[button addTarget:self action:@selector(onRegister:) forControlEvents:UIControlEventTouchUpInside];
	[_scrollView addSubview:button];
	
	_scrollView.contentSize = CGSizeMake(rect.size.width, _scrollView.bounds.size.height);
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
	
	if (_nameField.text.length <= 0)
	{
		[self.view showPopMsg:@"请填写用户名" timeout:2];
		return;
	}
	
	if (_passwordField.text.length <= 0)
	{
		[self.view showPopMsg:@"请填写密码" timeout:2];
		return;
	}
	
	[self.view showColorIndicatorFreezeUI:YES];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	if (textField == _nameField)
	{
		[_passwordField becomeFirstResponder];
	}
	else if (textField == _passwordField)
	{
		[self onLogin:_passwordField];
	}
	return YES;
}

-(void) handleGetter:(id<Getter>)getter
{
	[self.view dismiss];
}

@end
