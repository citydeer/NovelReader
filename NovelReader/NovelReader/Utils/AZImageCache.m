//
//  AZImageCache.m
//  CJWF
//
//  Created by zhihui zhao on 13-8-23.
//  Copyright (c) 2013年 Tenfen Inc. All rights reserved.
//

#import "AZImageCache.h"

@implementation AZImageCache

+ (AZImageCache *)sharedImageCache
{
	static AZImageCache* imageCache = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		imageCache = [[AZImageCache alloc] init];
		imageCache.countLimit = 100;
	});
	return imageCache;
}

- (NSData *)cacheDataForKey:(NSString *)cacheKey
{
	return [self objectForKey:cacheKey];
}

- (void)storeCacheData:(NSData *)data forKey:(NSString *)cacheKey
{
	[self setObject:data forKey:cacheKey];
}

- (UIImage *)cacheImageForKey:(NSString *)cacheKey
{
	return [self objectForKey:cacheKey];
}

- (void)storeCacheImage:(UIImage *)image forKey:(NSString *)cacheKey
{
	[self setObject:image forKey:cacheKey];
}

@end
