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
{
	UIImageView* _icon;
}

@property (readonly) UILabel* label;
@property (readonly) UIImageView* icon;
@property (readonly) UIView* line;

@end



@interface SelectorView () <UITableViewDataSource, UITableViewDelegate>
{
	UITableView* _tableView;
}

@end



@implementation SelectorView


#define BorderWidth 7.0f
#define PopArrowHeight 3.0f

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_selectedIndex = -1;
		_cellHeight = 37.0f;
		
		_bgView = [[UIImageView alloc] initWithFrame:self.bounds];
		_bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_bgView.image = [CDImage(@"main/selectorbg") resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 40)];
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
		_tableView.rowHeight = _cellHeight;
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

-(void) setCellHeight:(CGFloat)cellHeight
{
	_cellHeight = cellHeight;
	_tableView.rowHeight = cellHeight;
}

-(CGFloat) totalHeight
{
	return _tableView.contentSize.height + BorderWidth * 2 + PopArrowHeight;
}

-(CGFloat) borderHeight
{
	return BorderWidth*2 + PopArrowHeight;
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
	
	self.alpha = 0.0f;
	[UIView animateWithDuration:0.3 animations:^{ self.alpha = 1.0f; } completion:^(BOOL finished){
		[_tableView flashScrollIndicators];
	}];
}

-(void) dismiss
{
	UIView* maskView = [self.superview viewWithTag:MaskViewTag];
	[UIView animateWithDuration:0.3 animations:^{ self.alpha = 0.0f; } completion:^(BOOL finished){
		[self removeFromSuperview];
		[maskView removeFromSuperview];
	}];
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
	[UIHelper moveView:cell.line toY:_cellHeight-cell.line.frame.size.height];
	cell.line.hidden = (indexPath.row == _items.count-1);
	cell.label.text = [_items objectAtIndex:indexPath.row];
	if (_icons.count > 0 && indexPath.row < _icons.count)
		cell.icon.image = [_icons objectAtIndex:indexPath.row];
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
		_label.font = [UIFont systemFontOfSize:15.0f];
		_label.textAlignment = NSTextAlignmentLeft;
		_label.lineBreakMode = NSLineBreakByTruncatingMiddle;
		_label.textColor = CDColor(nil, @"757575");
		[self.contentView addSubview:_label];
		
//		_line = [[UIImageView alloc] initWithFrame:CGRectMake(0, rect.size.height-1, rect.size.width, 1)];
//		_line.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//		_line.image = CDImage(@"main/selectorline");
//		[self.contentView addSubview:_line];
		
		_line = [UIHelper addRect:self.contentView color:CDColor(nil, @"d1d1d1") x:0 y:0 w:rect.size.width h:0.5f resizing:UIViewAutoresizingFlexibleWidth];
		
		UIView* bgView = [[UIView alloc] initWithFrame:rect];
		bgView.backgroundColor = CDColor(nil, @"ec6400");
		self.selectedBackgroundView = bgView;
	}
	return self;
}

-(UIImageView*) icon
{
	if (_icon == nil)
	{
		CGRect rect = self.contentView.bounds;
		_icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, rect.size.height)];
		_icon.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_icon.contentMode = UIViewContentModeCenter;
		[self.contentView addSubview:_icon];
		_label.frame = CGRectMake(42, 0, rect.size.width-50, rect.size.height);
	}
	return _icon;
}

@end


