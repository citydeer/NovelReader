//
//  CDPageViewController.h
//  RefactorTest
//
//  Created by Pang Zhenyu on 14-9-29.
//
//

#import "CDViewController.h"



//
//@interface CDPageViewController : CDViewController
//
//-(instancetype) initWithLoop:(BOOL)loop;
//
//@property (readonly) UIScrollView* scrollView;
//@property (readonly) UIViewController* currentController;
//@property (nonatomic, copy) NSArray* viewControllers;
//
//// For override, datasource and delegate
//-(void) _onProgressChanged:(double)progress firstIndex:(NSInteger)firstIndex secondIndex:(NSInteger)secondIndex;
//-(void) didShowController:(UIViewController*)controller atIndex:(NSUInteger)index previousController:(UIViewController*)pController;
//
//@end



@interface CDPageViewController : CDViewController
{
@protected
	UIView* _containerView;
}

@property (readonly) UIViewController* currentController;

-(void) setCurrentController:(UIViewController *)currentController animate:(BOOL)animate isForward:(BOOL)forward;

// For override
-(UIViewController*) _previousController:(UIViewController*)controller;
-(UIViewController*) _nextController:(UIViewController*)controller;
-(void) _progressChanged:(double)progress incoming:(UIViewController*)incomingVC outgoing:(UIViewController*)outgoingVC;

@end

