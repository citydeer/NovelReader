//
//  KYPageControl.h
//  Nemo
//
//  Created by zhihui zhao on 13-11-5.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KYPageControllerStyle)
{
	KYPageControllerStyleMiddle = 0,
	KYPageControllerStyleLeft,
	KYPageControllerStyleRight
};

@interface KYPageControl : UIView {
	
    NSInteger _numberOfPages;
	NSInteger _currentPage;
	float _singleWidth;
	float _spaceWidth;
	UIColor* _currentPageColor;
	UIColor* _spaceColor;
	UIColor* _otherPageColor;
	BOOL _hidesForSinglePage;
	
}

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) float singleWidth;
@property (nonatomic, assign) float spaceWidth;
@property (nonatomic, assign) float originOffset;//adapt to KYPageControllerStyleLeft
@property (nonatomic, retain) UIColor* currentPageColor;
@property (nonatomic, retain) UIColor* otherPageColor;
@property (nonatomic, assign) BOOL hidesForSinglePage;
@property (nonatomic, retain) UIImage* curImage;
@property (nonatomic, retain) UIImage* otherImage;
@property (nonatomic, strong) UIImage* bgImage;

- (id)initWithFrame:(CGRect)frame;
- (id)initWithFrame:(CGRect)frame style:(KYPageControllerStyle)style;

@end
