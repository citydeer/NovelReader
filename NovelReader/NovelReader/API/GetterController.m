//
//  GetterController.m
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-21.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "GetterController.h"



@implementation GetterController

@synthesize dataStatus = _dataStatus, hasMoreStatus = _hasMoreStatus, viewHasAppeared = _viewHasAppeared, lastUpdateTime = _lastUpdateTime;
@synthesize currentPage = _currentPage;

-(id) initWithOwner:(id)owner
{
	self = [super init];
	if (self)
	{
		_owner = owner;
		_fetchingGetters = [[NSMutableSet alloc] initWithCapacity:0];
		_getterQueue = [[NSMutableArray alloc] initWithCapacity:0];
		_hasMoreStatus = DataStatusLoadedNoMore;
	}
	return self;
}

-(void) dealloc
{
	self.owner = nil;
	for (id<Getter> getter in _fetchingGetters)
	{
		if (getter.delegate == self)
		{
			getter.delegate = nil;
			[getter stopFetching];
		}
	}
}

-(void) launchGetter:(id<Getter>)getter
{
	if (getter == nil || getter.isFetching)
		return;
	
	getter.delegate = self;
	[_fetchingGetters addObject:getter];
	[getter fetch];
}

-(void) enqueueGetter:(id<Getter>)getter
{
	if (![_getterQueue containsObject:getter])
	{
		[_getterQueue insertObject:getter atIndex:0];
		[self checkQueue];
	}
}

-(void) checkQueue
{
	if (!_isQueueBusy)
	{
		id<Getter> getter = [_getterQueue lastObject];
		if (getter != nil && !getter.isFetching)
		{
			_isQueueBusy = YES;
			[self launchGetter:getter];
		}
	}
}

-(NSArray*) runningGetters
{
	return [_fetchingGetters allObjects];
}

-(void) cancelAllGetters
{
	for (id<Getter> getter in _fetchingGetters)
	{
		if (getter.delegate == self)
		{
			getter.delegate = nil;
			[getter stopFetching];
		}
	}
	[_fetchingGetters removeAllObjects];
	[_getterQueue removeAllObjects];
}

-(void) didFinishFetch:(id<Getter>)getter
{
	if ([_fetchingGetters containsObject:getter])
	{
		[_fetchingGetters removeObject:getter];
		
#ifdef __KUYUN_TEST__
		if (getter.resultCode != KYResultCodeSuccess && getter.resultCode != KYResultCodeCanceled && getter.resultCode != KYResultCodeCacheNotFound)
		{
//			NSString* className = [[getter class] description];
//			if (![className isEqualToString:@"KYAPIImageGetter"])
//			{
//				NSString* msg = [NSString stringWithFormat:@"%@ API错误\n%@", className, KYLocalizedResultString(getter.resultCode)];
//				KYAlertView* av = [[KYAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//				[av show];
//				[av release];
//			}
		}
#endif
		
		if ([_getterQueue containsObject:getter])
		{
			[_getterQueue removeObject:getter];
			_isQueueBusy = NO;
			[self checkQueue];
		}
		
		[_owner handleGetter:getter];
	}
}

@end
