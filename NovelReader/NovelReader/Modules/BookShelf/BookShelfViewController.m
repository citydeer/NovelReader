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
#import "BookManager.h"
#import "KYTipsView.h"
#import "SelectorView.h"
#import "UIHelper.h"



@interface BookShelfViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SelectViewDelegate>
{
	UICollectionView* _gridView;
	
	NSArray* _books;
	
	BookManager* _bookManager;
	
	BOOL _onScreen;
}

@end



@implementation BookShelfViewController

-(id) init
{
	self = [super init];
	if (self)
	{
		_bookManager = [BookManager instance];
		[_bookManager addObserver:self forKeyPath:@"books" options:0 context:nil];
	}
	return self;
}

-(void) dealloc
{
	[_bookManager removeObserver:self forKeyPath:@"books"];
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
	_gridView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
	_gridView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 50, 0);
	_gridView.dataSource = self;
	_gridView.delegate = self;
	[_gridView registerClass:[BookCell class] forCellWithReuseIdentifier:@"BookCell"];
	[self.view addSubview:_gridView];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	_onScreen = YES;
	
	_books = _bookManager.books;
	[_gridView reloadData];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	_onScreen = NO;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (!_onScreen)
		return;
	
	if ([@"books" isEqualToString:keyPath])
	{
		_books = _bookManager.books;
		[_gridView reloadData];
	}
}

-(void) rightButtonAction:(id)sender
{
	SelectorView* sv = [[SelectorView alloc] initWithFrame:CGRectMake(320-156-10, _naviBarHeight-13, 156, 150)];
	sv.delegate = self;
	sv.icons = @[CDImage(@"shelf/import_book"), CDImage(@"shelf/manage_book"), CDImage(@"shelf/clean_book")];
	sv.items = @[@"导入本地书籍", @"管理书籍", @"清理无效书籍"];
	[UIHelper setView:sv toHeight:sv.totalHeight];
	[sv showInView:self.view];
}

-(void) didSelect:(SelectorView *)selectorView index:(NSUInteger)index
{
	[selectorView dismiss];
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

