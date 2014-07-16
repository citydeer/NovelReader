//
//  GetterController.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-21.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "Getter.h"



typedef enum
{
	DataStatusUnInit = 0,
	DataStatusLoadedFromCache,
	DataStatusLoadingAnimated,
	DataStatusLoadingBackground,
	DataStatusLoadingFromCache,
	DataStatusLoadingMore,
	DataStatusLoadedHasMore,
	DataStatusLoadedNoMore,
	DataStatusShouldLoadMore,
	DataStatusShouldLoadRefresh,
	DataStatusShouldRefresImmediately,
	DataStatusRefreshNoMore,
	DataStatusViewUnloaded,
	DataStatusLoadedError,
}
DataStatus;



@protocol GetterControllerOwner <NSObject>

-(void) handleGetter:(id<Getter>)getter;

@end


@interface GetterController : NSObject <GetterDelegate>
{
	NSMutableSet* _fetchingGetters;		// Instances of Getter which is fetching
	NSMutableArray* _getterQueue;		// Instances of Getter which is in queue
	BOOL _isQueueBusy;
	
	DataStatus _dataStatus;
	DataStatus _hasMoreStatus;
	BOOL _viewHasAppeared;
	NSInteger _currentPage;
	id<NSObject> _lastUpdateTime;
}

@property (nonatomic, weak)		id<GetterControllerOwner> owner;
@property (nonatomic, assign) DataStatus dataStatus;
@property (nonatomic, assign) DataStatus hasMoreStatus;
@property (nonatomic, assign) BOOL viewHasAppeared;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, retain) id<NSObject> lastUpdateTime;		// NSDate or NSString
@property (readonly) NSArray* runningGetters;

-(id) initWithOwner:(id)owner;
-(void) launchGetter:(id<Getter>)getter;
-(void) enqueueGetter:(id<Getter>)getter;
-(void) checkQueue;
-(void) cancelAllGetters;

@end

