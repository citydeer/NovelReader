//
//  SelectorView.m
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-7.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "SelectorView.h"
#import "Theme.h"
#import "UIHelper.h"



@interface SelectorCell : UITableViewCell

@property (readonly) UILabel* label;
@property (readonly) UIImageView* line;

@end



@interface SelectorView () <UITableViewDataSource, UITableViewDelegate>
{
	UITableView* _tableView;
}

@end



@implementation SelectorView


#define BorderWidth 3.0f
#define PopArrowHeight 7.0f

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_bgView = [[UIImageView alloc] initWithFrame:self.bounds];
		_bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:_bgView];
		
		CGRect rect = self.bounds;
		rect.origin.x += BorderWidth;
		rect.origin.y += BorderWidth + PopArrowHeight;
		rect.size.width -= BorderWidth*2;
		rect.size.height -= BorderWidth*2 + PopArrowHeight;
		_tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.scrollsToTop = NO;
		_tableView.delegate = self;
		_tableView.dataSource = self;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.backgroundView = nil;
		_tableView.rowHeight = 44.0f;
		_tableView.showsHorizontalScrollIndicator = NO;
		_tableView.showsVerticalScrollIndicator = YES;
		_tableView.alwaysBounceVertical = YES;
		_tableView.directionalLockEnabled = YES;
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		[self addSubview:_tableView];
	}
	return self;
}

-(void) setItems:(NSArray *)items
{
	_items = items;
	[_tableView reloadData];
	if (_selectedIndex >= 0 && _selectedIndex < _items.count)
		[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

-(void) setSelectedIndex:(NSInteger)selectedIndex
{
	_selectedIndex = selectedIndex;
	if (_selectedIndex >= 0 && _selectedIndex < _items.count)
		[_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
}

-(CGFloat) totalHeight
{
	return _tableView.contentSize.height + BorderWidth * 2 + PopArrowHeight;
}

#define MaskViewTag 34207

-(void) showInView:(UIView*)view
{
	UIView* maskView = [[UIView alloc] initWithFrame:view.bounds];
	maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	maskView.tag = MaskViewTag;
	[view addSubview:maskView];
	UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
	[maskView addGestureRecognizer:tgr];
	
	[view addSubview:self];
	
	[_tableView flashScrollIndicators];
}

-(void) dismiss
{
	UIView* maskView = [self.superview viewWithTag:MaskViewTag];
	[maskView removeFromSuperview];
	[self removeFromSuperview];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString* cellID = @"__Cell__";
	SelectorCell* cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (cell == nil)
	{
		cell = [[SelectorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
		cell.backgroundColor = [UIColor clearColor];
	}
	cell.label.text = [_items objectAtIndex:indexPath.row];
	return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([self.delegate respondsToSelector:@selector(didSelect:index:)])
		[self.delegate didSelect:self index:indexPath.row];
}

@end



@implementation SelectorCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self)
	{
		CGRect rect = self.contentView.bounds;
		_label = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, rect.size.width - 32, rect.size.height)];
		_label.backgroundColor = [UIColor clearColor];
		_label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_label.font = [UIFont systemFontOfSize:14.0f];
		_label.textAlignment = NSTextAlignmentLeft;
		_label.lineBreakMode = NSLineBreakByTruncatingMiddle;
		_label.textColor = CDColor(nil, @"f1f1f1");
		[self.contentView addSubview:_label];
		
		_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
		_line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		_line.image = CDImage(@"report/popline");
		[self.contentView addSubview:_line];
		
		UIView* bgView = [[UIView alloc] initWithFrame:rect];
		bgView.backgroundColor = CDColor(nil, @"973d17");
		self.selectedBackgroundView = bgView;
	}
	return self;
}

@end


