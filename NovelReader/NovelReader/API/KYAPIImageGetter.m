//
//  KYAPIImageGetter.m
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-22.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "KYAPIImageGetter.h"
#import "Encodings.h"
#import "AZImageCache.h"
#import "Properties.h"



@implementation KYAPIImageGetter

-(id) init
{
	self = [super init];
	if (self)
	{
		self.cachePolicy = KYHttpCachePolicyUseIfAvailable;
		self.shouldStoreResult = YES;
		self.imageSize = CGSizeZero;
	}
	return self;
}

-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy
{
	if (_imageId.length <= 0)
		return nil;
		
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Properties appProperties].imageHost, _imageId]];
	
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:120];
	[request setHTTPMethod:@"GET"];
	if (_referUrl.length > 0)
		[request setValue:_referUrl forHTTPHeaderField:@"referer"];
	return request;
}

-(NSInteger) _fillModelWithData:(NSData *)data
{
	UIImage* im = [UIImage imageWithData:data];
	if (im != nil)
	{
		self.image = [UIImage imageWithCGImage:im.CGImage scale:[UIScreen mainScreen].scale orientation:im.imageOrientation];
		self.imageSize = im.size;
		[[AZImageCache sharedImageCache] storeCacheImage:self.image forKey:self.cacheKey];
		return KYResultCodeSuccess;
	}
	return KYResultCodeParseError;
}

- (NSInteger)_fillModelWithImage:(UIImage *)image
{
	self.image = image;
	self.imageSize = image.size;
	return KYResultCodeSuccess;
}

- (BOOL)hasCacheForCacheKey:(NSString *)key
{
	UIImage* image = [[AZImageCache sharedImageCache] cacheImageForKey:key];
	if (image)
	{
		_tempResultCode = [self _fillModelWithImage:image];
		_resultCode = _tempResultCode;
		return YES;
	}
	NSData* cache = [self cacheDataForKey:key];
	if (cache.length > 0)
	{
		_tempResultCode = [self _fillModelWithData:cache];
		_resultCode = _tempResultCode;
		return YES;
	}
	return NO;
}

@end
