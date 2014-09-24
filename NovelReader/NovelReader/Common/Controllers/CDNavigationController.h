//
//  CDNavigationController.h
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-15.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//


extern NSString* const CDNavigationWillPushNotification;
extern NSString* const CDNavigationWillPopNotification;
extern NSString* const CDNavigationWillSwitchNotification;

@class CDNavigationController;

CDNavigationController* getNaviController(void);

typedef NS_OPTIONS(NSInteger, AnimationOptions)
{
	ASNone = 0,
	ASTranslationToLeft,
	ASTranslationToRight,
	ASTranslationUp,
	ASTranslationDown,
	ASFadeIn,
	ASFadeOut,
	ASFallBehind,
	ASLiftForward,
	
	ASNatureIn,
	ASNatureOut,

	ASResultNone		= 0 << 8,
	ASResultDelete		= 1 << 8
};


@interface CDNavigationController : UIViewController

@property (nonatomic, readonly) UIViewController* currentController;

-(id) initWithRootViewController:(UIViewController*)rootViewController;

-(UIViewController*) getRootViewController;

-(void) pushViewController:(UIViewController*)controller;
-(void) pushViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle;
-(void) pushViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration;

-(void) popViewController;
-(void) popViewControllerWithInStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle;
-(void) popViewControllerWithInStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration;

-(void) popToRootViewController;
-(void) popToViewController:(UIViewController *)controller;
-(void) popToViewController:(UIViewController *)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle;
-(void) popToViewController:(UIViewController *)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration;

-(void) setRootViewController:(UIViewController*)controller;
-(void) setRootViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle;
-(void) setRootViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration;

-(void) setViewController:(UIViewController*)controller afterController:(UIViewController*)foreController;

@end



@interface UIViewController (CDNavigationController)

@property (readonly) CDNavigationController* cdNavigationController;
@property (readonly) BOOL shouldPopoutOnSwipe;

-(void) willPresentView:(NSTimeInterval)duration;
-(void) willDismissView:(NSTimeInterval)duration;
-(void) didPresentView;
-(void) didDismissView;
-(void) doingPresentView;
-(void) doingDismissView;

@end

