//
//  HttpGetter.m
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-21.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "HttpGetter.h"
#import "Encodings.h"
#import "DataCacheService.h"


static dispatch_queue_t json_process_queue()
{
	static dispatch_queue_t json_queue;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		json_queue = dispatch_queue_create("com.json.process.queue", DISPATCH_QUEUE_CONCURRENT);
	});
	return json_queue;
}

@interface HttpGetter()

@property (nonatomic, retain) NSMutableData* rawData;

-(void) doFetch;
-(void) doSendNotification;
-(void) callObserverForReceivingEvent;
-(void) callObserverForSendingEvent;

-(void) increaseNetworkIndicator;
-(void) decreaseNetworkIndicator;
-(void) doUpdateNetworkIndicator;

@end



@implementation HttpGetter

@synthesize delegate = _delegate;
@synthesize getterObserver = _getterObserver;
@synthesize resultCode = _resultCode;
@synthesize resultMessage = _resultMessage;
@synthesize isFetching = _fetching;
@synthesize rawData = _rawData;
@synthesize cacheKey = _cacheKey;
@synthesize cachePolicy = _cachePolicy;
@synthesize tag = _tag;
@synthesize userData = _userData;
@synthesize totalBytesExpectedToReceive = _totalBytesExpectedToReceive;
@synthesize totalBytesReceived = _totalBytesReceived;
@synthesize totalBytesWritten = _totalBytesWritten;
@synthesize totalBytesExpectedToWrite = _totalBytesExpectedToWrite;
@synthesize shouldStoreResult = _shouldStoreResult;
@synthesize shouldAffectNetworkIndicator = _shouldAffectNetworkIndicator;
@synthesize urlRequest = _urlRequest;

static NSInteger _networkConnectionCount = 0;

+ (void)networkThreadEntry
{
	@autoreleasepool {
		NSRunLoop* theRunLoop = [NSRunLoop currentRunLoop];
		[theRunLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
		[theRunLoop run];
	}
}

+ (NSThread *)networkThread
{
	static NSThread* networkThread = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		networkThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkThreadEntry) object:nil];
		[networkThread start];
	});
	return networkThread;
}

-(id) init
{
	if ((self = [super init]))
	{
		self.cachePolicy = KYHttpCachePolicyIgnoreCache;
		self.shouldStoreResult = NO;
		self.shouldAffectNetworkIndicator = YES;
	}
	return self;
}

-(void) dealloc
{
	self.delegate = nil;
}

-(NSURLRequest *)urlRequest
{
	return [self _createRequest:KYHttpCachePolicyOnlyCache];
}

#pragma Hanldle network indicator

-(void) increaseNetworkIndicator
{
	_networkConnectionCount++;
	[self performSelectorOnMainThread:@selector(doUpdateNetworkIndicator) withObject:nil waitUntilDone:NO];
}

-(void) decreaseNetworkIndicator
{
	_networkConnectionCount--;
	[self performSelectorOnMainThread:@selector(doUpdateNetworkIndicator) withObject:nil waitUntilDone:NO];
}

-(void) doUpdateNetworkIndicator
{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (_networkConnectionCount > 0);
}


#pragma Performs on main thread

-(void) fetch
{
	_fetching = YES;
	_tempCachePolicy = _cachePolicy;
	[self performSelector:@selector(doFetch) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
}

-(void) stopFetching
{
	if (_fetching)
	{
		[self performSelector:@selector(doStopFetching) onThread:[[self class] networkThread] withObject:nil waitUntilDone:NO];
		_fetching = NO;
		_resultCode = KYResultCodeCanceled;
		[self.delegate didFinishFetch:self];
	}
}

-(void) doSendNotification
{
	if (_fetching)
	{
		_fetching = NO;
		_resultCode = _tempResultCode;
		[self.delegate didFinishFetch:self];
	}
}

- (BOOL)hasCacheForCacheKey:(NSString *)key
{
	NSData* cache = [self cacheDataForKey:key];
	if (cache.length > 0)
	{
		//LOG_debug(@"Load data from cache: %@", key);
		_tempResultCode = [self _fillModelWithData:cache];
		_resultCode = _tempResultCode;
		return YES;
	}
	return NO;
}

- (NSData *)cacheDataForKey:(NSString *)key
{
	return [[DataCacheService cacheWithType:DataCacheServiceHttp] getData:self.cacheKey];
}

- (void)storeCacheData:(NSData *)data forKey:(NSString *)key
{
	[[DataCacheService cacheWithType:DataCacheServiceHttp] saveData:key data:data];
}

-(BOOL) loadCache
{
	[self stopFetching];
	
	NSURLRequest* request = [self _createRequest:KYHttpCachePolicyOnlyCache];
	if (request == nil)
	{
		_resultCode = KYResultCodeInvalidRequest;
		return NO;
	}
	
	if (_cacheKey == nil)
	{
		self.cacheKey = [[request URL] absoluteString];
		NSData* bodyData = [request HTTPBody];
		if (bodyData.length > 0)
		{
			self.cacheKey = [NSString stringWithFormat:@"%@+%@", self.cacheKey, [bodyData md5]];
		}
	}
	
//	NSData* cache = [self cacheDataForKey:self.cacheKey];
//	if (cache.length > 0)
//	{
//		LOG_debug(@"Load data from cache: %@", self.cacheKey);
//		_resultCode = [self _fillModelWithData:cache];
//		if (_resultCode == KYResultCodeSuccess)
//			return YES;
//	}
//	else
//	{
//		LOG_debug(@"Cache not found: %@", self.cacheKey);
//		_resultCode = KYResultCodeCacheNotFound;
//	}
	if ([self hasCacheForCacheKey:self.cacheKey])
	{
		if (_resultCode == KYResultCodeSuccess)
			return YES;
	}
	else
	{
		LOG_debug(@"Cache not found: %@", self.cacheKey);
		_resultCode = KYResultCodeCacheNotFound;
	}
	return NO;
}

-(void) callObserverForReceivingEvent
{
	if ([_getterObserver conformsToProtocol:@protocol(HttpGetterObserver)])
	{
		if ([_getterObserver respondsToSelector:@selector(didReceivedData:)])
		{
			[(id<HttpGetterObserver>)_getterObserver didReceivedData:self];
		}
	}
}

-(void) callObserverForSendingEvent
{
	if ([_getterObserver conformsToProtocol:@protocol(HttpGetterObserver)])
	{
		if ([_getterObserver respondsToSelector:@selector(didWrittenData:)])
		{
			[(id<HttpGetterObserver>)_getterObserver didWrittenData:self];
		}
	}
}


#pragma Performs on daemon thread

-(void) doFetch
{
	[self doStopFetching];
	
	NSURLRequest* request = [self _createRequest:_tempCachePolicy];
	if (request == nil)
	{
		_tempResultCode = KYResultCodeInvalidRequest;
		[self sendNotification];
		return;
	}
	
	// Calculating cache key
	if (_cacheKey == nil)
	{
		self.cacheKey = [[request URL] absoluteString];
		NSData* bodyData = [request HTTPBody];
		if (bodyData.length > 0)
		{
			self.cacheKey = [NSString stringWithFormat:@"%@+%@", self.cacheKey, [bodyData md5]];
		}
	}
	
//	if (_tempCachePolicy != KYHttpCachePolicyIgnoreCache)
//	{
//		NSData* cache = [self cacheDataForKey:self.cacheKey];
//		if (cache.length > 0)
//		{
//			LOG_debug(@"Load data from cache: %@", self.cacheKey);
//			_tempResultCode = [self _fillModelWithData:cache];
//			[self sendNotification];
//			return;
//		}
//	}
	if (_tempCachePolicy != KYHttpCachePolicyIgnoreCache)
	{
		if ([self hasCacheForCacheKey:self.cacheKey])
		{
			[self sendNotification];
			return;
		}
	}
	
	if (_tempCachePolicy == KYHttpCachePolicyOnlyCache)
	{
		_tempResultCode = KYResultCodeCacheNotFound;
		[self sendNotification];
		return;
	}
	
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (_connection != nil && _shouldAffectNetworkIndicator)
	{
		[self increaseNetworkIndicator];
	}
}

-(void) doStopFetching
{
	if (_connection)
	{
		if (_shouldAffectNetworkIndicator)
			[self decreaseNetworkIndicator];
		[_connection cancel];
		_connection = nil;
		self.rawData = nil;
		LOG_debug(@"Connection did canceled!");
	}
}

-(void) sendNotification
{
	[self performSelectorOnMainThread:@selector(doSendNotification) withObject:nil waitUntilDone:NO];
}

-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy
{
	return nil;
}

-(NSInteger) _fillModelWithData:(NSData*)data
{
	return KYResultCodeParseError;
}

-(void) _didReceiveResponse:(NSURLResponse*)response
{
}


#pragma mark URLConnection

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
	_totalBytesExpectedToWrite = totalBytesExpectedToWrite;
	_totalBytesWritten = totalBytesWritten;
	[self performSelectorOnMainThread:@selector(callObserverForSendingEvent) withObject:nil waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	self.rawData = [[NSMutableData alloc] initWithCapacity:0];
	
	NSDictionary* headers = [(NSHTTPURLResponse*)response allHeaderFields];
	_totalBytesExpectedToReceive = [[headers objectForKey:@"Content-Length"] intValue];
	_totalBytesReceived = 0;
	
	LOG_debug(@"###################### Content Length: %d ############", _totalBytesExpectedToReceive);
	
	[self _didReceiveResponse:response];
	
	[self performSelectorOnMainThread:@selector(callObserverForReceivingEvent) withObject:nil waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	[self.rawData appendData:data];
	_totalBytesReceived += data.length;
	
	[self performSelectorOnMainThread:@selector(callObserverForReceivingEvent) withObject:nil waitUntilDone:NO];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	if (_shouldAffectNetworkIndicator)
		[self decreaseNetworkIndicator];
	_connection = nil;
	self.rawData = nil;
	
	LOG_debug(@"%@", [error localizedDescription]);
	
	_tempResultCode = KYResultCodeNetworkError;
	[self sendNotification];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	if (_shouldAffectNetworkIndicator)
		[self decreaseNetworkIndicator];
	_connection = nil;
	
	NSString* debugString = [[NSString alloc] initWithData:_rawData encoding:NSUTF8StringEncoding];
	LOG_debug(@"%@", debugString);
	dispatch_async(json_process_queue(), ^{
		_tempResultCode = [self _fillModelWithData:_rawData];
		if ((_tempCachePolicy != KYHttpCachePolicyIgnoreCache || self.shouldStoreResult) && _tempResultCode == KYResultCodeSuccess && _rawData.length > 0)
		{
			[self storeCacheData:_rawData forKey:self.cacheKey];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			self.rawData = nil;
			[self sendNotification];
		});
	});
}

@end



@implementation URLGetter

-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy
{
	if (self.url.length <= 0)
		return nil;
	return [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
}

-(NSInteger) _fillModelWithData:(NSData*)data
{
	self.data = data;
	return KYResultCodeSuccess;
}

@end

