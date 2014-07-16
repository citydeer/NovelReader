//
//  UIHelper.m
//  KuyunHD
//
//  Created by Pang Zhenyu on 12-3-1.
//  Copyright (c) 2012年 tenfen Inc. All rights reserved.
//

#import "UIHelper.h"

@implementation UIHelper

+(UIButton*) buttonWithTitle:(NSString*)title
				  titleColor:(UIColor*)titleColor
						font:(UIFont*)font
					 bgImage:(UIImage*)bgImage
					   image:(UIImage*)image
					  target:(id)target
					  action:(SEL)action
					   frame:(CGRect)frame
{
	UIButton* button = [[UIButton alloc] initWithFrame:frame];
	if (title)
		[button setTitle:title forState:UIControlStateNormal];
	if (titleColor)
		[button setTitleColor:titleColor forState:UIControlStateNormal];
	if (font)
		button.titleLabel.font = font;
	if (bgImage)
		[button setBackgroundImage:bgImage forState:UIControlStateNormal];
	if (image)
		[button setImage:image forState:UIControlStateNormal];
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	return button;
}

+(UILabel*) labelWithText:(NSString*)text titleColor:(UIColor*)titleColor font:(UIFont*)font alignment:(UITextAlignment)alignment frame:(CGRect)frame
{
	UILabel* label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	if (text)
		label.text = text;
	if (titleColor)
		label.textColor = titleColor;
	if (font)
		label.font = font;
	label.textAlignment = alignment;
	return label;
}

+(UILabel*) label:(NSString*)text tc:(UIColor*)titleColor fs:(CGFloat)fontSize b:(BOOL)bold al:(NSTextAlignment)alignment frame:(CGRect)frame
{
	UILabel* label = [[UILabel alloc] initWithFrame:frame];
	label.backgroundColor = [UIColor clearColor];
	label.text = text;
	if (titleColor)
		label.textColor = titleColor;
	if (bold)
		label.font = [UIFont boldSystemFontOfSize:fontSize];
	else
		label.font = [UIFont systemFontOfSize:fontSize];
	label.textAlignment = alignment;
	return label;
}

+(CGFloat) labelRealWidth:(UILabel*)label
{
	CGSize nowSize = label.bounds.size;
	CGSize size = [label sizeThatFits:nowSize];
	if (size.width > nowSize.width)
		return nowSize.width;
	return size.width;
}

+(void) moveView:(UIView*)view toX:(CGFloat)x andY:(CGFloat)y
{
	CGRect rect = view.frame;
	if (roundf(rect.origin.y) == roundf(y) && roundf(rect.origin.x) == roundf(x))
		return;
	
	rect.origin.x = x;
	rect.origin.y = y;
	view.frame = rect;
}

+(void) moveView:(UIView*)view toX:(CGFloat)x
{
	CGRect rect = view.frame;
	if (roundf(rect.origin.x) != roundf(x))
	{
		rect.origin.x = x;
		view.frame = rect;
	}
}

+(void) moveView:(UIView*)view toY:(CGFloat)y
{
	// Fixed blink in animation.
	CGRect rect = view.frame;
	if (roundf(rect.origin.y) != roundf(y))
	{
		rect.origin.y = y;
		view.frame = rect;
	}
}

+(void) moveView:(UIView*)view dX:(CGFloat)dx dY:(CGFloat)dy
{
	if (dx == 0.0f && dy == 0.0f)
		return;
	
	CGRect rect = view.frame;
	rect.origin.x += dx;
	rect.origin.y += dy;
	view.frame = rect;
}

+(void) setView:(UIView*)view toHeight:(CGFloat)h
{
	CGRect rect = view.frame;
	if (roundf(rect.size.height) != roundf(h))
	{
		rect.size.height = h;
		view.frame = rect;
	}
}

+(void) setView:(UIView*)view toWidth:(CGFloat)w
{
	CGRect rect = view.frame;
	if (roundf(rect.size.width) != roundf(w))
	{
		rect.size.width = w;
		view.frame = rect;
	}
}

+(void) setView:(UIView*)view toWidth:(CGFloat)w andHeight:(CGFloat)h
{
	CGRect rect = view.frame;
	if (roundf(rect.size.height) == roundf(h) && roundf(rect.size.width) == roundf(w))
		return;
	
	rect.size.width = w;
	rect.size.height = h;
	view.frame = rect;
}

+(CGFloat) heightForSize:(CGSize)size fitWidth:(CGFloat)width maxLimit:(CGFloat)max minLimit:(CGFloat)min
{
	CGFloat ret = 0.0f;
	if (size.width > 0.0f && size.height > 0.0f)
	{
		ret = size.height * width / size.width;
	}
	if (max > 0.0f && ret > max)
		ret = max;
	if (min > 0.0f && ret < min)
		ret = min;
	return ret;
}

+(CGFloat) widthForSize:(CGSize)size fitHeight:(CGFloat)height maxLimit:(CGFloat)max minLimit:(CGFloat)min
{
	CGFloat ret = 0.0f;
	if (size.width > 0.0f && size.height > 0.0f)
	{
		ret = size.width * height / size.height;
	}
	if (max > 0.0f && ret > max)
		ret = max;
	if (min > 0.0f && ret < min)
		ret = min;
	return ret;
}

+(void) shakeView:(UIView*)view scope:(CGFloat)scope
{
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
	animation.duration = 0.05;
	animation.repeatCount = 4;
	animation.autoreverses = YES;
	animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(view.center.x - scope, view.center.y)];
	animation.toValue = [NSValue valueWithCGPoint:CGPointMake(view.center.x + scope, view.center.y)];
	[view.layer addAnimation:animation forKey:@"position"];
}

+ (CGSize)sizeWithString:(NSString *)string maxFontSize:(CGFloat *)fontSize constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;
{
    CGSize extendSize = size;
    extendSize.height = size.height * 2.0;
    CGSize fitSize = CGSizeZero;
	
	UIFont *font = [UIFont systemFontOfSize:*fontSize];
	fitSize = [string sizeWithFont:font minFontSize:0.0 actualFontSize:fontSize forWidth:size.width lineBreakMode:lineBreakMode];
//	fitSize = [string sizeWithFont:font constrainedToSize:extendSize lineBreakMode:lineBreakMode];
//	while (fitSize.height > size.height) 
//	{
//		(*fontSize) -= 1.0;
//		font = [UIFont systemFontOfSize:*fontSize];
//        fitSize = [string sizeWithFont:font constrainedToSize:extendSize lineBreakMode:lineBreakMode];
//	}
//    do {
//        UIFont *font = [UIFont systemFontOfSize:*fontSize];
//        fitSize = [string sizeWithFont:font constrainedToSize:extendSize lineBreakMode:lineBreakMode];
//        (*fontSize) -= 1.0;
//    } while (fitSize.height > size.height);
    return fitSize;
}

+ (UIImage *)screenShotFromView:(UIView *)view
{
	CGSize screenShotSize = view.bounds.size;
	if (UIGraphicsBeginImageContextWithOptions != NULL)
		UIGraphicsBeginImageContextWithOptions(screenShotSize, NO, [UIScreen mainScreen].scale);
	else
		UIGraphicsBeginImageContext(screenShotSize);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[[view layer] renderInContext:context];
	UIImage *screenShot = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return screenShot;
}

@end

