//
//  SearchBookViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "SearchBookViewController.h"
#import "UIHelper.h"
#import "Models.h"
#import "Properties.h"
#import "CDCustomViews.h"
#import "RestfulAPIGetter.h"
#import "XLWebViewController.h"
#import "Encodings.h"



@interface SearchBookViewController () <GetterControllerOwner, UITextFieldDelegate>
{
	GetterController* _getterController;
	
	UIScrollView* _scrollView;
	CDCustomTextField* _keywordField;
	UIButton* _refreshButton;
	NSMutableArray* _labels;
	UIView* _bg;
	
	NSArray* _hotkeys;
}

-(void) updateView;
-(void) search;
-(void) refreshAction:(id)sender;
-(void) hotwordAction:(UITapGestureRecognizer*)sender;
-(void) keyboardWillShown:(NSNotification*)notification;
-(void) keyboardWillHide:(NSNotification*)notification;
-(UILabel*) addLabel:(CGRect)frame color:(UIColor*)color fontSize:(CGFloat)fontSize toView:(UIView*)av;

@end



@implementation SearchBookViewController

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
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	[self.rightButton setImage:CDImage(@"store/search") forState:UIControlStateNormal];
	self.rightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -15.0f);
	
	CGRect rect = self.view.bounds;
	
	_bg=[UIHelper addRect:self.naviBarView color:[UIColor whiteColor] x:50 y:_statusBarHeight+10 w:rect.size.width-50*2 h:25 resizing:UIViewAutoresizingFlexibleWidth];
	_keywordField = [[CDCustomTextField alloc] initWithFrame:CGRectMake(7, 0, rect.size.width-57*2, 25)];
	_keywordField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_keywordField.returnKeyType = UIReturnKeySearch;
	_keywordField.keyboardType = UIKeyboardTypeDefault;
	_keywordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	_keywordField.placeHolderColor = CDColor(nil, @"a7a7a7");
	_keywordField.placeHolderFont = [UIFont systemFontOfSize:13];
	_keywordField.placeholder = @"请输入书名或作者名";
	_keywordField.textColor = CDColor(nil, @"282828");
	_keywordField.font = [UIFont systemFontOfSize:15];
	_keywordField.delegate = self;
	[_bg addSubview:_keywordField];
	
	_scrollView = [[UIScrollView alloc]	initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight)];
	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_scrollView.directionalLockEnabled = YES;
	_scrollView.alwaysBounceVertical = YES;
	_scrollView.backgroundColor = CDColor(nil, @"ffffff");
	[self.view addSubview:_scrollView];
	
	UIView* cv = [UIHelper addRect:_scrollView color:[UIColor clearColor] x:0 y:0 w:rect.size.width h:200 resizing:UIViewAutoresizingFlexibleWidth];
	[cv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hotwordAction:)]];
	
	_labels = [NSMutableArray array];
	[_labels addObject:[self addLabel:CGRectMake(42, 30, 150, 20) color:CDColor(nil, @"3e83e4") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(180, 69, 130, 30) color:CDColor(nil, @"93cb41") fontSize:25 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(131, 109, 175, 30) color:CDColor(nil, @"da7ef7") fontSize:25 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(47, 91, 135, 20) color:CDColor(nil, @"00ae35") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(205, 40, 100, 20) color:CDColor(nil, @"ff6b97") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(97, 56, 109, 30) color:CDColor(nil, @"fa9836") fontSize:25 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(131, 10, 160, 20) color:CDColor(nil, @"3bbae7") fontSize:18 toView:cv]];
	
	UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake((rect.size.width-116)/2, 165, 116, 25)];
	[button setBackgroundImage:[CDImage(@"main/button_bg1") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forState:UIControlStateNormal];
	[button setBackgroundImage:[CDImage(@"main/button_bg2") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 20, 0, 20)] forState:UIControlStateHighlighted];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
	[button setTitleColor:CDColor(nil, @"ec6226") forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont systemFontOfSize:12];
	[button setTitle:@"换一换" forState:UIControlStateNormal];
	[button addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventTouchUpInside];
	[cv addSubview:button];
	_refreshButton = button;
	
	CGFloat theY = (_scrollView.bounds.size.height - 240 - cv.frame.size.height) / 2.0f;
	if (theY > 0.0f)
		[UIHelper moveView:cv toY:theY];
	
	_scrollView.contentSize = CGSizeMake(rect.size.width, CGRectGetMaxY(cv.frame));
}

-(UILabel*) addLabel:(CGRect)frame color:(UIColor*)color fontSize:(CGFloat)fontSize toView:(UIView*)av
{
	UILabel* label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentLeft;
	label.textColor = color;
	label.font = [UIFont fontWithName:@"Palatino-Bold" size:fontSize];
	[av addSubview:label];
	return label;
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShown:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	if (_keywordField.canBecomeFirstResponder)
		[_keywordField becomeFirstResponder];
	
	if (_getterController.dataStatus == DataStatusUnInit)
	{
		_getterController.dataStatus = DataStatusLoadingAnimated;
		[self refreshAction:nil];
	}
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

-(void) updateView
{
	for (NSInteger i = 0; i < _labels.count; ++i)
		((UILabel*)_labels[i]).text = (i < _hotkeys.count ? _hotkeys[i] : nil);
}

-(void) refreshAction:(id)sender
{
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"site", @"a" : @"hotsearchkey"};
	[_getterController launchGetter:getter];
}

-(void) hotwordAction:(UITapGestureRecognizer*)sender
{
	CGPoint location = [sender locationInView:sender.view];
	for (UILabel* label in _labels)
	{
		if (CGRectContainsPoint(label.frame, location))
		{
			_keywordField.text = label.text;
			[self search];
		}
	}
}

-(void) rightButtonAction:(id)sender
{
	[self search];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	[self search];
	return YES;
}

-(void) search
{
	if (_keywordField.text.length <= 0)
	{
		[UIHelper shakeView:_bg scope:5.0f];
		return;
	}
	
	XLWebViewController* vc = [[XLWebViewController alloc] init];
	vc.pageTitle = @"搜索结果";
	vc.pageURL = [NSString stringWithFormat:@"%@list.html?keyword=%@", [Properties appProperties].XLWebHost, [_keywordField.text urlEncode:NSUTF8StringEncoding]];
	[self.cdNavigationController pushViewController:vc];
}

-(void) handleGetter:(id<Getter>)getter
{
	if ([getter resultCode] == KYResultCodeSuccess)
	{
		id data = ((RestfulAPIGetter*)getter).result[@"data"];
		if ([data isKindOfClass:[NSArray class]])
		{
			_hotkeys = [data copy];
			[self updateView];
		}
	}
}

@end
