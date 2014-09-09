//
//  BookCell.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-1.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "BookCell.h"
#import "UIHelper.h"
#import "Theme.h"
#import "BookManager.h"



@interface BookCell ()
{
	UILabel* _titleLabel;
	UIImageView* _coverImage;
	UIImageView* _newIcon;
	UIImageView* _previewIcon;
	
	BookModel* _model;
}

@end



@implementation BookCell

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-31)];
		v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		v.backgroundColor = [UIColor whiteColor];
		UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(-4, -1, v.bounds.size.width+8, v.bounds.size.height+8)];
		iv.image = [CDImage(@"shelf/shadow_border") resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 30, 10)];
		[v addSubview:iv];
		[self addSubview:v];
		
		_coverImage = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, frame.size.width-4, frame.size.height-31-4)];
		_coverImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_coverImage.backgroundColor = CDColor(nil, @"c9c9c9");
		_coverImage.contentMode = UIViewContentModeScaleAspectFill;
		_coverImage.clipsToBounds = YES;
		[self addSubview:_coverImage];
		
		_newIcon = [[UIImageView alloc] initWithImage:CDImage(@"shelf/new_icon")];
		[UIHelper moveView:_newIcon toX:frame.size.width-35.5 andY:-1];
		_newIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[self addSubview:_newIcon];
		
		_previewIcon = [[UIImageView alloc] initWithImage:CDImage(@"shelf/preview_icon")];
		[UIHelper moveView:_previewIcon toX:frame.size.width-35.5 andY:-1];
		_previewIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
		[self addSubview:_previewIcon];
		
		_titleLabel = [UIHelper label:nil tc:CDColor(nil, @"282828") fs:12 b:NO al:NSTextAlignmentCenter frame:CGRectMake(0, frame.size.height-24, frame.size.width, 20)];
		_titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
		[self addSubview:_titleLabel];
	}
	return self;
}

+(CGSize) measureModel:(id)model
{
	return CGSizeMake(84, 150);
}

-(void) applyModel:(id)model
{
	_model = model;
	
	_coverImage.image = [UIImage imageWithContentsOfFile:_model.image];
	_newIcon.hidden = !_model.isNew;
	_previewIcon.hidden = !_model.isPreview;
	_titleLabel.text = _model.name;
}

@end

