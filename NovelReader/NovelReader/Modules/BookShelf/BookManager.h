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
@property (readwrite) double lastReadTime;
@property (readwrite) NSString* lastReadChapterID;
@property (readwrite) NSInteger lastReadLocation;
@property (readwrite) NSMutableDictionary* bookmarkTable;

@property (nonatomic, copy) NSString* bookPath;
@property (readonly) NSArray* chapters;

@property (nonatomic, assign) BOOL requestFailed;
@property (nonatomic, copy) NSString* errorMsg;

@property (nonatomic, assign) BOOL editing;
@property (nonatomic, assign) BOOL selected;

-(void) saveBook;
-(void) saveBookInfo;
-(void) requestInfoAndChapters;
-(void) clearChapters;

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

@property (nonatomic, assign) BOOL requestFailed;
@property (nonatomic, copy) NSString* errorMsg;

-(void) requestContent;

@end






@interface BookManager : NSObject

@property (readonly) NSArray* books;

+(BookManager*) instance;

-(NSArray*) sortedBooks;

-(void) addBooks:(NSArray*)books;
-(void) deleteBooks:(NSArray*)books;

-(XLBookModel*) getBook:(NSString*)bookID;
-(void) addFav:(NSString*)bookID;
-(void) downloadBook:(NSString*)bookID;
-(BOOL) isFav:(NSString*)bookID;
-(BOOL) hasDownloaded:(NSString*)bookID;

@end

