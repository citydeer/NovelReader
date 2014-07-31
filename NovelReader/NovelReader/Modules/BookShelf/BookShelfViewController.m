//
//  BookShelfViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-7-31.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "BookShelfViewController.h"
#import "MainTabViewController.h"
#import "BookCell.h"



@interface BookShelfViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
	UICollectionView* _gridView;
}

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
//	[self.rightButton setImage:CDImage(@"shelf/navi_menu2") forState:UIControlStateHighlighted];
	
	CGRect rect = self.view.bounds;
	
	UICollectionViewFlowLayout* cvf = [[UICollectionViewFlowLayout alloc] init];
	cvf.itemSize = CGSizeMake(84, 119);
	cvf.sectionInset = UIEdgeInsetsMake(16, 17, 16, 17);
	_gridView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, _naviBarHeight, rect.size.width, rect.size.height-_naviBarHeight) collectionViewLayout:cvf];
	_gridView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	_gridView.backgroundColor = CDColor(nil, @"e1e1e1");
	_gridView.dataSource = self;
	_gridView.delegate = self;
	[_gridView registerClass:[BookCell class] forCellWithReuseIdentifier:@"BookCell"];
	[self.view addSubview:_gridView];
}

-(void) rightButtonAction:(id)sender
{
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return 120;
}

-(UICollectionViewCell*) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookCell" forIndexPath:indexPath];
	cell.contentView.backgroundColor = [UIColor yellowColor];
	return cell;
}

@end

