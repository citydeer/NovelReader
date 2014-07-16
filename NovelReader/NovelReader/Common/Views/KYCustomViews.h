//
//  KYCustomViews.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-10-7.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//




@interface KYProgressView : UIView
{
	UIColor* _progressColor;
	float _progress;
}

@property (nonatomic, retain) UIColor* progressColor;
@property (nonatomic, assign) float progress;

@end



// Progress bar with another style
@interface KYProgressView2 : UIView
{
	float _progress;
}
@property (nonatomic, retain) UIColor* edgeColor;
@property (nonatomic, retain) UIColor* fillColor;
@property (nonatomic, assign) float progress;

@end



@interface KYScrollIndicator : UIView
{
	UIColor* _progressColor;
	UIColor* _lineColor;
	CGFloat _totalLength;
	CGFloat _screenLength;
	CGFloat _screenOffset;
	CGFloat _minThumbLength;
}

@property (nonatomic, retain) UIColor* progressColor;
@property (nonatomic, assign) CGFloat totalLength;
@property (nonatomic, assign) CGFloat screenLength;
@property (nonatomic, assign) CGFloat screenOffset;
@property (nonatomic, assign) CGFloat minThumbLength;
@property (nonatomic, retain) UIColor* lineColor;

@end



@interface KYChannelSelectedView : UIView {

    UIColor* _viewColor;
}

@property (nonatomic, retain) UIColor* viewColor;

@end



@interface KYFeedImageView : UIImageView
{
	UIImageView* _kuyunIcon;
}

@end



@interface KYFeedImageView1 : UIImageView
{
	UIImageView* _kuyunIcon;
}

@end



@interface KYRateCircleView : UIView
{
@private
    NSInteger _rate;
}

@property (nonatomic, assign) NSInteger rate;

@end

@interface KYUILabel : UILabel {

	CGFloat insetsWidth;
	CGFloat insetsHeight;
    
}
@property (nonatomic,assign) CGFloat insetsWidth;
@property (nonatomic,assign) CGFloat insetsHeight;
@end


@interface PrivacyLockView : UIView 

@end


#define StartWithUnloggedGuide @"StartWithUnloggedGuide"
#define MainViewGuide @"MainViewGuide"
#define ReadViewGuide @"ReadViewGuide"
#define ChannelSubscriptionGuide @"ChannelSubscriptionGuide"
#define SocialViewGuide @"SocialViewGuide"
#define EPGViewGuide @"EPGViewGuide"
@interface KYGuideView : UIImageView 
@property(nonatomic, copy) NSString* name;
@end



@protocol KYSegmentedControlDelegate;

@interface KYSegmentedControl : UIView 
{
@private
	NSInteger _count;
    NSArray* _buttonsArr; 
	
	NSArray* _imageArr;
	NSArray* _selImageArr;
}
@property (nonatomic, assign) NSInteger currentSelectIndex;
@property (nonatomic, weak) id<KYSegmentedControlDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withCount:(NSInteger)count;
- (void)setTitle:(NSString*)title forIndex:(NSInteger)index;
- (void)setImage:(NSArray*)imageArr;
- (void)setSelectedImage:(NSArray*)imageArr;
@end

@protocol KYSegmentedControlDelegate <NSObject>
@optional
- (void)segmentValueChanged:(KYSegmentedControl*)sender;
@end

@interface KYLabFrameView : UIImageView 
{
	BOOL _isPortrait;
	UIImageView* _backImageView;
	UIImageView* _iconImageView;
	UILabel* _title;
	UILabel* _subTitle;
	UILabel* _timeLable;
}
@property (nonatomic, assign) BOOL isPortrait;
@property (readonly) UIImageView* backImageView;
@property (readonly) UIImageView* iconImageView;
@property (readonly) UILabel* title;
@property (readonly) UILabel* subTitle;
@property (readonly) UILabel* timeLable;
- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isPortrait;
@end

@interface KYLabFrameView2 : UIImageView 
{
	BOOL _isPortrait;
	UIImageView* _backImageView;
	UIImageView* _iconImageView;
	UILabel* _topLabel;
	UILabel* _bottomLabel;
	UILabel* _title;
	UILabel* _countLabel;
	UILabel* _descripLabel;
}
@property (readonly) UIImageView* backImageView;
@property (readonly) UIImageView* iconImageView;
@property (readonly) UILabel* topLabel;
@property (readonly) UILabel* bottomLabel;
@property (readonly) UILabel* title;
@property (readonly) UILabel* countLabel;
@property (readonly) UILabel* descripLabel;
@property (nonatomic, assign) BOOL isPortrait;
- (id)initWithFrame:(CGRect)frame orientation:(BOOL)isPortrait;


@end


typedef enum {
    KYProgressCircleViewStyleProgress,
    KYProgressCircleViewStyleColorChange
}KYProgressCircleViewStyle;

@interface KYCircleView : UIView
{
    UIColor *_circleColor;
}

@property (nonatomic, retain) UIColor *circleColor;

- (id)initWithFrame:(CGRect)frame;

@end

@interface KYProgressCircleView : UIView
{
    UIColor *_progressBackgroundColor;
	UIColor *_progressBarColor;    
	float _progress;
    KYProgressCircleViewStyle _style;
@private
    CADisplayLink *_displayLink;
}

@property (nonatomic, retain) UIColor *progressBackgroundColor;
@property (nonatomic, retain) UIColor *progressBarColor;

@property (nonatomic, assign) float progress;

- (id)initWithFrame:(CGRect)frame style:(KYProgressCircleViewStyle)aStyle;
- (void)startAnimating;
- (void)stopAnimating;

@end

@protocol KYRunLabelDelegate <NSObject>
@optional
- (void)runFinished;
@end

@interface KYRunLabel : UIView
{
	UILabel* _label;
	
	BOOL _shouldRun;
	CFTimeInterval _duration;
	
	NSTimeInterval _begin;
}
@property (nonatomic, assign) CGFloat speed;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) BOOL startWithOffset;
@property (nonatomic, assign) NSTimeInterval minTime;
@property (nonatomic, assign) NSTimeInterval finishDelayTime;
@property (nonatomic, assign) NSTimeInterval repeatTime;
@property (nonatomic, assign) UITextAlignment  textAlignment;
@property (nonatomic, copy) NSString* text;
@property (nonatomic, retain) UIFont* font;
@property (nonatomic, retain) UIColor* textColor;
@property (nonatomic, retain) UIColor* shadowColor;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, weak) id<KYRunLabelDelegate> delegate;
- (void)startAnimate;
@end

