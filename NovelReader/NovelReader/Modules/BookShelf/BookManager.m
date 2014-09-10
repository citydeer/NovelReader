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



@implementation XLBookModel
@dynamic book_about, book_addtime, book_author, book_chapterinfoid, book_coverimg_big, book_coverimg_middle, book_coverimg_small, book_id, book_isbn, book_isnew, book_isread, book_newchapterid, book_paytype, book_restype, book_showpay, book_state, book_tag, book_title, book_typeid, book_uptime, book_wordnum, id, isDownload, isFavorate, isPreview, bookPath;

-(BOOL) isEqual:(id)object
{
	if ([object isKindOfClass:[XLBookModel class]])
		return [self.book_id isEqualToString:((XLBookModel*)object).book_id];
	return NO;
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

-(void) addBook:(XLBookModel*)book
{
	BOOL changed = NO;
	[_lock lock];
	if (book.book_id.length > 0 && [_books indexOfObject:book] == NSNotFound)
	{
		changed = YES;
		book.bookPath = [_bookHomePath stringByAppendingPathComponent:book.book_id];
		[self createDirIfNotExists:book.bookPath];
		[book writeToFile:[book.bookPath stringByAppendingPathComponent:@"bookinfo.plist"]];
		[_books addObject:book];
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
		NSArray* books = [((RestfulAPIGetter*)getter).result[@"data"] convertItemsToPKMappingObject:[XLBookModel class]];
		for (XLBookModel* b in books)
		{
			b.isPreview = YES;
			[self addBook:b];
		}
		CDSetProp(PropAppPresetFlag, @"1");
	}
}

@end

