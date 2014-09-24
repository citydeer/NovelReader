//
//  DataCacheService.m
//
//  Created by Pang Zhenyu on 10-12-31.
//  Copyright 2010 Tenfen Inc. All rights reserved.
//

#import "DataCacheService.h"
#import "Encodings.h"


@interface DataCacheService()

-(void) checkCacheDirectories;
-(NSString*) fullPathForKey:(NSString*)key;

@end


#define DIRECTORY_NUMBER 32

@implementation DataCacheService

-(id) initWithPath:(NSString*)folderPath overtime:(NSTimeInterval)interval
{
	if ((self = [super init]))
	{
		_cacheFolderPath = [folderPath copy];
		_overtime = interval;
		
		[self checkCacheDirectories];
		
		// 清除过期的缓存数据
		if (interval > 0)
		{
			[NSThread detachNewThreadSelector:@selector(removeOvertimeCache) toTarget:self withObject:nil];
		}
	}
	return self;
}

-(void) dealloc
{
}

-(void) checkCacheDirectories
{
	NSFileManager* fm = [NSFileManager defaultManager];
	
	// if root directory doesn't exist, or it's not a directory, create.
	BOOL isDirectory = YES;
	BOOL exists = [fm fileExistsAtPath:_cacheFolderPath isDirectory:&isDirectory];
	if (exists && !isDirectory)
	{
		[fm removeItemAtPath:_cacheFolderPath error:NULL];
		exists = NO;
	}
	if (!exists)
	{
		[fm createDirectoryAtPath:_cacheFolderPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	for (NSInteger i = 0; i < DIRECTORY_NUMBER; ++i)
	{
		NSString* subPath = [_cacheFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"__%ld__", (long)i]];
		isDirectory = YES;
		exists = [fm fileExistsAtPath:subPath isDirectory:&isDirectory];
		if (exists && !isDirectory)
		{
			[fm removeItemAtPath:subPath error:NULL];
			exists = NO;
		}
		if (!exists)
		{
			[fm createDirectoryAtPath:subPath withIntermediateDirectories:YES attributes:nil error:NULL];
		}
	}
}

-(NSString*) fullPathForKey:(NSString*)key
{
	NSString* dir = [_cacheFolderPath stringByAppendingPathComponent:[NSString stringWithFormat:@"__%lu__", (long)([key hash] % DIRECTORY_NUMBER)]];
	return [dir stringByAppendingPathComponent:[key md5]];
}

-(BOOL) hasCacheForKey:(NSString*)key
{
	if (key.length <= 0)
		return NO;
	
	NSString* path = [self fullPathForKey:key];
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

-(void) clearCache
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:_cacheFolderPath])
	{
		[[NSFileManager defaultManager] removeItemAtPath:_cacheFolderPath error:NULL];
	}
	[self checkCacheDirectories];
}

-(void) removeOvertimeCache
{
	@autoreleasepool {
		int count = 0;
		NSFileManager* fm = [NSFileManager defaultManager];
		NSArray* dirs = [fm contentsOfDirectoryAtPath:_cacheFolderPath error:NULL];
		for (NSString* dirName in dirs)
		{
			NSString* subDir = [_cacheFolderPath stringByAppendingPathComponent:dirName];
			NSArray* files = [fm contentsOfDirectoryAtPath:subDir error:NULL];
			for (NSString* fileName in files)
			{
				NSString* path = [subDir stringByAppendingPathComponent:fileName];
				NSDictionary* attr = [fm attributesOfItemAtPath:path error:NULL];
				if (attr != nil && fabs([[attr fileModificationDate] timeIntervalSinceNow]) > _overtime)
				{
					[fm removeItemAtPath:path error:NULL];
					count++;
				}
			}
		}
		
		LOG_debug(@"Number of overtime cache data: %d", count);
	}
}

-(NSData*) getData:(NSString*)key
{
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
		return [NSData dataWithContentsOfFile:dataPath];
	}
	return nil;
}

-(void) saveData:(NSString*)key data:(NSData*)theData
{
	if (key.length <= 0)
		return;
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString* dataPath = [self fullPathForKey:key];
		if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
		{
			[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
		}
		if (theData != nil)
			[theData writeToFile:dataPath atomically:YES];
	});
}

-(NSArray*) getArray:(NSString*)key
{
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
		return [NSArray arrayWithContentsOfFile:dataPath];
	}
	return nil;
}

-(void) saveArray:(NSString*)key array:(NSArray*)theArray
{
	if (key.length <= 0)
		return;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString* dataPath = [self fullPathForKey:key];
		if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
		{
			[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
		}
		if (theArray != nil)
			[theArray writeToFile:dataPath atomically:YES];
	});
}

-(NSDictionary*) getDictionary:(NSString*)key
{
	if (key.length <= 0)
		return nil;
	
	NSString* dataPath = [self fullPathForKey:key];
	if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
	{
		// 使用文件的修改时间来标识上次访问的时间
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], NSFileModificationDate, nil];
		[[NSFileManager defaultManager] setAttributes:dict ofItemAtPath:dataPath error:NULL];
		return [NSDictionary dictionaryWithContentsOfFile:dataPath];
	}
	return nil;
}

-(void) saveDictionary:(NSString*)key dictionary:(NSDictionary*)theDictionary
{
	if (key.length <= 0)
		return;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString* dataPath = [self fullPathForKey:key];
		if ([[NSFileManager defaultManager] fileExistsAtPath:dataPath])
		{
			[[NSFileManager defaultManager] removeItemAtPath:dataPath error:NULL];
		}
		if (theDictionary != nil)
			[theDictionary writeToFile:dataPath atomically:YES];
	});
}


static DataCacheService* _httpCache = nil;
static DataCacheService* _defaultCache = nil;
static DataCacheService* _permanenceCache = nil;

+(DataCacheService*) cacheWithType:(DataCacheServiceType)cacheType
{
	switch (cacheType)
	{
		case DataCacheServiceHttp:
			if (_httpCache == nil)
			{
				@synchronized(self)
				{
					if (_httpCache == nil)
					{
						NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
						NSString* httpPath = [(NSString*)[paths lastObject] stringByAppendingPathComponent:@"CacheRoot"];
						_httpCache = [[DataCacheService alloc] initWithPath:httpPath overtime:0];
					}
				}
			}
			return _httpCache;
		case DataCacheServicePermanence:
			if (_permanenceCache == nil)
			{
				@synchronized(self)
				{
					if (_permanenceCache == nil)
					{
						NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
						NSString* httpPath = [(NSString*)[paths lastObject] stringByAppendingPathComponent:@"__j4fvJ8H"];
						_permanenceCache = [[DataCacheService alloc] initWithPath:httpPath overtime:0];
					}
				}
			}
			return _permanenceCache;
		default:
			if (_defaultCache == nil)
			{
				@synchronized(self)
				{
					if (_defaultCache == nil)
					{
						NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
						NSString* defaultPath = [(NSString*)[paths lastObject] stringByAppendingPathComponent:@"ContentData"];
						_defaultCache = [[DataCacheService alloc] initWithPath:defaultPath overtime:0];
					}
				}
			}
			return _defaultCache;
	}
	return nil;
}

@end
