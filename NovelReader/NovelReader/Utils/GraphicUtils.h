//
//  GraphicUtils.h
//
//  Created by Pang Zhenyu on 10-10-13.
//  Copyright 2010 tenfen Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GraphicUtils : NSObject

+(id) createRoundedRectImage:(UIImage *)image;
+(id) createRoundedRectImage:(UIImage*)image size:(CGSize)size;

// 可能有空白，等比
+(UIImage*) imageWithImage:(UIImage*)sourceImage scaledToFitSizeWithSameAspectRatio:(CGSize)targetSize;

// 不会有空白，等比
+(UIImage*) imageWithImage:(UIImage*)sourceImage scaledToFillSizeWithSameAspectRatio:(CGSize)targetSize;

+(UIImage *)rotateImage:(UIImage *)aImage;

// 形如 #RGB, #ARGB, #RRGGBB, #AARRGGBB 这四类的颜色值解析
+(UIColor*) colorWithString:(NSString*)colorStr;

+(UIColor*)oppsiteColor:(UIColor*)color;

+(BOOL)isDarkColor:(UIColor*)color;

+(UIImage*) imageWithColor:(UIColor*)color;
@end

