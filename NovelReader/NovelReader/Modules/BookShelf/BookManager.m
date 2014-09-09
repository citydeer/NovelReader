//
//  BookManager.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-9.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "BookManager.h"



@implementation BookModel
@dynamic path, image, isNew, isPreview, name, isDownload, isFavorate, local_id;
@end



@implementation BookManager

+(BookManager*) instance
{
	static BookManager* _instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_instance = [[BookManager alloc] init];
	});
	return _instance;
}

-(void) searchBooks
{
}

@end

