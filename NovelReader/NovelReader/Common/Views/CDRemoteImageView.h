//
//  CDRemoteImageView.h
//  KuyunHD
//
//  Created by Pang Zhenyu on 12-3-6.
//  Copyright (c) 2012年 tenfen Inc. All rights reserved.
//

#import "CDImageGetter.h"


@class CDRemoteImageView;

@protocol CDRemoteImageViewDelegate <NSObject>

@optional
-(void) didReceiveResponse:(CDRemoteImageView*)imageView;
-(void) didFinishLoading:(CDRemoteImageView*)imageView;

@end


@interface CDRemoteImageView : UIImageView <GetterDelegate, HttpGetterObserver>
{	
	CDImageGetter* _imageGetter;
	
	UIImageView* _maskView;
}

@property (nonatomic, weak) id<CDRemoteImageViewDelegate> delegate;

// 希望加载的图片的URL
@property (nonatomic, copy) NSString* imageURL;

// 请求时的Refer头，详情请查http协议相关资料
@property (nonatomic, copy) NSString* referURL;

// 当前显示的图片的URL
@property (nonatomic, copy) NSString* currentImageURL;

// 图片大小
@property (nonatomic, assign) CGSize imageSize;

// 覆盖在图片上的View，通常用于给图片加一些修饰
@property (nonatomic, readonly) UIImageView* maskView;

// 在加载过程中，显示的图片
@property (nonatomic, strong) UIImage* placeholderImage;

// 是否在加载完成后显示maskView
@property (nonatomic, assign) BOOL showMaskViewAfterLoaded;

// 加载过程中显示的图片的ContentMode
@property (nonatomic, assign) UIViewContentMode placeHolderContetMode;

// 加载完之后的图片的ContentMode
@property (nonatomic, assign) UIViewContentMode imageContentMode;

@property (nonatomic, assign) UIViewContentMode failHolderContentMode;
@property (nonatomic, strong) UIImage* failHolderImage;

-(void) checkNeedsLoad;
-(void) stopLoading;
-(void) clearTargets;
-(void) setTarget:(id)target action:(SEL)action;

@end

@interface UIImage (Scale)

-(UIImage*)scaleToSize:(CGSize)size;

@end


