//
//  BookManager.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-9.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "PKMappingObject.h"


@interface BookModel : PKMappingObject
@property (readwrite) NSString* local_id;
@property (readwrite) NSString* name;
@property (readwrite) NSString* image;
@property (readwrite) NSString* path;
@property (readwrite) BOOL isNew;
@property (readwrite) BOOL isPreview;
@property (readwrite) BOOL isFavorate;
@property (readwrite) BOOL isDownload;
@end



@interface BookManager : NSObject

@property (readonly) NSArray* books;

+(BookManager*) instance;

-(void) searchBooks;

@end

