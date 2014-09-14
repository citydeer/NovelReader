//
//  DirectoryViewController.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-14.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "DirectoryViewController.h"
#import "UIHelper.h"
#import "BookManager.h"
#import "ReaderViewController.h"



@interface DirectoryViewController () <UITableViewDataSource, UITableViewDelegate>
{
	NSArray* _chapters;
	NSArray* _bookmarks;
	
	UITableView* _directoryView;
	UITableView* _bookmarkView;
	
	UIButton* _directoryButton;
	UIButton* _bookmarkButton;
	UIView* _underlineView;
	
	NSDateFormatter* _formatter;
}

-(void) switchAction:(UIButton*)sender;
-(void) updateTabButton;

@end



@implementation DirectoryViewController

-(id) init
{
    self = [super init];
    if (self)
	{
		_formatter = [[NSDateFormatter alloc] init];
		[_formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    }
    return self;
}

-(void) dealloc
{
}

-(void) loadView
{
	[super loadView];
	
	self.titleLabel.text = @"目录";
	
	[self.leftButton setImage:CDImage(@"main/navi_back") forState:UIControlStateNormal];
	self.leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15.0f, 0, 0);
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	CGRect rect = self.view.bounds;
	UIView* container = [UIHelper addRect:self.view color:nil x:0 y:_naviBarHeight w:rect.size.width h:rect.size.height-_naviBarHeight resizing:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	
	[UIHelper addLabel:container t:_bookModel.book_title tc:CDColor(nil, @"282828") fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(12, 13, 300, 20)];
	NSString* author = [NSString stringWithFormat:@"作者: %@", _bookModel.book_author];
	[UIHelper addLabel:container t:author tc:CDColor(nil, @"757575") fs:9 b:NO al:NSTextAlignmentLeft frame:CGRectMake(12, 35, 300, 18)];
	
	_directoryButton = [[UIButton alloc] initWithFrame:CGRectMake(12, 62, 60, 30)];
	_directoryButton.titleLabel.font = [UIFont systemFontOfSize:12];
	[_directoryButton setTitle:@"目录" forState:UIControlStateNormal];
	[_directoryButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	[container addSubview:_directoryButton];
	
	_bookmarkButton = [[UIButton alloc] initWithFrame:CGRectMake(72, 62, 60, 30)];
	_bookmarkButton.titleLabel.font = [UIFont systemFontOfSize:12];
	[_bookmarkButton setTitle:@"书签" forState:UIControlStateNormal];
	[_bookmarkButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
	[container addSubview:_bookmarkButton];
	
	[UIHelper addRect:container color:CDColor(nil, @"8b8b8b") x:0 y:91.5 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
	_underlineView = [UIHelper addRect:container color:CDColor(nil, @"ec6226") x:12 y:89 w:60 h:3 resizing:0];
	
	_directoryView = [[UITableView alloc] initWithFrame:CGRectMake(0, 92, rect.size.width, container.bounds.size.height-92) style:UITableViewStylePlain];
	_directoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_directoryView.dataSource = self;
	_directoryView.delegate = self;
	_directoryView.backgroundColor = [UIColor clearColor];
	_directoryView.showsVerticalScrollIndicator = YES;
	_directoryView.bounces = YES;
	_directoryView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[container addSubview:_directoryView];
	
	_bookmarkView = [[UITableView alloc] initWithFrame:CGRectMake(0, 92, rect.size.width, container.bounds.size.height-92) style:UITableViewStylePlain];
	_bookmarkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_bookmarkView.dataSource = self;
	_bookmarkView.delegate = self;
	_bookmarkView.backgroundColor = [UIColor clearColor];
	_bookmarkView.showsVerticalScrollIndicator = YES;
	_bookmarkView.bounces = YES;
	_bookmarkView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[container addSubview:_bookmarkView];
	
	_bookmarkView.hidden = YES;
	[self updateTabButton];
}

-(void) viewDidLoad
{
	[super viewDidLoad];
	
	_chapters = [_bookModel.chapters copy];
	[_directoryView reloadData];
	
	_bookmarks = [_bookModel.bookmarkTable.allKeys sortedArrayUsingSelector:@selector(compare:)];
	if (_bookmarks.count <= 0)
		_bookmarkButton.hidden = YES;
	else
		[_bookmarkView reloadData];
	_bookmarkView.hidden = YES;
	[self updateTabButton];
}

-(void) updateTabButton
{
	BOOL phone = _bookmarkView.hidden;
	[_directoryButton setTitleColor:(phone ? CDColor(nil, @"282828") : CDColor(nil, @"757575")) forState:UIControlStateNormal];
	[_directoryButton setTitleColor:(phone ? CDColor(nil, @"282828") : CDColor(nil, @"757575")) forState:UIControlStateHighlighted];
	[_bookmarkButton setTitleColor:(!phone ? CDColor(nil, @"282828") : CDColor(nil, @"757575")) forState:UIControlStateNormal];
	[_bookmarkButton setTitleColor:(!phone ? CDColor(nil, @"282828") : CDColor(nil, @"757575")) forState:UIControlStateHighlighted];
	[UIView animateWithDuration:0.2 animations:^{ [UIHelper moveView:_underlineView toX:(phone ? 12 : 72)]; }];
}

-(void) switchAction:(UIButton*)sender
{
	if (sender == _directoryButton && !_bookmarkView.hidden)
	{
		_bookmarkView.hidden = YES;
		_directoryView.hidden = NO;
		[self updateTabButton];
	}
	else if (sender == _bookmarkButton && _bookmarkView.hidden)
	{
		_bookmarkView.hidden = NO;
		_directoryView.hidden = YES;
		[self updateTabButton];
	}
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (tableView == _directoryView)
		return _chapters.count;
	else
		return _bookmarks.count;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == _directoryView)
		return 46;
	else
	{
		NSString* cid = _bookmarks[indexPath.row];
		NSDictionary* info = _bookModel.bookmarkTable[cid];
		NSString* summary = [info objectForKey:@"summary"];
		CGFloat height = [summary sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(296, CGFLOAT_MAX)].height;
		CGFloat ret = height+40+9;
		if (ret < 52) ret = 52;
		return ret;
	}
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (tableView == _directoryView)
	{
		static NSString* cid = @"DirCellID";
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cid];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			CGFloat width = cell.bounds.size.width;
			
			UILabel* label = [UIHelper label:nil tc:CDColor(nil, @"282828") fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(12, 0, 300, 46)];
			label.tag = 1;
			[cell addSubview:label];
			
			[UIHelper addRect:cell color:CDColor(nil, @"d1d1d1") x:10 y:0 w:width-12 h:0.5f resizing:UIViewAutoresizingFlexibleWidth].tag = 2;
			
			UIImageView* iv = [[UIImageView alloc] initWithImage:CDImage(@"reader/locked")];
			iv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
			iv.tag = 3;
			[UIHelper moveView:iv toX:width-15-10 andY:13];
			[cell addSubview:iv];
		}
		XLChapterModel* c = _chapters[indexPath.row];
		((UILabel*)[cell viewWithTag:1]).text = c.chapter_title;
		[cell viewWithTag:2].hidden = (indexPath.row <= 0);
		[cell viewWithTag:3].hidden = c.chapter_readable;
		
		return cell;
	}
	else
	{
		static NSString* cid2 = @"MarkCellID";
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cid2];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cid2];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			CGFloat width = cell.bounds.size.width;
			[UIHelper addLabel:cell t:nil tc:CDColor(nil, @"282828") fs:15 b:NO al:NSTextAlignmentLeft frame:CGRectMake(12, 10, 180, 24)].tag = 1;
			[UIHelper addRect:cell color:CDColor(nil, @"d1d1d1") x:10 y:0 w:width-12 h:0.5f resizing:UIViewAutoresizingFlexibleWidth].tag = 2;
			[UIHelper addLabel:cell t:nil tc:CDColor(nil, @"757575") fs:10 b:NO al:NSTextAlignmentRight frame:CGRectMake(width-10-140, 10, 140, 24)].tag = 3;
			UILabel* label = [UIHelper addLabel:cell t:nil tc:CDColor(nil, @"282828") fs:11 b:NO al:NSTextAlignmentLeft frame:CGRectMake(12, 40, width-24, 40)];
			label.tag = 4;
			label.numberOfLines = 0;
		}
		XLChapterModel* cm = [[XLChapterModel alloc] initWithDictionary:nil];
		cm.chapter_id = _bookmarks[indexPath.row];
		NSUInteger index = [_bookModel.chapters indexOfObject:cm];
		if (index != NSNotFound)
			cm = [_bookModel.chapters objectAtIndex:index];
		
		NSDictionary* info = _bookModel.bookmarkTable[cm.chapter_id];
		((UILabel*)[cell viewWithTag:1]).text = cm.chapter_title;
		[cell viewWithTag:2].hidden = (indexPath.row <= 0);
		((UILabel*)[cell viewWithTag:3]).text = [_formatter stringFromDate:[info objectForKey:@"date"]];
		
		NSString* summary = [info objectForKey:@"summary"];
		UILabel* sLabel = (UILabel*)[cell viewWithTag:4];
		CGFloat height = [summary sizeWithFont:sLabel.font constrainedToSize:CGSizeMake(sLabel.bounds.size.width, CGFLOAT_MAX)].height;
		[UIHelper setView:sLabel toHeight:height];
		sLabel.text = summary;
		
		return cell;
	}
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if (tableView == _directoryView)
	{
		XLChapterModel* c = _chapters[indexPath.row];
		_parent.chapterID = c.chapter_id;
		_parent.chapterLocation = 0;
		[_parent reloadContents];
		[self.cdNavigationController popViewController];
	}
	else
	{
		NSString* cid = _bookmarks[indexPath.row];
		_parent.chapterID = cid;
		_parent.chapterLocation = [_bookModel.bookmarkTable[cid][@"loc"] intValue];
		[_parent reloadContents];
		[self.cdNavigationController popViewController];
	}
}

@end

