//
//  CDPageViewController.m
//  RefactorTest
//
//  Created by Pang Zhenyu on 14-9-29.
//
//

#import "CDPageViewController.h"
#import "RSTimingFunction.h"



//@interface CDPageViewController () <UIScrollViewDelegate>
//{
//	BOOL _loop;
//	UIView* _containerView;
//	CGSize _oldSize;
//	
//	NSMutableArray* _visibleControllers;
//	
//	NSInteger _currentIndex;
//	NSInteger _totalPageCount;
//	NSInteger _indexBase;
//}
//
//-(void) adjustScrollViewSize;
//-(void) scrolling:(BOOL)callControllerAction;
//-(void) chooseController:(BOOL)callControllerAction;
//-(void) checkSize;
//-(void) centerLoopView;
//
//-(NSInteger) mapToRealIndex:(NSInteger)index;
//
//@end
//
//
//
//@interface CDPageLayoutSubview : UIView
//
//@property (nonatomic, weak) id owner;
//
//@end
//
//
//
//
//@implementation CDPageViewController
//
//-(instancetype) initWithLoop:(BOOL)loop
//{
//	self = [super init];
//	if (self)
//	{
//		_loop = loop;
//		_naviBarHeight = 0.0f;
//		_visibleControllers = [[NSMutableArray alloc] initWithCapacity:3];
//		_totalPageCount = 101;
//		_indexBase = 50;
//	}
//	return self;
//}
//
//-(void) dealloc
//{
//}
//
//-(void) loadView
//{
//	[super loadView];
//	
//	_containerView = [[CDPageLayoutSubview alloc] initWithFrame:self.view.bounds];
//	_containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//	[self.view insertSubview:_containerView atIndex:0];
//	
//	_scrollView = [[UIScrollView alloc] initWithFrame:_containerView.bounds];
//	_scrollView.pagingEnabled = YES;
//	_scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//	_scrollView.showsHorizontalScrollIndicator = NO;
//	_scrollView.showsVerticalScrollIndicator = NO;
//	_scrollView.directionalLockEnabled = YES;
//	_scrollView.alwaysBounceHorizontal = YES;
//	_scrollView.bounces = YES;
//	_scrollView.delegate = self;
//	_scrollView.scrollsToTop = NO;
//	[_containerView addSubview:_scrollView];
//}
//
//-(void) willPresentView:(NSTimeInterval)duration
//{
//	[super willPresentView:duration];
//	[_currentController willPresentView:duration];
//}
//
//-(void) willDismissView:(NSTimeInterval)duration
//{
//	[super willDismissView:duration];
//	[_currentController willDismissView:duration];
//}
//
//-(void) didPresentView
//{
//	[super didPresentView];
//	[_currentController didPresentView];
//}
//
//-(void) didDismissView
//{
//	[super didDismissView];
//	[_currentController didDismissView];
//}
//
//-(void) doingPresentView
//{
//	[super doingPresentView];
//	[_currentController doingPresentView];
//}
//
//-(void) doingDismissView
//{
//	[super doingDismissView];
//	[_currentController doingDismissView];
//}
//
//-(void) setViewControllers:(NSArray *)viewControllers
//{
//	if (![_viewControllers isEqualToArray:viewControllers])
//	{
//		_viewControllers = [viewControllers copy];
//		_currentIndex = -1;
//		_currentController = nil;
//		
//		if ([self isViewLoaded])
//		{
//			[self adjustScrollViewSize];
//			[self scrolling:YES];
//			[self chooseController:YES];
//		}
//	}
//}
//
//-(NSInteger) mapToRealIndex:(NSInteger)index
//{
//	if (_loop)
//	{
//		if (index < 0 || index >= _totalPageCount)
//			return -1;
//		NSInteger count = _viewControllers.count;
//		if (count <= 0)
//			return -1;
//		if (_currentIndex < 0)
//			return -1;
//		return (_currentIndex + index - _indexBase) % count;
//	}
//	else
//	{
//		if (index < 0 || index >= _viewControllers.count)
//			return -1;
//		return index;
//	}
//}
//
//-(void) checkSize
//{
//	CGSize newSize = _scrollView.bounds.size;
//	if (!CGSizeEqualToSize(_oldSize, newSize))
//	{
//		_oldSize = newSize;
//		[_visibleControllers removeAllObjects];
//		[self adjustScrollViewSize];
//		[self scrolling:NO];
//		[self chooseController:NO];
//	}
//}
//
//-(void) adjustScrollViewSize
//{
//	CGRect rect = _scrollView.bounds;
//	if (_loop && _viewControllers.count > 0)
//	{
//		_scrollView.contentSize = CGSizeMake(_totalPageCount * rect.size.width, rect.size.height);
//	}
//	else
//	{
//		_scrollView.contentSize = CGSizeMake(_viewControllers.count * rect.size.width, rect.size.height);
//	}
//	
//	if (_currentIndex < _viewControllers.count && _currentIndex >= 0)
//	{
//		if (_loop)
//		{
//			rect.origin.x = rect.size.width * _indexBase;
//		}
//		else
//		{
//			rect.origin.x = rect.size.width * _currentIndex;
//		}
//		[_scrollView scrollRectToVisible:rect animated:NO];
//	}
//}
//
//-(void) scrolling:(BOOL)callControllerAction
//{
//	if (self.viewControllers.count <= 0)
//		return;
//	
//	CGRect visibleBounds = _scrollView.bounds;
//	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
//	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
//	int realFirst = [self mapToRealIndex:firstNeededPageIndex];
//	int realLast = [self mapToRealIndex:lastNeededPageIndex];
//	
//	// Remove invisible controllers
//	for (NSUInteger i = _visibleControllers.count-1; i != 0; i--)
//	{
//		UIViewController* controller = _visibleControllers[i];
//		NSUInteger index = [_viewControllers indexOfObjectIdenticalTo:controller];
//		BOOL indexVisible = NO;
//		if (realFirst <= realLast && index >= realFirst && index <= realLast)
//			indexVisible = YES;
//		if (realFirst > realLast && (index >= realFirst || index <= realLast))
//			indexVisible = YES;
//		if (index == NSNotFound || indexVisible)
//		{
//			[controller.view removeFromSuperview];
//			if (callControllerAction)
//				[controller didDismissView];
//			[_visibleControllers removeObjectAtIndex:i];
//		}
//	}
//	
//	// Add missing controllers
//	for (NSInteger i = firstNeededPageIndex; i <= lastNeededPageIndex; ++i)
//	{
//		NSInteger realIndex = [self mapToRealIndex:i];
//		if (realIndex < 0)
//			continue;
//		
//		UIViewController* controller = [_viewControllers objectAtIndex:realIndex];
//		if ([_visibleControllers indexOfObjectIdenticalTo:controller] == NSNotFound)
//		{
//			CGRect rect = visibleBounds;
//			rect.origin.x = visibleBounds.size.width * i;
//			controller.view.frame = rect;
//			[_scrollView addSubview:controller.view];
//			controller.view.frame = rect;
//			[_visibleControllers addObject:controller];
//			
//			if (callControllerAction)
//				[controller willPresentView:0];
//		}
//	}
//}
//
//-(void) chooseController:(BOOL)callControllerAction
//{
//	if (_viewControllers.count <= 0)
//	{
//		_currentIndex = -1;
//		_currentController = nil;
//	}
//	else
//	{
//		CGRect visibleBounds = _scrollView.bounds;
//		int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
//		int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
//		if (_loop)
//		{
//			int realIndex = [self mapToRealIndex:(firstNeededPageIndex + lastNeededPageIndex) / 2];
//			if (realIndex != _currentIndex)
//			{
//				_currentIndex = realIndex;
//				if (_currentIndex < 0) _currentIndex = 0;
//				UIViewController* cvc = _viewControllers[_currentIndex];
//				visibleBounds.origin.x = _indexBase * visibleBounds.size.width;
//				cvc.view.frame = visibleBounds;
//				_scrollView.contentOffset = CGPointMake(_indexBase * visibleBounds.size.width, 0);
//			}
//		}
//		else
//		{
//			firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
//			lastNeededPageIndex  = MIN(lastNeededPageIndex, self.viewControllers.count - 1);
//			_currentIndex = (firstNeededPageIndex + lastNeededPageIndex) / 2;
//		}
//		
//		UIViewController* newController = [_viewControllers objectAtIndex:_currentIndex];
//		if (newController != _currentController)
//		{
//			UIViewController* old = _currentController;
//			_currentController = newController;
//			[self didShowController:newController atIndex:_currentIndex previousController:old];
//			if (callControllerAction)
//				[newController didPresentView];
//		}
//	}
//}
//
//-(void) centerLoopView
//{
//}
//
//
//#pragma UIScrollViewDelegate
//
//-(void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//	[self scrolling:YES];
//}
//
//-(void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//	if (!decelerate)
//	{
//		[self chooseController:YES];
//	}
//}
//
//-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//	[self chooseController:YES];
//}
//
//-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
//{
//	[self chooseController:YES];
//}
//
//@end
//
//
//
//
//@implementation CDPageLayoutSubview
//
//-(void) layoutSubviews
//{
//	[super layoutSubviews];
//	[_owner checkSize];
//}
//
//@end



@interface CDPageViewController ()
{
	UIViewController* _incomingController;
	UIViewController* _outgoingController;
	
	CADisplayLink* _displayLink;
	CFTimeInterval _firstTimeStamp;
	double _duration;
	CGFloat _startX;
	CGFloat _endX;
	RSTimingFunction* _timingFunc;
	
	BOOL _panning;
	CGFloat _lastTransitionX;
	CGFloat _startPanningX;
}

-(void) onPanGesture:(UIPanGestureRecognizer*)pan;
-(void) animationUpdate:(CADisplayLink*)displayLink;

@end




@implementation CDPageViewController

#define CDAnimationDuration 0.35

-(instancetype) init
{
	self = [super init];
	if (self)
	{
		_naviBarHeight = 0.0f;
		_timingFunc = [[RSTimingFunction alloc] initWithName:kRSTimingFunctionDefault];
	}
	return self;
}

-(void) dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	_containerView = [[UIView alloc] initWithFrame:self.view.bounds];
	_containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view insertSubview:_containerView atIndex:0];
	
	if (_currentController != nil)
	{
		CGRect rect = _containerView.bounds;
		_currentController.view.frame = rect;
		_currentController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[_containerView addSubview:_currentController.view];
	}
	
	[_containerView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGesture:)]];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	[_currentController willPresentView:duration];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	[_currentController willDismissView:duration];
}

-(void) didPresentView
{
	[super didPresentView];
	[_currentController didPresentView];
}

-(void) didDismissView
{
	[super didDismissView];
	[_currentController didDismissView];
}

-(void) doingPresentView
{
	[super doingPresentView];
	[_currentController doingPresentView];
}

-(void) doingDismissView
{
	[super doingDismissView];
	[_currentController doingDismissView];
}

-(void) setCurrentController:(UIViewController *)currentController animate:(BOOL)animate isForward:(BOOL)forward
{
	if (_displayLink != nil || _panning)
		return;
	
	if (currentController == _currentController)
		return;
	
	if (!self.isViewLoaded)
	{
		_currentController = currentController;
		return;
	}
	
	if (currentController == nil)
		return;
	
	UIViewController* oldVC = _currentController;
	_currentController = currentController;
	CGRect rect = _containerView.bounds;
	_currentController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	if (!animate)
	{
		_currentController.view.frame = rect;
		[_containerView addSubview:_currentController.view];
		[oldVC.view removeFromSuperview];
		
		[_currentController willPresentView:0];
		[oldVC willDismissView:0];
		[oldVC didDismissView];
		[_currentController didPresentView];
		return;
	}
	
	if (_displayLink != nil)
		[_displayLink invalidate];
	
	_currentController.view.frame = CGRectMake((forward ? rect.size.width : -rect.size.width), 0, rect.size.width, rect.size.height);
	[_containerView addSubview:_currentController.view];
	
	[_currentController willPresentView:CDAnimationDuration];
	[oldVC willDismissView:CDAnimationDuration];
	
	_incomingController = _currentController;
	_outgoingController = oldVC;
	
	_firstTimeStamp = -1.0;
	_duration = CDAnimationDuration;
	_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationUpdate:)];
	[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void) onPanGesture:(UIPanGestureRecognizer*)pan
{
	if (pan.state == UIGestureRecognizerStateBegan && !_panning && _currentController != nil)
	{
		_panning = YES;
		_startPanningX = _currentController.view.frame.origin.x;
		
		if (_displayLink != nil)
		{
			[_displayLink invalidate];
			_displayLink = nil;
		}
		
		if (_outgoingController != nil)
		{
			_incomingController = _outgoingController;
			_outgoingController = nil;
		}
	}
	
	if (!_panning)
		return;
	
	CGPoint translation = [pan translationInView:_containerView];
	translation.x += _startPanningX;
	CGPoint velocity = [pan velocityInView:_containerView];
	
	UIViewController* showingVC = _incomingController;
	if (translation.x > 0.0f && _lastTransitionX <= 0.0f)
		showingVC = [self _previousController:_currentController];
	else if (translation.x < 0.0f && _lastTransitionX >= 0.0f)
		showingVC = [self _nextController:_currentController];
	_lastTransitionX = translation.x;
	
	if (showingVC != _incomingController)
	{
		if (_incomingController != nil)
		{
			[_incomingController didDismissView];
			[_incomingController.view removeFromSuperview];
		}
		_incomingController = showingVC;
		if (_incomingController != nil)
		{
			_incomingController.view.frame = _containerView.bounds;
			_incomingController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			[_containerView addSubview:_incomingController.view];
			[_incomingController willPresentView:0];
		}
	}
	
	CGRect rect = _containerView.bounds;
	CGRect currentVCFrame = _currentController.view.frame;
	currentVCFrame.origin.x = translation.x;
	_currentController.view.frame = currentVCFrame;
	if (_incomingController != nil)
	{
		CGRect incomingFrame = _incomingController.view.frame;
		if (translation.x > 0.0)
			incomingFrame.origin.x = -rect.size.width + translation.x;
		else
			incomingFrame.origin.x = rect.size.width + translation.x;
		_incomingController.view.frame = incomingFrame;
	}
	
	double progress = fabsf(translation.x / rect.size.width);
	if (progress > 1.0) progress = 1.0;
	[self _progressChanged:progress incoming:_incomingController outgoing:_currentController];
	
	if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled)
	{
		BOOL rollBack = NO;
		if (translation.x > 0.0)
		{
			double speed = (progress - 0.5) * 640 + velocity.x;
			rollBack = (speed <= 0.0);
		}
		else
		{
			double speed = (0.5 - progress) * 640 + velocity.x;
			rollBack = (speed >= 0.0);
		}
		if (_incomingController == nil)
			rollBack = YES;
		
		if (rollBack)
		{
			_outgoingController = _incomingController;
			_incomingController = _currentController;
		}
		else
		{
			_outgoingController = _currentController;
			_currentController = _incomingController;
			_lastTransitionX = _currentController.view.frame.origin.x;
		}
		
		if (_displayLink != nil)
			[_displayLink invalidate];
		
		[_outgoingController willDismissView:0];
		
		_firstTimeStamp = -1.0;
		double maxDuration = (1-progress) * 0.35;
		_duration = maxDuration;
		if (_duration < 0.2) _duration = 0.2;
		_displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(animationUpdate:)];
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		_panning = NO;
	}
}

-(void) animationUpdate:(CADisplayLink*)displayLink
{
	if (_firstTimeStamp <= 0.0)
	{
		_firstTimeStamp = displayLink.timestamp;
		_startX = _incomingController.view.frame.origin.x;
		_endX = 0.0f;
		if (_duration <= 0.0) _duration = 0.01;
		return;
	}
	
	double dt = (displayLink.timestamp - _firstTimeStamp) / _duration;
	if (dt <= 0.0) dt = 0.0;
	else if (dt >= 1.0) dt = 1.0;
	else dt = [_timingFunc valueForX:dt];
	
	CGFloat originX = _startX * (1.0 - dt) + _endX * dt;
	CGRect incomingRect = _incomingController.view.frame;
	CGFloat dx = originX - incomingRect.origin.x;
	incomingRect.origin.x = originX;
	_incomingController.view.frame = incomingRect;
	if (_outgoingController != nil)
	{
		CGRect outgoingRect = _outgoingController.view.frame;
		outgoingRect.origin.x += dx;
		_outgoingController.view.frame = outgoingRect;
	}
	
	[self _progressChanged:dt incoming:_incomingController outgoing:_outgoingController];
	
	if (dt >= 1.0)
	{
		_lastTransitionX = 0.0f;
		[_outgoingController didDismissView];
		[_incomingController didPresentView];
		[_outgoingController.view removeFromSuperview];
		_outgoingController = nil;
		_incomingController = nil;
		[_displayLink invalidate];
		_displayLink = nil;
	}
}

-(UIViewController*) _previousController:(UIViewController*)controller
{
	return nil;
}

-(UIViewController*) _nextController:(UIViewController*)controller
{
	return nil;
}

-(void) _progressChanged:(double)progress incoming:(UIViewController*)incomingVC outgoing:(UIViewController*)outgoingVC
{
}

@end



