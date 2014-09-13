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



@interface BookShelfViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SelectViewDelegate, UIAlertViewDelegate>
{
	UICollectionView* _gridView;
	
	NSArray* _books;
	BookManager* _bookManager;
	
	BOOL _onScreen;
	BOOL _editing;
	
	UIButton* _doneButton;
	UIButton* _deleteButton;
}

-(void) deleteAction:(id)sender;
-(void) doneAction:(id)sender;
-(void) longPressAction:(UILongPressGestureRecognizer*)lpgr;
-(void) updateView;
-(void) updateDeleteButton;

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
	
	_deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _statusBarHeight, 80.0f, _naviBarHeight - _statusBarHeight)];
	_deleteButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
	_deleteButton.showsTouchWhenHighlighted = YES;
	_deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
	[_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_deleteButton setTitleColor:CDColor(nil, @"4e4e4e") forState:UIControlStateDisabled];
	[_deleteButton addTarget:self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.naviBarView addSubview:_deleteButton];
	
	_doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.naviBarView.bounds.size.width - 60.0f, _statusBarHeight, 60.0f, _naviBarHeight - _statusBarHeight)];
	_doneButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
	_doneButton.showsTouchWhenHighlighted = YES;
	_doneButton.titleLabel.font = [UIFont systemFontOfSize:14];
	[_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_doneButton setTitle:@"完成" forState:UIControlStateNormal];
	[_doneButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
	[self.naviBarView addSubview:_doneButton];
	
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
	[_gridView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressAction:)]];
	[self.view addSubview:_gridView];
}

-(void) willPresentView:(NSTimeInterval)duration
{
	[super willPresentView:duration];
	_onScreen = YES;
	
	_books = [_bookManager sortedBooks];
	_editing = NO;
	[self updateView];
}

-(void) willDismissView:(NSTimeInterval)duration
{
	[super willDismissView:duration];
	_onScreen = NO;
}

-(void) updateView
{
	self.rightButton.hidden = _editing;
	_deleteButton.hidden = !_editing;
	_doneButton.hidden = !_editing;
	[self updateDeleteButton];
	
	for (XLBookModel* book in _books)
	{
		book.editing = _editing;
		book.selected = NO;
	}
	[_gridView reloadData];
}

-(void) updateDeleteButton
{
	NSInteger count = 0;
	for (XLBookModel* book in _books)
		if (book.selected)
			count++;
	[_deleteButton setTitle:[NSString stringWithFormat:@"删除(%d)", count] forState:UIControlStateNormal];
	_deleteButton.enabled = (count > 0);
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (!_onScreen)
		return;
	
	if ([@"books" isEqualToString:keyPath])
	{
		_books = [_bookManager sortedBooks];
		_editing = NO;
		[self updateView];
	}
}

-(void) rightButtonAction:(id)sender
{
	SelectorView* sv = [[SelectorView alloc] initWithFrame:CGRectMake(320-156-10, _naviBarHeight-13, 156, 150)];
	sv.delegate = self;
//	sv.icons = @[CDImage(@"shelf/import_book"), CDImage(@"shelf/manage_book"), CDImage(@"shelf/clean_book")];
//	sv.items = @[@"导入本地书籍", @"管理书籍", @"清理无效书籍"];
	sv.icons = @[CDImage(@"shelf/manage_book")];
	sv.items = @[@"管理书籍"];
	[UIHelper setView:sv toHeight:sv.totalHeight];
	[sv showInView:self.view];
}

-(void) didSelect:(SelectorView *)selectorView index:(NSUInteger)index
{
	[selectorView dismiss];
	
	_editing = YES;
	[self updateView];
}

-(void) longPressAction:(UILongPressGestureRecognizer*)lpgr
{
	if (!_editing)
	{
		NSIndexPath* indexPath = [_gridView indexPathForItemAtPoint:[lpgr locationInView:_gridView]];
		if (indexPath != nil)
		{
			_editing = YES;
			[self performSelectorOnMainThread:@selector(updateView) withObject:nil waitUntilDone:NO];
		}
	}
}

-(void) deleteAction:(id)sender
{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"您确定要删除这些书吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
	[alert show];
}

-(void) doneAction:(id)sender
{
	_editing = NO;
	[self updateView];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 1)
	{
		NSMutableArray* toBeDeleted = [NSMutableArray array];
		for (XLBookModel* book in _books)
			if (book.selected)
				[toBeDeleted addObject:book];
		
		_editing = NO;
		[self updateView];
		[_bookManager deleteBooks:toBeDeleted];
	}
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
	if (_editing)
	{
		XLBookModel* book = _books[indexPath.row];
		book.selected = !book.selected;
		[collectionView reloadItemsAtIndexPaths:@[indexPath]];
		[self updateDeleteButton];
	}
	else
	{
		ReaderViewController* vc = [[ReaderViewController alloc] init];
		vc.bookModel = [_books objectAtIndex:indexPath.row];
		[_parent.cdNavigationController pushViewController:vc];
	}
}

@end

