//
//  BookManager.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-9.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "PKMappingObject.h"



@interface XLBookModel : PKMappingObject

@property (readwrite) NSString* id;
@property (readwrite) NSString* book_id;
@property (readwrite) NSString* book_coverimg_small;
@property (readwrite) NSString* book_coverimg_middle;
@property (readwrite) NSString* book_coverimg_big;
@property (readwrite) NSString* book_title;
@property (readwrite) NSString* book_typeid;
@property (readwrite) NSString* book_restype;
@property (readwrite) NSString* book_author;
@property (readwrite) NSString* book_isbn;
@property (readwrite) NSString* book_tag;
@property (readwrite) NSString* book_about;
@property (readwrite) NSString* book_paytype;
@property (readwrite) NSString* book_state;
@property (readwrite) NSString* book_addtime;
@property (readwrite) NSString* book_uptime;
@property (readwrite) NSString* book_isnew;
@property (readwrite) NSString* book_newchapterid;
@property (readwrite) NSString* book_wordnum;
@property (readwrite) NSString* book_isread;
@property (readwrite) NSString* book_chapterinfoid;
@property (readwrite) NSString* book_showpay;

@property (readwrite) BOOL isPreview;
@property (readwrite) BOOL isFavorate;
@property (readwrite) BOOL isDownload;

@property (nonatomic, copy) NSString* bookPath;
@property (nonatomic, copy) NSArray* chapters;

-(void) saveBook;
-(void) saveBookInfo;
-(void) requestInfoAndChapters;

@end




@interface XLChapterModel : PKMappingObject

@property (readwrite) NSString* chapter_id;
@property (readwrite) NSString* chapter_title;
@property (readwrite) NSString* chapter_bookid;
@property (readwrite) NSString* chapter_wordnum;
@property (readwrite) NSString* chapter_paytype;
@property (readwrite) NSString* chapter_payvalue;
@property (readwrite) NSString* chapter_updatetime;
@property (readwrite) BOOL chapter_readable;

@property (nonatomic, copy) NSString* bookPath;
@property (nonatomic, copy) NSString* content;

-(void) requestContent;

@end






@interface BookManager : NSObject

@property (readonly) NSArray* books;

+(BookManager*) instance;

-(void) addBook:(XLBookModel*)book;

@end

