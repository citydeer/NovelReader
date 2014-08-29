//
//  CDRemoteImageView.m
//  KuyunHD
//
//  Created by Pang Zhenyu on 12-3-6.
//  Copyright (c) 2012年 tenfen Inc. All rights reserved.
//

#import "CDRemoteImageView.h"
#import "AZImageCache.h"


@interface CDRemoteImageView()


@end



@implementation CDRemoteImageView

-(void) dealloc
{
	[self stopLoading];
}

-(UIImageView*) maskView
{
	if (_maskView == nil)
	{
		_maskView = [[UIImageView alloc] initWithFrame:self.bounds];
		_maskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_maskView.userInteractionEnabled = NO;
		[self addSubview:_maskView];
	}
	return _maskView;
}


-(void) setImageURL:(NSString *)imageURL
{
	if (![imageURL isEqualToString:_imageURL])
	{
		_imageURL = imageURL;
	}
	if (![imageURL isEqualToString:self.currentImageURL])
	{
		if (_imageGetter != nil && ![_imageGetter.imageId isEqualToString:imageURL])
			[self stopLoading];
		self.image = self.placeholderImage;
		self.currentImageURL = nil;
		if (self.showMaskViewAfterLoaded)
		{
			self.maskView.hidden = YES;
		}
		else
		{
			self.maskView.hidden = NO;
		}
	}
	if (self.window != nil)
		[self checkNeedsLoad];
}

-(void) setPlaceholderImage:(UIImage *)placeholderImage
{
	_placeholderImage = placeholderImage;
	
	if (![self.imageURL isEqualToString:self.currentImageURL])
	{
		self.image = self.placeholderImage;
	}
}

-(void) setPlaceHolderContetMode:(UIViewContentMode)placeHolderContetMode
{
	_placeHolderContetMode = placeHolderContetMode;
	if (![self.imageURL isEqualToString:self.currentImageURL])
	{
		self.contentMode = placeHolderContetMode;
	}
}

-(void) checkNeedsLoad
{
	if ([self.currentImageURL isEqualToString:self.imageURL])
		return;
	
	if (_imageGetter != nil && [_imageGetter.imageId isEqualToString:self.imageURL])
		return;
	self.contentMode = self.placeHolderContetMode;
	[self stopLoading];
	
	if (self.imageURL.length > 0)
	{
		//和 CDImageGetter 中的cacheKey保持一致
		NSString* cacheKey = self.imageURL;
		UIImage* image = [[AZImageCache sharedImageCache] cacheImageForKey:cacheKey];
		if (image != nil)
		{
			if (_showMaskViewAfterLoaded)
				self.maskView.hidden = NO;
			self.currentImageURL = self.imageURL;
			self.image = image;
			self.contentMode = self.imageContentMode;
			self.imageSize = image.size;
			if ([_delegate respondsToSelector:@selector(didFinishLoading:)])
				[_delegate didFinishLoading:self];
		}
		else
		{
			_imageGetter = [[CDImageGetter alloc] init];
			_imageGetter.delegate = self;
			_imageGetter.getterObserver = self;
			_imageGetter.imageId = self.imageURL;
			_imageGetter.referUrl = self.referURL;
			_imageGetter.cachePolicy = KYHttpCachePolicyUseIfAvailable;
			[_imageGetter fetch];
		}
	}
}

-(void) stopLoading
{
	if (_imageGetter != nil)
	{
		_imageGetter.delegate = nil;
		_imageGetter.getterObserver = nil;
		[_imageGetter stopFetching];
		_imageGetter = nil;
	}
}

-(void) didFinishFetch:(id<Getter>)getter
{
	if (_imageGetter == getter)
	{
		_imageGetter = nil;
		
		CDImageGetter* ig = (CDImageGetter*)getter;
		if (ig.resultCode == KYResultCodeSuccess && [ig.imageId isEqualToString:self.imageURL])
		{
			if (_showMaskViewAfterLoaded)
			{
				self.maskView.hidden = NO;
			}
			self.currentImageURL = ig.imageId;
			self.image = ig.image;
			self.contentMode = self.imageContentMode;
			self.imageSize = ig.image.size;
		}
		else if (ig.resultCode != KYResultCodeSuccess && _failHolderImage != nil)
		{
			self.image = _failHolderImage;
			self.contentMode = _failHolderContentMode;
		}
		if ([_delegate respondsToSelector:@selector(didFinishLoading:)])
			[_delegate didFinishLoading:self];
	}
}

-(void) didReceivedData:(HttpGetter *)getter
{
	if (_imageGetter == getter)
	{
		if ([_delegate respondsToSelector:@selector(didReceiveResponse:)])
			[_delegate didReceiveResponse:self];
	}
}

-(void) clearTargets
{
	NSArray* gestures = self.gestureRecognizers;
	for (id gesture in gestures)
		[self removeGestureRecognizer:gesture];
	self.userInteractionEnabled = NO;
}

-(void) setTarget:(id)target action:(SEL)action
{
	[self clearTargets];
	
	UITapGestureRecognizer* tgr = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	[self addGestureRecognizer:tgr];
	self.userInteractionEnabled = YES;
}

-(void) didMoveToWindow
{
	if (self.window == nil)
	{
		[self stopLoading];
	}
	else
	{
		[self checkNeedsLoad];
	}
}

@end
