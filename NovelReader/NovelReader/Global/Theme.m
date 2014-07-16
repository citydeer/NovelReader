//
//  Theme.m
//  Nemo
//
//  Created by zhihui zhao on 13-9-30.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "Theme.h"
#import "GraphicUtils.h"

@interface Theme ()
{
	NSDictionary* _colorDict;
	NSDictionary* _imageDict;
}

@end


@implementation Theme

+ (Theme *)currentTheme
{
	static Theme* _intance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_intance = [[Theme alloc] init];
	});
	return _intance;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		NSString* sources = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Images/Sources"];
		NSString* themePath = [sources stringByAppendingPathComponent:@"theme.plist"];
		_colorDict = [[NSDictionary alloc] initWithContentsOfFile:themePath];
		
		themePath = [sources stringByAppendingPathComponent:@"image.plist"];
		_imageDict = [[NSDictionary alloc] initWithContentsOfFile:themePath];
	}
	return self;
}

- (UIColor *)colorForKey:(NSString *)key defaultColorString:(NSString *)colorStr
{
	NSString* value = nil;
	if (key.length > 0)
		value = [_colorDict objectForKey:key];
	
	return [GraphicUtils colorWithString:(value.length > 0 ? value:colorStr)];
}

- (UIImage *)imageForName:(NSString *)name
{
	NSString* imageBasePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Images"];

	UIScreen* screen = [UIScreen mainScreen];
	if ([screen respondsToSelector:@selector(scale)] && [screen scale] >= 2.0f)
	{
		UIImage* image = nil;
		if (IS_IPAD)
		{
			NSString* imagePath = [imageBasePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x~ipad.png", name]];
			image = [UIImage imageWithContentsOfFile:imagePath];
		}
		if (image == nil)
		{
			NSString* imagePath = [imageBasePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@@2x.png", name]];
			image = [UIImage imageWithContentsOfFile:imagePath];
		}
		if (image != nil)
			return [UIImage imageWithCGImage:image.CGImage scale:2.0f orientation:image.imageOrientation];
	}
	UIImage* image = nil;
	if (IS_IPAD)
	{
		NSString* imagePath = [imageBasePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@~ipad.png", name]];
		image = [UIImage imageWithContentsOfFile:imagePath];
	}
	if (image == nil)
	{
		NSString* imagePath = [imageBasePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
		image = [UIImage imageWithContentsOfFile:imagePath];
	}
	if (image != nil)
		return image;
	
	return [UIImage imageNamed:[NSString stringWithFormat:@"Images/%@",name]];
}

- (UIImage *)imageForKey:(NSString *)key
{
	if (key.length <= 0)
		return nil;
	return [self imageForName:[_imageDict objectForKey:key]];
}

+(NSString*) onlineSkinPath
{
	return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"Templet"];
}

+(UIImage*) imageWithName:(NSString*)name inPath:(NSString*)path
{
	UIImage* image = nil;
	if (path)
	{
		NSString* imagePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", name]];
		image = [UIImage imageWithContentsOfFile:imagePath];
	}
	if (image != nil)
		return image;
	
	return [UIImage imageNamed:[NSString stringWithFormat:@"%@.png", name]];
}
@end
