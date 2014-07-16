//
//  DataCacheService.h
//
//  Created by Pang Zhenyu on 10-12-31.
//  Copyright 2010 Tenfen Inc. All rights reserved.
//



typedef enum
{
	DataCacheServiceDefault = 0,
	DataCacheServiceHttp,
	DataCacheServicePermanence,
}
DataCacheServiceType;

@interface DataCacheService : NSObject
{
	NSString* _cacheFolderPath;
	NSTimeInterval _overtime;
}

-(id) initWithPath:(NSString*)folderPath overtime:(NSTimeInterval)interval;
-(BOOL) hasCacheForKey:(NSString*)key;
-(void) clearCache;
-(void) removeOvertimeCache;

-(NSData*) getData:(NSString*)key;
-(void) saveData:(NSString*)key data:(NSData*)theData;
-(NSArray*) getArray:(NSString*)key;
-(void) saveArray:(NSString*)key array:(NSArray*)theArray;
-(NSDictionary*) getDictionary:(NSString*)key;
-(void) saveDictionary:(NSString*)key dictionary:(NSDictionary*)theDictionary;

+(DataCacheService*) cacheWithType:(DataCacheServiceType)cacheType;

@end
