//
//  Getter.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-21.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//



@protocol Getter;

@protocol GetterDelegate <NSObject>

@required
-(void) didFinishFetch:(id<Getter>)getter;

@end



typedef enum
{
	KYResultCodeSuccess = -200,
	KYResultCodeUnknown,
	KYResultCodeTimeout,
	KYResultCodeNetworkError,
	KYResultCodeParseError,
	KYResultCodeInvalidRequest,
	KYResultCodeCanceled,
	KYResultCodeCacheNotFound,
	KYResultCodeUnInit = 0,
}
KYResultCode;


#define KYLocalizedResultString(resultCode) \
[[NSBundle mainBundle] localizedStringForKey:[NSString stringWithFormat:@"%d", (resultCode)] \
value:[NSString stringWithFormat:@"错误代码:%d", (resultCode)] table:nil]


typedef enum
{
	KYHttpCachePolicyIgnoreCache = 0,
	KYHttpCachePolicyOnlyCache,
	KYHttpCachePolicyUseIfAvailable,
}
KYHttpCachePolicy;



@protocol Getter <NSObject>

@required

@property (weak) id<GetterDelegate> delegate;
@property (readonly) BOOL isFetching;
@property (assign) KYHttpCachePolicy cachePolicy;
@property (readonly) NSInteger resultCode;
@property (readonly) NSString* resultMessage;
@property (assign) NSInteger tag;

-(void) fetch;
-(void) stopFetching;
-(BOOL) loadCache;

@optional
@property (retain) NSObject* userData;

@end
