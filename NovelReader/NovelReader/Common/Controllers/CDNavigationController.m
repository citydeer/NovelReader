//
//  CDNavigationController.m
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-15.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "CDNavigationController.h"
#import <objc/runtime.h>



NSString* const CDNavigationWillPushNotification = @"CDNavigationWillPushNotification";
NSString* const CDNavigationWillPopNotification = @"CDNavigationWillPopNotification";
NSString* const CDNavigationWillSwitchNotification = @"CDNavigationWillSwitchNotification";

CDNavigationController* getNaviController(void)
{
	UIViewController* rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
	if ([rootVC isKindOfClass:[CDNavigationController class]])
		return (CDNavigationController *)rootVC;
	return nil;
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

-(void) screenEdgePanAction:(UIScreenEdgePanGestureRecognizer*)segtr;

@end



@implementation CDNavigationController
{
	NSMutableArray* _controllerStack;
	BOOL _hasWillAppeared;
	BOOL _hasDidAppeared;
	UIViewController* _panningController;
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
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	self.view.multipleTouchEnabled = YES;
	
	UIViewController* cvc = self.currentController;
	CGRect rect = self.view.bounds;
	if (!cvc.wantsFullScreenLayout)
	{
		CGFloat barHeight = iOS7 ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
		rect.origin.y += barHeight;
		rect.size.height -= barHeight;
	}
	cvc.view.frame = rect;
	cvc.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:cvc.view];
	cvc.cdNavigationController = self;
	
	if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
		[self setNeedsStatusBarAppearanceUpdate];
	
	UIScreenEdgePanGestureRecognizer* sgtr = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(screenEdgePanAction:)];
	sgtr.edges = UIRectEdgeLeft;
	[self.view addGestureRecognizer:sgtr];
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

#define CDNaturalStyleRate 0.3

-(void) screenEdgePanAction:(UIScreenEdgePanGestureRecognizer*)segtr
{
	if (segtr.state == UIGestureRecognizerStateBegan && _panningController == nil && _controllerStack.count >= 2 && self.currentController.shouldPopoutOnSwipe)
	{
		_panningController = _controllerStack[_controllerStack.count-2];
		CGRect oldFrame = self.view.bounds;
		if (!_panningController.wantsFullScreenLayout)
		{
			CGFloat barHeight = iOS7 ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
			oldFrame.origin.y += barHeight;
			oldFrame.size.height -= barHeight;
		}
		_panningController.view.frame = oldFrame;
		[self.view insertSubview:_panningController.view atIndex:0];
		
		_panningController.view.userInteractionEnabled = NO;
		UIViewController* currentVC = _controllerStack.lastObject;
		currentVC.view.userInteractionEnabled = NO;
		currentVC.view.layer.shadowOffset = CGSizeMake(-6, 0);
		currentVC.view.layer.shadowRadius = 6;
		currentVC.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:currentVC.view.bounds].CGPath;
	}
	
	if (_panningController == nil)
		return;
	
	UIViewController* currentVC = _controllerStack.lastObject;
	CGRect rect = self.view.bounds;
	CGRect currentVCFrame = currentVC.view.frame;
	CGRect previousVCFrame = _panningController.view.frame;
	CGPoint translation = [segtr translationInView:self.view];
	CGPoint velocity = [segtr velocityInView:self.view];
	double progress = translation.x / rect.size.width;
	if (progress > 1.0) progress = 1.0;
	if (progress < 0.0) progress = 0.0;
	currentVCFrame.origin.x = rect.size.width * progress;
	previousVCFrame.origin.x = -rect.size.width*CDNaturalStyleRate*(1.0-progress);
	currentVC.view.frame = currentVCFrame;
	_panningController.view.frame = previousVCFrame;
	currentVC.view.layer.shadowOpacity = 0.3*(1.0-progress);
	
	if (segtr.state == UIGestureRecognizerStateEnded || segtr.state == UIGestureRecognizerStateCancelled)
	{
		double speed = (progress - 0.5) * 640 + velocity.x;
		double duration = 0.18;
		if (speed > 0.0)
		{
			[_controllerStack removeLastObject];
			[_panningController willPresentView:duration];
			[currentVC willDismissView:duration];
			[UIView animateWithDuration:duration animations:^
			{
				currentVC.view.frame = CGRectMake(rect.size.width, currentVCFrame.origin.y, currentVCFrame.size.width, currentVCFrame.size.height);
				currentVC.view.layer.shadowOpacity = 0;
				_panningController.view.frame = CGRectMake(0, previousVCFrame.origin.y, previousVCFrame.size.width, previousVCFrame.size.height);
			}
			completion:^(BOOL finished)
			{
				[currentVC didDismissView];
				[_panningController didPresentView];
				currentVC.view.layer.shadowOpacity = 0;
				[currentVC.view removeFromSuperview];
				_panningController.view.userInteractionEnabled = YES;
				_panningController = nil;
			}];
		}
		else
		{
			[UIView animateWithDuration:duration animations:^
			{
				currentVC.view.frame = CGRectMake(0, currentVCFrame.origin.y, currentVCFrame.size.width, currentVCFrame.size.height);
				currentVC.view.layer.shadowOpacity = 0.3;
				_panningController.view.frame = CGRectMake(-rect.size.width*CDNaturalStyleRate, previousVCFrame.origin.y, previousVCFrame.size.width, previousVCFrame.size.height);
			}
			completion:^(BOOL finished)
			{
				currentVC.view.userInteractionEnabled = YES;
				currentVC.view.layer.shadowOpacity = 0;
				[_panningController.view removeFromSuperview];
				_panningController = nil;
			}];
		}
	}
}

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
	CGRect toRect = rect;
	CGRect fromRect = fromView.frame;
	if (!toController.wantsFullScreenLayout)
	{
		CGFloat barHeight = iOS7 ? 0 : [UIApplication sharedApplication].statusBarFrame.size.height;
		toRect.origin.y += barHeight;
		toRect.size.height -= barHeight;
	}
	
	// Prepare for animation
	switch (toStyle & 0xff)
	{
		case ASNone:
		{
			toView.frame = toRect;
			toView.alpha = 1.0f;
			break;
		}
		case ASFadeIn:
		{
			toView.frame = toRect;
			toView.alpha = 0.0f;
			break;
		}
		case ASFadeOut:
		{
			toView.frame = toRect;
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationToLeft:
		{
			toView.frame = CGRectMake(rect.size.width, toRect.origin.y, toRect.size.width, toRect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationToRight:
		{
			toView.frame = CGRectMake(-rect.size.width, toRect.origin.y, toRect.size.width, toRect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationUp:
		{
			toView.frame = CGRectMake(toRect.origin.x, rect.size.height, toRect.size.width, toRect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASTranslationDown:
		{
			toView.frame = CGRectMake(toRect.origin.x, -toRect.size.height, toRect.size.width, toRect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASFallBehind:
		{
			toView.frame = toRect;
			toView.alpha = 1.0f;
			break;
		}
		case ASLiftForward:
		{
			toView.frame = toRect;
			toView.alpha = 1.0f;
			break;
		}
		case ASNatureIn:
		{
			toView.frame = CGRectMake(rect.size.width, toRect.origin.y, toRect.size.width, toRect.size.height);
			toView.alpha = 1.0f;
			break;
		}
		case ASNatureOut:
		{
			toView.frame = CGRectMake(-rect.size.width*CDNaturalStyleRate, toRect.origin.y, toRect.size.width, toRect.size.height);
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
				fromView.frame = CGRectMake(-fromRect.size.width, fromRect.origin.y, fromRect.size.width, fromRect.size.height);;
				break;
			}
			case ASTranslationToRight:
			{
				fromView.frame = CGRectMake(rect.size.width, fromRect.origin.y, fromRect.size.width, fromRect.size.height);
				break;
			}
			case ASTranslationUp:
			{
				fromView.frame = CGRectMake(fromRect.origin.x, -fromRect.size.height, fromRect.size.width, fromRect.size.height);
				break;
			}
			case ASTranslationDown:
			{
				fromView.frame = CGRectMake(fromRect.origin.x, rect.size.height, fromRect.size.width, fromRect.size.height);
				break;
			}
			case ASFallBehind:
			{
				fromView.frame = CGRectMake(fromRect.origin.x, -fromRect.size.height, fromRect.size.width, fromRect.size.height);
//				CATransform3D trans = CATransform3DMakeRotation(M_PI/4.0, 1.0f, 0, 0);
//				fromView.layer.transform = trans;
				break;
			}
			case ASLiftForward:
			{
				break;
			}
			case ASNatureIn:
			{
				fromView.frame = CGRectMake(-fromRect.size.width*CDNaturalStyleRate, fromRect.origin.y, fromRect.size.width, fromRect.size.height);;
				break;
			}
			case ASNatureOut:
			{
				fromView.frame = CGRectMake(rect.size.width, fromRect.origin.y, fromRect.size.width, fromRect.size.height);
				break;
			}
		}
		
		CGRect newRect = toRect;
		
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
			case ASNatureIn:
			{
				toView.frame = newRect;
				break;
			}
			case ASNatureOut:
			{
				toView.frame = newRect;
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
	[self pushViewController:controller inStyle:ASNatureIn outStyle:ASNatureIn duration:DefaultAnimationDuration];
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
	[self popViewControllerWithInStyle:ASNatureOut outStyle:ASNatureOut duration:DefaultAnimationDuration];
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
}

-(void) popToRootViewController
{
	[self popToViewController:_controllerStack.firstObject inStyle:ASNatureOut outStyle:ASNatureOut duration:DefaultAnimationDuration];
}

-(void) popToViewController:(UIViewController *)controller
{
	[self popToViewController:controller inStyle:ASNatureOut outStyle:ASNatureOut duration:DefaultAnimationDuration];
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
	
	for (NSInteger i = _controllerStack.count - 2; i > index; i--) {
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
	[self setRootViewController:controller inStyle:ASNatureIn outStyle:ASNatureIn duration:DefaultAnimationDuration];
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

-(void) setViewController:(UIViewController*)controller afterController:(UIViewController*)foreController
{
	if (controller == nil || [_controllerStack indexOfObjectIdenticalTo:controller] != NSNotFound)
	{
		LOG_debug(@"Pushed controller is nil, or in navigation stack already!");
		return;
	}
	
	NSUInteger index = [_controllerStack indexOfObject:foreController];
	if (index == NSNotFound || index == _controllerStack.count - 1)
	{
		[self pushViewController:controller];
		return;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:CDNavigationWillPopNotification object:nil];
	
	for (NSInteger i = _controllerStack.count - 2; i > index; i--)
		[_controllerStack removeObjectAtIndex:i];
	
	UIViewController* oldVC = [_controllerStack lastObject];
	[_controllerStack removeLastObject];
	[_controllerStack addObject:controller];
	[self switchFromController:oldVC fromStyle:ASNatureIn toController:controller toStyle:ASNatureIn isToAbove:YES duration:DefaultAnimationDuration];
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

-(BOOL) shouldPopoutOnSwipe
{
	return YES;
}

@end


