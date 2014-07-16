//
//  UIHelper.h
//  KuyunHD
//
//  Created by Pang Zhenyu on 12-3-1.
//  Copyright (c) 2012年 tenfen Inc. All rights reserved.
//


@interface UIHelper : NSObject

+(UIButton*) buttonWithTitle:(NSString*)title
				  titleColor:(UIColor*)titleColor
						font:(UIFont*)font
					 bgImage:(UIImage*)bgImage
					   image:(UIImage*)image
					  target:(id)target
					  action:(SEL)action
					   frame:(CGRect)frame;

+(UILabel*) labelWithText:(NSString*)text titleColor:(UIColor*)titleColor font:(UIFont*)font alignment:(UITextAlignment)alignment frame:(CGRect)frame;
+(UILabel*) label:(NSString*)text tc:(UIColor*)titleColor fs:(CGFloat)fontSize b:(BOOL)bold al:(NSTextAlignment)alignment frame:(CGRect)frame;

+(CGFloat) labelRealWidth:(UILabel*)label;

+(void) moveView:(UIView*)view toX:(CGFloat)x andY:(CGFloat)y;
+(void) moveView:(UIView*)view toX:(CGFloat)x;
+(void) moveView:(UIView*)view toY:(CGFloat)y;
+(void) moveView:(UIView*)view dX:(CGFloat)dx dY:(CGFloat)dy;

+(void) setView:(UIView*)view toHeight:(CGFloat)h;
+(void) setView:(UIView*)view toWidth:(CGFloat)w;
+(void) setView:(UIView*)view toWidth:(CGFloat)w andHeight:(CGFloat)h;

+(CGFloat) heightForSize:(CGSize)size fitWidth:(CGFloat)width maxLimit:(CGFloat)max minLimit:(CGFloat)min;
+(CGFloat) widthForSize:(CGSize)size fitHeight:(CGFloat)height maxLimit:(CGFloat)max minLimit:(CGFloat)min;;

// 摇晃一个UIView。scope:振幅
+(void) shakeView:(UIView*)view scope:(CGFloat)scope;

//
+ (CGSize)sizeWithString:(NSString *)string maxFontSize:(CGFloat *)fontSize constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

//screen shots
+ (UIImage *)screenShotFromView:(UIView *)view;

@end

