//
//  BookManager.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-9.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "BookManager.h"
#import "GetterController.h"
#import "RestfulAPIGetter.h"
#import "Properties.h"



@interface XLChapterModel () <GetterControllerOwner>
{
	GetterController* _getterController;
}
@end


@implementation XLChapterModel

@dynamic chapter_bookid, chapter_id, chapter_paytype, chapter_payvalue, chapter_readable, chapter_title, chapter_updatetime, chapter_wordnum;

-(BOOL) isEqual:(id)object
{
	if ([object isKindOfClass:[XLChapterModel class]])
		return [self.chapter_id isEqualToString:((XLChapterModel*)object).chapter_id];
	return NO;
}

-(void) requestContent
{
	if (self.content.length <=0 && self.bookPath.length > 0)
	{
		NSString* txtPath = [self.bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.chapter_id]];
		NSString* txt = [NSString stringWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:NULL];
		if (txt.length > 0)
		{
			[self setValue:txt forKey:@"content"];
			return;
		}
	}
	
	_getterController = [[GetterController alloc] initWithOwner:self];
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"book", @"a" : @"getcontent", @"bookid" : self.chapter_bookid, @"chapterid" : self.chapter_id};
	[_getterController enqueueGetter:getter];
}

-(void) handleGetter:(id<Getter>)getter
{
	if (getter.resultCode == KYResultCodeSuccess)
	{
		NSString* txt = ((RestfulAPIGetter*)getter).result[@"data"][@"chapter_content"];
		if (self.bookPath.length > 0)
		{
			NSString* txtPath = [self.bookPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt", self.chapter_id]];
			[txt writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:NULL];
		}
		[self setValue:txt forKey:@"content"];
	}
	self.errorMsg = [getter resultMessage];
	[self setValue:[NSNumber numberWithBool:(getter.resultCode != KYResultCodeSuccess)] forKey:@"requestFailed"];
}

@end




@interface XLBookModel () <GetterControllerOwner>
{
	GetterController* _getterController;
	NSMutableArray* _chapters;
}
@end


@implementation XLBookModel

@dynamic book_about, book_addtime, book_author, book_chapterinfoid, book_coverimg_big, book_coverimg_middle, book_coverimg_small, book_id, book_isbn, book_isnew, book_isread, book_newchapterid, book_paytype, book_restype, book_showpay, book_state, book_tag, book_title, book_typeid, book_uptime, book_wordnum, id, isDownload, isFavorate, isPreview, lastReadTime, lastReadChapterID, lastReadLocation, bookmarkTable;

-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		_chapters = [NSMutableArray array];
		self.bookmarkTable = [self.bookmarkTable mutableCopy];
	}
	return self;
}

-(BOOL) isEqual:(id)object
{
	if ([object isKindOfClass:[XLBookModel class]])
		return [self.book_id isEqualToString:((XLBookModel*)object).book_id];
	return NO;
}

-(NSArray*) chapters
{
	return _chapters;
}

-(void) requestInfoAndChapters
{
	if (self.chapters.count <= 0 && self.bookPath.length > 0)
	{
		NSArray* dir = [NSArray arrayWithContentsOfFile:[self.bookPath stringByAppendingPathComponent:@"directory.plist"]];
		NSArray* chapters = [dir arrayByConvertToPKMappingObject:[XLChapterModel class]];
		for (XLChapterModel* c in chapters)
			c.bookPath = self.bookPath;
		[self willChangeValueForKey:@"chapters"];
		[_chapters removeAllObjects];
		[_chapters addObjectsFromArray:chapters];
		[self didChangeValueForKey:@"chapters"];
	}
	
	_getterController = [[GetterController alloc] initWithOwner:self];
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"book", @"a" : @"getinfochapters", @"bookid" : self.book_id};
	[_getterController enqueueGetter:getter];
}

-(void) saveBook
{
	if (self.bookPath.length > 0)
	{
		[self writeToFile:[self.bookPath stringByAppendingPathComponent:@"bookinfo.plist"]];
		[[_chapters arrayByConvertToDictionary] writeToFile:[self.bookPath stringByAppendingPathComponent:@"directory.plist"] atomically:YES];
	}
}

-(void) saveBookInfo
{
	if (self.bookPath.length > 0)
	{
		[self writeToFile:[self.bookPath stringByAppendingPathComponent:@"bookinfo.plist"]];
	}
}

-(void) clearChapters
{
	[_chapters removeAllObjects];
}

-(void) handleGetter:(id<Getter>)getter
{
	if (getter.resultCode == KYResultCodeSuccess)
	{
		NSDictionary* data = ((RestfulAPIGetter*)getter).result[@"data"];
		[_dic addEntriesFromDictionary:data[@"info"]];
		NSArray* chapters = [data[@"chapters"] arrayByConvertToPKMappingObject:[XLChapterModel class]];
		for (XLChapterModel* c in chapters)
			c.bookPath = self.bookPath;
		
		BOOL changed = NO;
		NSUInteger lastIndex = [chapters indexOfObject:_chapters.lastObject];
		if (lastIndex == NSNotFound)
		{
			[_chapters removeAllObjects];
			[_chapters addObjectsFromArray:chapters];
			changed = YES;
		}
		else if (lastIndex < chapters.count - 1)
		{
			[_chapters addObjectsFromArray:[chapters subarrayWithRange:NSMakeRange(lastIndex+1, chapters.count-lastIndex-1)]];
			changed = YES;
		}
		if (changed)
		{
			[self saveBook];
			[self willChangeValueForKey:@"chapters"];
			[self didChangeValueForKey:@"chapters"];
		}
	}
	self.errorMsg = [getter resultMessage];
	[self setValue:[NSNumber numberWithBool:(getter.resultCode != KYResultCodeSuccess)] forKey:@"requestFailed"];
}

@end




@interface BookManager () <GetterControllerOwner>
{
	NSLock* _lock;
	
	GetterController* _getterController;
	NSString* _bookHomePath;
	NSMutableArray* _books;
}

-(void) createDirIfNotExists:(NSString*)dirPath;

-(void) initBooks;
-(void) getPresetBooks;

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

-(id) init
{
	self = [super init];
	if (self)
	{
		_lock = [[NSLock alloc] init];
		_getterController = [[GetterController alloc] initWithOwner:self];
		_books = [[NSMutableArray alloc] init];
		
		NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		_bookHomePath = [(NSString*)[paths firstObject] stringByAppendingPathComponent:@"Books"];
		[self createDirIfNotExists:_bookHomePath];
		
		[self initBooks];
	}
	return self;
}

-(void) createDirIfNotExists:(NSString*)dirPath
{
	NSFileManager* fm = [NSFileManager defaultManager];
	BOOL isDirectory = YES;
	BOOL exists = [fm fileExistsAtPath:dirPath isDirectory:&isDirectory];
	if (exists && !isDirectory)
	{
		[fm removeItemAtPath:dirPath error:NULL];
		exists = NO;
	}
	if (!exists)
	{
		[fm createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
	}
}

-(NSArray*) books
{
	[_lock lock];
	NSArray* ret = [_books copy];
	[_lock unlock];
	return ret;
}

-(void) initBooks
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@autoreleasepool
		{
			[_lock lock];
			NSFileManager* localFileManager = [[NSFileManager alloc] init];
			NSArray* paths = [localFileManager contentsOfDirectoryAtPath:_bookHomePath error:NULL];
			NSMutableArray* arr = [NSMutableArray array];
			BOOL isDir = NO;
			for (NSString* path in paths)
			{
				NSString* fullPath = [_bookHomePath stringByAppendingPathComponent:path];
				if ([localFileManager fileExistsAtPath:fullPath isDirectory:&isDir] && isDir)
				{
					NSString* plist = [fullPath stringByAppendingPathComponent:@"bookinfo.plist"];
					XLBookModel* model = [[XLBookModel alloc] initWithContentsOfFile:plist];
					if (model.book_id.length > 0 && [model.book_id isEqualToString:path.lastPathComponent])
					{
						model.bookPath = fullPath;
						[arr addObject:model];
					}
				}
			}
			[_books removeAllObjects];
			[_books addObjectsFromArray:arr];
			[_lock unlock];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self willChangeValueForKey:@"books"];
				[self didChangeValueForKey:@"books"];
				[self getPresetBooks];
			});
		}
	});
}

-(void) getPresetBooks
{
	if ([CDProp(PropAppPresetFlag) boolValue])
		return;
	
	RestfulAPIGetter* getter = [[RestfulAPIGetter alloc] init];
	getter.params = @{@"c" : @"site", @"a" : @"bookcaserecomm"};
	[_getterController enqueueGetter:getter];
}

-(NSArray*) sortedBooks
{
	return [_books copy];
//	return [_books sortedArrayUsingComparator:^NSComparisonResult(XLBookModel* obj1, XLBookModel* obj2) {
//		if (obj1.lastReadTime == obj2.lastReadTime)
//			return NSOrderedSame;
//		if (obj1.lastReadTime == 0.0)
//			return NSOrderedAscending;
//		if (obj2.lastReadTime == 0.0)
//			return NSOrderedDescending;
//		if (obj1.lastReadTime < obj2.lastReadTime)
//			return NSOrderedDescending;
//		return NSOrderedAscending;
//	}];
}

-(void) addBooks:(NSArray*)books
{
	BOOL changed = NO;
	[_lock lock];
	for (XLBookModel* book in books)
	{
		if (book.book_id.length > 0 && [_books indexOfObject:book] == NSNotFound)
		{
			changed = YES;
			book.bookPath = [_bookHomePath stringByAppendingPathComponent:book.book_id];
			[self createDirIfNotExists:book.bookPath];
			[book saveBook];
			[_books addObject:book];
		}
	}
	[_lock unlock];
	if (changed)
	{
		[self willChangeValueForKey:@"books"];
		[self didChangeValueForKey:@"books"];
	}
}

-(void) handleGetter:(id<Getter>)getter
{
	if (getter.resultCode == KYResultCodeSuccess)
	{
		NSArray* books = [((RestfulAPIGetter*)getter).result[@"data"] arrayByConvertToPKMappingObject:[XLBookModel class]];
		for (XLBookModel* b in books)
			b.isPreview = YES;
		[self addBooks:books];
		CDSetProp(PropAppPresetFlag, @"1");
	}
}

-(void) deleteBooks:(NSArray*)books
{
	for (XLBookModel* b in books)
	{
		[_books removeObject:b];
		if (b.bookPath.length > 0)
		{
			[[NSFileManager defaultManager] removeItemAtPath:b.bookPath error:NULL];
		}
	}
	[self willChangeValueForKey:@"books"];
	[self didChangeValueForKey:@"books"];
}

-(XLBookModel*) getBook:(NSString*)bookID
{
	for (XLBookModel* book in _books)
		if ([book.book_id isEqualToString:bookID])
			return book;
	return nil;
}

-(void) addFav:(NSString*)bookID
{
	if (bookID.length <= 0)
		return;
	
	XLBookModel* book = [self getBook:bookID];
	if (book == nil)
	{
		book = [[XLBookModel alloc] initWithDictionary:nil];
		book.book_id = bookID;
		book.isFavorate = YES;
		[self addBooks:@[book]];
		[book requestInfoAndChapters];
	}
	else
	{
		book.isFavorate = YES;
		[book saveBookInfo];
	}
}

-(void) downloadBook:(NSString*)bookID
{
	if (bookID.length <= 0)
		return;
	
	XLBookModel* book = [self getBook:bookID];
	if (book == nil)
	{
		book = [[XLBookModel alloc] initWithDictionary:nil];
		book.book_id = bookID;
		book.isDownload = YES;
		[self addBooks:@[book]];
		[book requestInfoAndChapters];
	}
	else
	{
		book.isDownload = YES;
		[book saveBookInfo];
	}
}

-(BOOL) isFav:(NSString*)bookID
{
	return [self getBook:bookID].isFavorate;
}

-(BOOL) hasDownloaded:(NSString*)bookID
{
	return [self getBook:bookID].isDownload;
}

@end

