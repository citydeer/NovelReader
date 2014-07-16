//
//  AZImageCache.h
//  CJWF
//
//  Created by zhihui zhao on 13-8-23.
//  Copyright (c) 2013年 Tenfen Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AZImageCache : NSCache
+ (AZImageCache *)sharedImageCache;
- (NSData *)cacheDataForKey:(NSString *)cacheKey;
- (void)storeCacheData:(NSData *)data forKey:(NSString *)cacheKey;
- (UIImage *)cacheImageForKey:(NSString *)cacheKey;
- (void)storeCacheImage:(UIImage *)image forKey:(NSString *)cacheKey;
@end
