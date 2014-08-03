//
//  BookShelfViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "BookShelfViewController.h"
#import "MainTabViewController.h"
#import "ReaderViewController.h"
#import "BookCell.h"
#import "Models.h"
#import "KYTipsView.h"



@interface BookShelfViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
	UICollectionView* _gridView;
	
	NSArray* _books;
}

-(void) searchBooks;

@end



@implementation BookShelfViewController

-(id) init
{
	self = [super init];
	if (self)
	{
	}
	return self;
}

-(void) dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = @"我的书架";
	
	[self.rightButton setImage:CDImage(@"shelf/navi_menu1") forState:UIControlStateNormal];
	
	CGRect rect = self.view.bounds;
	
	UICollectionViewFlowLayout* cvf = [[UICollectionViewFlowLayout alloc] init];
	cvf.itemSize = CGSizeMake(84, 150);
	cvf.sectionInset = UIEdgeInsetsMake(16, 17, 16, 17);
	_gridView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight) collectionViewLayout:cvf];
	_gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_gridView.backgroundColor = CDColor(nil, @"e1e1e1");
	_gridView.dataSource = self;
	_gridView.delegate = self;
	[_gridView registerClass:[BookCell class] forCellWithReuseIdentifier:@"BookCell"];
	[self.view addSubview:_gridView];
	
	[self searchBooks];
}

-(void) searchBooks
{
	[self.view showPopTitle:@"" msg:@"正在搜索..."];
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		@autoreleasepool {
			NSString* searchHome = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Books"];
			NSFileManager* localFileManager = [[NSFileManager alloc] init];
			NSDirectoryEnumerator* dirEnum = [localFileManager enumeratorAtPath:searchHome];
			
			NSMutableArray* arr = [NSMutableArray array];
			NSString* file;
			while ((file = [dirEnum nextObject]))
			{
				if ([file.pathExtension.lowercaseString isEqualToString: @"txt"])
				{
					BookModel* model = [[BookModel alloc] init];
					model.path = [searchHome stringByAppendingPathComponent:file];
					model.name = file.lastPathComponent.stringByDeletingPathExtension;
					model.isPreview = YES;
					model.image = [[searchHome stringByAppendingPathComponent:model.name] stringByAppendingPathExtension:@"jpg"];
					[arr addObject:model];
				}
			}
			_books = [NSArray arrayWithArray:arr];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.view dismissMsg];
				[_gridView reloadData];
			});
		}
	});
}

-(void) rightButtonAction:(id)sender
{
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return _books.count;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	BookCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCell" forIndexPath:indexPath];
	[cell applyModel:[_books objectAtIndex:indexPath.row]];
	return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	ReaderViewController* vc = [[ReaderViewController alloc] init];
	vc.bookModel = [_books objectAtIndex:indexPath.row];
	[_parent.cdNavigationController pushViewController:vc];
}

@end

