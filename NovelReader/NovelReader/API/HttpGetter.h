//
//  HttpGetter.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-21.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "Getter.h"


@class HttpGetter;

@protocol HttpGetterObserver <NSObject>

@optional
-(void) didWrittenData:(HttpGetter*)getter;
-(void) didReceivedData:(HttpGetter*)getter;

@end



@interface HttpGetter : NSObject <Getter>
{
@private	
	NSURLConnection* _connection;
	NSMutableData* _rawData;
	
	KYHttpCachePolicy _cachePolicy;
	KYHttpCachePolicy _tempCachePolicy;
	NSString* _cacheKey;
	BOOL _shouldStoreResult;
	BOOL _shouldAffectNetworkIndicator;
	
	BOOL _fetching;
	
	NSInteger _tag;
	NSObject* _userData;
@protected
	NSInteger _resultCode;
	NSString* _resultMessage;
	__block NSInteger _tempResultCode;
	
	NSUInteger _totalBytesExpectedToReceive;
	NSUInteger _totalBytesReceived;
	NSInteger _totalBytesWritten;
	NSInteger _totalBytesExpectedToWrite;
}

@property (nonatomic, weak) id<HttpGetterObserver> getterObserver;
@property (nonatomic, copy) NSString* cacheKey;
@property (nonatomic, assign) BOOL shouldStoreResult;
@property (nonatomic, assign) BOOL shouldAffectNetworkIndicator;

@property (readonly) NSUInteger totalBytesExpectedToReceive;
@property (readonly) NSUInteger totalBytesReceived;
@property (readonly) NSInteger totalBytesWritten;
@property (readonly) NSInteger totalBytesExpectedToWrite;
@property (readonly) NSURLRequest* urlRequest;


-(void) sendNotification;
-(void) doStopFetching;
- (BOOL)hasCacheForCacheKey:(NSString *)key;
- (NSData *)cacheDataForKey:(NSString *)key;
- (void)storeCacheData:(NSData *)data forKey:(NSString *)key;
// Every model should implement methods below
-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy;
-(NSInteger) _fillModelWithData:(NSData*)data;
-(void) _didReceiveResponse:(NSURLResponse*)response;

@end



@interface NSData (NSData_Json)

/// Returns the NSDictionary or NSArray represented by the receiver's JSON representation, or nil on error
- (id)JSONValue;

@end
