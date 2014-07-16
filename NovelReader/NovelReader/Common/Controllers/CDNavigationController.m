//
//  CDNavigationController.m
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-15.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "CDNavigationController.h"
#import <objc/runtime.h>
#import "CDViewController.h"


NSString* const CDNavigationWillPushNotification = @"CDNavigationWillPushNotification";
NSString* const CDNavigationWillPopNotification = @"CDNavigationWillPopNotification";
NSString* const CDNavigationWillSwitchNotification = @"CDNavigationWillSwitchNotification";

CDNavigationController* getNaviController(void)
{
	return (CDNavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
}

@interface UIViewController (_CDNavigationController)
@property (readwrite) CDNavigationController* cdNavigationController;
@end

@implementation UIViewController (_CDNavigationController)
@dynamic cdNavigationController;
@end




@interface CDNavigationController()

/**
 从fromController切换到toController。使用时结合fromStyle, toStyle, isToAbove这三个参数可以实现不同的切换效果
 @param fromController 旧的controller
 @param fromStyle 旧的controller消失的动画方式
 @param toController 新的controller
 @param toStyle 新来的controller出现的动画方式
 @param isToAbove 为YES表示新来的controller会压在原有controller的前面，否则将放到原来controller后面
 @param duration 动画时间
 */
-(void) switchFromController:(UIViewController*)fromController
				   fromStyle:(AnimationOptions)fromStyle
				toController:(UIViewController*)toController
					 toStyle:(AnimationOptions)toStyle
				   isToAbove:(BOOL)isToAbove
					duration:(NSTimeInterval)duration;

@end



@implementation CDNavigationController
{
	NSMutableArray* _controllerStack;
	BOOL _hasWillAppeared;
	BOOL _hasDidAppeared;
}


#pragma View structure and memory management

-(id) init
{
	@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `initWithRootViewController:` instead.", NSStringFromClass([self class])] userInfo:nil];
}

-(id) initWithRootViewController:(UIViewController *)rootViewController
{
	if (rootViewController == nil)
	{
		@throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Root view controller is nil!" userInfo:nil];
	}
	
	self = [super init];
	if (self)
	{
		_controllerStack = [[NSMutableArray alloc] initWithCapacity:0];
		[_controllerStack addObject:rootViewController];
	}
	return self;
}

-(UIViewController*) getRootViewController
{
	if (_controllerStack.count > 0)
		return [_controllerStack firstObject];
	
	return nil;
}

-(void) dealloc
{
	for (UIViewController* vc in _controllerStack)
		vc.cdNavigationController = nil;
}

- (void)loadView
{
	CGRect frame = [UIScreen mainScreen].applicationFrame;
    frame.size.height += iOS7 ? 20:0;
    frame.origin.y = 0;
	if ([self.currentController isKindOfClass:[CDViewController class]])
	{
		frame = ((CDViewController *)self.currentController).viewFrame;
	}
	self.view = [[UIView alloc] initWithFrame:frame];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	self.view.multipleTouchEnabled = YES;
	self.view.clipsToBounds = YES;
		
	UIViewController* cvc = self.currentController;
	cvc.view.frame = self.view.bounds;
	cvc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:cvc.view];
	cvc.cdNavigationController = self;
	
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
		[self setNeedsStatusBarAppearanceUpdate];
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!_hasWillAppeared)
	{
		_hasWillAppeared = YES;
		[self.currentController willPresentView:0.0];
	}
}

-(void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (!_hasDidAppeared)
	{
		_hasDidAppeared = YES;
		[self.currentController didPresentView];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return [self.currentController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self.currentController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.currentController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

-(BOOL) shouldAutorotate
{
	return [self.currentController shouldAutorotate];
}

-(NSUInteger) supportedInterfaceOrientations
{
	return [self.currentController supportedInterfaceOrientations];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}


#pragma Manage controllers

-(UIViewController*) currentController
{
	return _controllerStack.lastObject;
}

-(void) switchFromController:(UIViewController*)fromController
				   fromStyle:(AnimationOptions)fromStyle
				toController:(UIViewController*)toController
					 toStyle:(AnimationOptions)toStyle
				   isToAbove:(BOOL)isToAbove
					duration:(NSTimeInterval)duration
{
	[[NSNotificationCenter defaultCenter] postNotificationName:CDNavigationWillSwitchNotification object:nil];
		
	if (isToAbove)
		toController.cdNavigationController = self;
	
	UIView* fromView = fromController.view;
	UIView* toView = toController.view;
	UIView* containerView = self.view;
	
	fromView.userInteractionEnabled = NO;
	toView.userInteractionEnabled = YES;
	
	toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	
	CGRect rect = containerView.bounds;
	
	// Prepare for animation
	switch (toStyle & 0xff)
	{
		case ASNone:
		{
			toView.frame = rect;
			toView.alpha = 1.0f;
			break;
		}
		case ASFadeIn:
		{
			toView.frame = rect;
			toView.alpha = 0.0f;
			break;
		}
		case ASFadeOut:
		{
			toView.frame = rect;
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationToLeft:
		{
			toView.frame = CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationToRight:
		{
			toView.frame = CGRectMake(-rect.size.width, 0, rect.size.width, rect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationUp:
		{
			toView.frame = CGRectMake(0, rect.size.height, rect.size.width, rect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationDown:
		{
			toView.frame = CGRectMake(0, -rect.size.height, rect.size.width, rect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASFallBehind:
		{
			toView.frame = rect;
			toView.alpha = 1.0f;
			break;
		}
		case ASLiftForward:
		{
			toView.frame = rect;
			toView.alpha = 1.0f;
			break;
		}
	}
	
	if (toView != nil)
	{
		if (isToAbove)
			[containerView addSubview:toView];
		else
			[containerView insertSubview:toView atIndex:0];
	}
	
	[toController willPresentView:duration];
	[fromController willDismissView:duration];
	
	[UIView animateWithDuration:duration animations:^
	{
		switch (fromStyle & 0xff)
		{
			case ASNone:
			{
				[fromController doingDismissView];
				break;
			}
			case ASFadeIn:
			{
				fromView.alpha = 1.0f;
				break;
			}
			case ASFadeOut:
			{
				fromView.alpha = 0.0f;
				break;
			}
			case ASTranslationToLeft:
			{
				fromView.frame = CGRectMake(-rect.size.width, 0, rect.size.width, rect.size.height);;
				break;
			}
			case ASTranslationToRight:
			{
				fromView.frame = CGRectMake(rect.size.width, 0, rect.size.width, rect.size.height);
				break;
			}
			case ASTranslationUp:
			{
				fromView.frame = CGRectMake(0, -rect.size.height, rect.size.width, rect.size.height);
				break;
			}
			case ASTranslationDown:
			{
				fromView.frame = CGRectMake(0, rect.size.height, rect.size.width, rect.size.height);
				break;
			}
			case ASFallBehind:
			{
				fromView.frame = CGRectMake(0, -rect.size.height, rect.size.width, rect.size.height);
//				CATransform3D trans = CATransform3DMakeRotation(M_PI/4.0, 1.0f, 0, 0);
//				fromView.layer.transform = trans;
				break;
			}
			case ASLiftForward:
			{
				break;
			}
		}
		
		CGRect newRect = containerView.bounds;
		
		switch (toStyle & 0xff)
		{
			case ASNone:
			{
				[toController doingPresentView];
				break;
			}
			case ASFadeIn:
			{
				toView.alpha = 1.0f;
				break;
			}
			case ASFadeOut:
			{
				toView.alpha = 0.0f;
				break;
			}
			case ASTranslationToLeft:
			{
				toView.frame = newRect;
				break;
			}
			case ASTranslationToRight:
			{
				toView.frame = newRect;
				break;
			}
			case ASTranslationUp:
			{
				toView.frame = newRect;
				break;
			}
			case ASTranslationDown:
			{
				toView.frame = newRect;
				break;
			}
			case ASFallBehind:
			{
				break;
			}
			case ASLiftForward:
			{
				break;
			}
		}
	}
	completion:^(BOOL finished)
	{
		[fromController didDismissView];
		[toController didPresentView];
		if (!isToAbove)
			fromController.cdNavigationController = nil;
		[fromController.view removeFromSuperview];
	}];
}

#define DefaultAnimationDuration 0.35

-(void) pushViewController:(UIViewController*)controller
{
	[self pushViewController:controller inStyle:ASTranslationToLeft outStyle:ASTranslationToLeft duration:DefaultAnimationDuration];
}

-(void) pushViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle
{
	[self pushViewController:controller inStyle:inStyle outStyle:outStyle duration:DefaultAnimationDuration];
}

-(void) pushViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration
{
	if (controller == nil || [_controllerStack indexOfObjectIdenticalTo:controller] != NSNotFound)
	{
		LOG_debug(@"Pushed controller is nil, or in navigation stack already!");
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CDNavigationWillPushNotification object:nil];
	
	UIViewController* oldVC = _controllerStack.lastObject;
	if ((outStyle & 0xff00) == ASResultDelete)
		[_controllerStack removeLastObject];
	[_controllerStack addObject:controller];
	[self switchFromController:oldVC fromStyle:outStyle toController:controller toStyle:inStyle isToAbove:YES duration:duration];
}

-(void) popViewController
{
	[self popViewControllerWithInStyle:ASTranslationToRight outStyle:ASTranslationToRight duration:DefaultAnimationDuration];
}

-(void) popViewControllerWithInStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle
{
	[self popViewControllerWithInStyle:inStyle outStyle:outStyle duration:DefaultAnimationDuration];
}

-(void) popViewControllerWithInStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration
{
	if (_controllerStack.count < 2)
	{
		LOG_debug(@"Can not pop root view controller!");
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CDNavigationWillPopNotification object:nil];
	UIViewController* oldVC = [_controllerStack lastObject];
	[_controllerStack removeLastObject];
	UIViewController* newVC = [_controllerStack lastObject];
	[self switchFromController:oldVC fromStyle:outStyle toController:newVC toStyle:inStyle isToAbove:NO duration:duration];
//	UIViewController* controller = [_controllerStack objectAtIndex:_controllerStack.count - 2];
//	[self popToViewController:controller inStyle:inStyle outStyle:outStyle duration:duration];
}

-(void) popToViewController:(UIViewController *)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle
{
	[self popToViewController:controller inStyle:inStyle outStyle:outStyle duration:DefaultAnimationDuration];
}

-(void) popToViewController:(UIViewController *)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration
{
	if (_controllerStack.count < 2)
	{
		LOG_debug(@"Can not pop root view controller!");
		return;
	}
	
	NSInteger index = [_controllerStack indexOfObject:controller];
	if (index == NSNotFound)
	{
		LOG_debug(@"Can not pop view controller that's not pushed by this navigation controller!");
		return;
	}

	if (index == _controllerStack.count - 1)
	{
		LOG_debug(@"The controller is already on top!");
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CDNavigationWillPopNotification object:nil];
	
	for (int i = _controllerStack.count - 2; i > index; i--) {
		UIViewController* tmp = [_controllerStack objectAtIndex:i];
		[_controllerStack removeObject:tmp];
	}
	
	UIViewController* oldVC = [_controllerStack lastObject];
	[_controllerStack removeLastObject];
	UIViewController* newVC = [_controllerStack lastObject];
	[self switchFromController:oldVC fromStyle:outStyle toController:newVC toStyle:inStyle isToAbove:NO duration:duration];
}

-(void) setRootViewController:(UIViewController*)controller
{
	[self setRootViewController:controller inStyle:ASTranslationToLeft outStyle:ASTranslationToLeft];
}

-(void) setRootViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle
{
	[self setRootViewController:controller inStyle:inStyle outStyle:outStyle duration:DefaultAnimationDuration];
}

-(void) setRootViewController:(UIViewController*)controller inStyle:(AnimationOptions)inStyle outStyle:(AnimationOptions)outStyle duration:(NSTimeInterval)duration
{
	if (controller == nil || [_controllerStack indexOfObjectIdenticalTo:controller] != NSNotFound)
	{
		LOG_debug(@"New controller is nil, or in navigation stack already!");
		return;
	}
	
	UIViewController* oldVC = _controllerStack.lastObject;
	[_controllerStack removeAllObjects];
	[_controllerStack addObject:controller];
	[self switchFromController:oldVC fromStyle:outStyle toController:controller toStyle:inStyle isToAbove:YES duration:duration];
}

@end




static char kCDNavigationControllerKey;

@implementation UIViewController (CDNavigationController)

-(CDNavigationController*) cdNavigationController
{
	return objc_getAssociatedObject(self, &kCDNavigationControllerKey);
}

-(void) setCdNavigationController:(CDNavigationController *)cdNavigationController
{
	objc_setAssociatedObject(self, &kCDNavigationControllerKey, cdNavigationController, OBJC_ASSOCIATION_ASSIGN);
}

-(void) willPresentView:(NSTimeInterval)duration
{
}

-(void) willDismissView:(NSTimeInterval)duration
{
}

-(void) didPresentView
{
}

-(void) didDismissView
{
}

-(void) doingPresentView
{
}

-(void) doingDismissView
{
}

@end


