//
//  LaunchViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-9.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "LaunchViewController.h"
#import "UIHelper.h"
#import "Properties.h"
#import "MainTabViewController.h"



@interface LaunchViewController ()
{
	NSMutableArray* _labels;
	NSArray* _hotBooks;
}

-(void) tapAction:(id)sender;
-(void) showNext;
-(void) updateView;
-(UILabel*) addLabel:(CGRect)frame color:(UIColor*)color fontSize:(CGFloat)fontSize toView:(UIView*)av;

@end



@implementation LaunchViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_naviBarHeight = 0;
		_hotBooks = CDIDProp(PropAppStartBooks);
    }
    return self;
}

-(void) loadView
{
	[super loadView];
	
	self.view.backgroundColor = CDColor(nil, @"eaeaea");
	
	CGRect rect = self.view.bounds;
	
	UIView* cv = [UIHelper addRect:self.view color:[UIColor clearColor] x:0 y:0 w:rect.size.width h:275 resizing:UIViewAutoresizingFlexibleWidth];
	[cv addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
	
	_labels = [NSMutableArray array];
	[_labels addObject:[self addLabel:CGRectMake(42, 30, 150, 20) color:CDColor(nil, @"3e83e4") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(180, 77, 130, 30) color:CDColor(nil, @"93cb41") fontSize:25 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(131, 117, 175, 30) color:CDColor(nil, @"da7ef7") fontSize:25 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(47, 100, 135, 20) color:CDColor(nil, @"00ae35") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(205, 40, 100, 20) color:CDColor(nil, @"ff6b97") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(97, 56, 150, 30) color:CDColor(nil, @"fa9836") fontSize:25 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(131, 10, 160, 20) color:CDColor(nil, @"3bbae7") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(97, 170, 86, 20) color:CDColor(nil, @"ff6b97") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(184, 204, 120, 20) color:CDColor(nil, @"00ae35") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(66, 204, 110, 20) color:CDColor(nil, @"3e83e4") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(139, 240, 160, 20) color:CDColor(nil, @"8372f6") fontSize:18 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(40, 140, 97, 20) color:CDColor(nil, @"93cb41") fontSize:15 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(245, 150, 65, 20) color:CDColor(nil, @"5ac0e8") fontSize:15 toView:cv]];
	[_labels addObject:[self addLabel:CGRectMake(184, 162, 60, 20) color:CDColor(nil, @"fa9836") fontSize:15 toView:cv]];
	
	[UIHelper moveView:cv toY:(rect.size.height - cv.frame.size.height) / 2.0f];
	
	[self updateView];
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

-(void) didPresentView
{
	[super didPresentView];
	[self performSelector:@selector(showNext) withObject:nil afterDelay:3];
}

-(void) updateView
{
	for (NSInteger i = 0; i < _labels.count; ++i)
		((UILabel*)_labels[i]).text = (i < _hotBooks.count ? _hotBooks[i][@"book_title"] : nil);
}

-(void) tapAction:(UITapGestureRecognizer*)sender
{
	[self showNext];
}

-(void) showNext
{
	self.view.userInteractionEnabled = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	MainTabViewController* vc = [[MainTabViewController alloc] init];
	[self.cdNavigationController setRootViewController:vc inStyle:ASFadeIn outStyle:ASFadeOut];
}

@end




@interface ChooseGenderViewController : CDViewController
{
	UIImageView* _bgView;
}

-(void) tapAction:(id)sender;
-(void) showNext;

@end



@interface FirstLaunchViewController ()

-(void) tapAction:(id)sender;
-(void) showNext;

@end



@implementation FirstLaunchViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_naviBarHeight = 0;
    }
    return self;
}

-(void) loadView
{
	[super loadView];
	
	self.view.backgroundColor = CDColor(nil, @"3bbae7");
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
	
	CGRect rect = self.view.bounds;
	UIImageView* iv = [[UIImageView alloc] initWithImage:CDImage(@"main/launch")];
	[UIHelper moveView:iv toY:rect.size.height-iv.frame.size.height];
	iv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
	[self.view addSubview:iv];
}

-(void) didPresentView
{
	[super didPresentView];
	[self performSelector:@selector(showNext) withObject:nil afterDelay:3];
}

-(void) tapAction:(UITapGestureRecognizer*)sender
{
	[self showNext];
}

-(void) showNext
{
	self.view.userInteractionEnabled = NO;
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	ChooseGenderViewController* vc = [[ChooseGenderViewController alloc] init];
	[self.cdNavigationController setRootViewController:vc inStyle:ASFadeIn outStyle:ASFadeOut];
}

@end



@implementation ChooseGenderViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_naviBarHeight = 0;
    }
    return self;
}

-(void) loadView
{
	[super loadView];
	
	self.view.backgroundColor = CDColor(nil, @"eaeaea");
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
	
	CGRect rect = self.view.bounds;
	_bgView = [[UIImageView alloc] initWithImage:CDImage(@"main/gender_bg")];
	[UIHelper moveView:_bgView toY:(rect.size.height-_bgView.frame.size.height)/2.0f];
	[self.view addSubview:_bgView];
}

-(void) tapAction:(UITapGestureRecognizer*)sender
{
	CGPoint location = [sender locationInView:_bgView];
	if (CGRectContainsPoint(CGRectMake(116, 213, 88, 26), location))
	{
		CDSetProp(PropStoreChannel, @"1");
		[self showNext];
	}
	else if (CGRectContainsPoint(CGRectMake(116, 375, 88, 26), location))
	{
		CDSetProp(PropStoreChannel, @"0");
		[self showNext];
	}
}

-(void) showNext
{
	self.view.userInteractionEnabled = NO;
	MainTabViewController* vc = [[MainTabViewController alloc] init];
	[self.cdNavigationController setRootViewController:vc inStyle:ASFadeIn outStyle:ASFadeOut];
}

@end

