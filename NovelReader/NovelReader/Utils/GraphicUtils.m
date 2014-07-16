//
//  GraphicUtils.m
//
//  Created by Pang Zhenyu on 10-10-13.
//  Copyright 2010 tenfen Inc. All rights reserved.
//

#import "GraphicUtils.h"


@implementation GraphicUtils

static CGContextRef MyCreateBitmapContext(int pixelsWide, int pixelsHigh)
{
	CGContextRef context = NULL;
	CGColorSpaceRef colorSpace;
//	void* bitmapData;
	int bitmapByteCount;
	int bitmapBytesPerRow;
	
	bitmapBytesPerRow = (pixelsWide * 4);
	bitmapByteCount	= (bitmapBytesPerRow * pixelsHigh);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
//	bitmapData = malloc( bitmapByteCount);
//	if (bitmapData == NULL)
//	{
//		CGColorSpaceRelease(colorSpace);
//		return NULL;
//	}
	context = CGBitmapContextCreate (NULL,
									 pixelsWide,
									 pixelsHigh,
									 8,
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
	
	CGColorSpaceRelease(colorSpace);
//	free(bitmapData);
	
	return context;
}

static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight)
{
	float fw, fh;
	if (ovalWidth == 0 || ovalHeight == 0)
	{
		CGContextAddRect(context, rect);
		return;
	}
	
	CGContextSaveGState(context);
	CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
	CGContextScaleCTM(context, ovalWidth, ovalHeight);
	fw = CGRectGetWidth(rect) / ovalWidth;
	fh = CGRectGetHeight(rect) / ovalHeight;
	
	CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
	CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
	CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
	CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
	CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
	
	CGContextClosePath(context);
	CGContextRestoreGState(context);
}

+(id) createRoundedRectImage:(UIImage*)image size:(CGSize)size
{
	// the size of CGContextRef
	int w = size.width;
	int h = size.height;
	
	UIImage *img = image;
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
	CGRect rect = CGRectMake(0, 0, w, h);
	
	CGContextBeginPath(context);
	addRoundedRectToPath(context, rect, 10, 10);
	CGContextClosePath(context);
	CGContextClip(context);
	CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
	CGImageRef imageMasked = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	UIImage* ret = [UIImage imageWithCGImage:imageMasked];
	CGImageRelease(imageMasked);
	return ret;
}

+(id) createRoundedRectImage:(UIImage *)image
{
	return [self createRoundedRectImage:image size:image.size];
}

#define radians(degrees) (degrees * M_PI / 180)

+(UIImage*) imageWithImage:(UIImage*)sourceImage scaledToFillSizeWithSameAspectRatio:(CGSize)targetSize;
{
	CGSize imageSize = sourceImage.size;
	CGSize scaleSize = imageSize;
	if (targetSize.width < imageSize.width && targetSize.height < imageSize.height)
	{
		CGFloat widthFactor = targetSize.width / imageSize.width;
		CGFloat heightFactor = targetSize.height / imageSize.height;
		CGFloat scaleFactor = (widthFactor > heightFactor) ? widthFactor : heightFactor;
		
		scaleSize = CGSizeMake(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
	}
	CGPoint drawPoint = CGPointMake((targetSize.width - scaleSize.width)/2, (targetSize.height - scaleSize.height)/2);
	
	if (sourceImage.imageOrientation == UIImageOrientationLeft || sourceImage.imageOrientation == UIImageOrientationRight)
	{
		scaleSize = CGSizeMake(scaleSize.height, scaleSize.width);
		drawPoint = CGPointMake(drawPoint.y, drawPoint.x);
	}
	
	CGContextRef bitmap;
	if (sourceImage.imageOrientation == UIImageOrientationLeft || sourceImage.imageOrientation == UIImageOrientationRight)
	{
		bitmap = MyCreateBitmapContext(scaleSize.height, scaleSize.width);
	}
	else
	{
		bitmap = MyCreateBitmapContext(scaleSize.width, scaleSize.height);
	}
	
	if (sourceImage.imageOrientation == UIImageOrientationLeft)
	{
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -scaleSize.height);
	}
	else if (sourceImage.imageOrientation == UIImageOrientationRight)
	{
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -scaleSize.width, 0);
	}
	else if (sourceImage.imageOrientation == UIImageOrientationUp)
	{
		// NOTHING
	}
	else if (sourceImage.imageOrientation == UIImageOrientationDown)
	{
		CGContextTranslateCTM (bitmap, scaleSize.width, scaleSize.height);
		CGContextRotateCTM (bitmap, radians(-180.));
	}
	
	CGContextDrawImage(bitmap, CGRectMake(drawPoint.x, drawPoint.y, scaleSize.width, scaleSize.height), [sourceImage CGImage]);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return newImage;
	
//	CGFloat targetWidth = targetSize.width;
//	CGFloat targetHeight = targetSize.height;
//	
//	CGImageRef imageRef = [sourceImage CGImage];
//	CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
//	CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
//	
//	if (bitmapInfo == kCGImageAlphaNone)
//	{
//		bitmapInfo = kCGImageAlphaNoneSkipLast;
//	}
//	
//	CGContextRef bitmap;
//	
//	if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown)
//	{
//		bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
//	}
//	else
//	{
//		bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
//	}
//	
//	if (sourceImage.imageOrientation == UIImageOrientationLeft)
//	{
//		CGContextRotateCTM (bitmap, radians(90));
//		CGContextTranslateCTM (bitmap, 0, -targetHeight);
//	}
//	else if (sourceImage.imageOrientation == UIImageOrientationRight)
//	{
//		CGContextRotateCTM (bitmap, radians(-90));
//		CGContextTranslateCTM (bitmap, -targetWidth, 0);
//	}
//	else if (sourceImage.imageOrientation == UIImageOrientationUp)
//	{
//		// NOTHING
//	}
//	else if (sourceImage.imageOrientation == UIImageOrientationDown)
//	{
//		CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
//		CGContextRotateCTM (bitmap, radians(-180.));
//	}
//	
//	CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
//	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
//	UIImage* newImage = [UIImage imageWithCGImage:ref];
//	
//	CGContextRelease(bitmap);
//	CGImageRelease(ref);
//	
//	return newImage;
}

+(UIImage*) imageWithImage:(UIImage*)sourceImage scaledToFitSizeWithSameAspectRatio:(CGSize)targetSize
{
	CGSize imageSize = sourceImage.size;
	CGSize scaleSize = imageSize;
	if (targetSize.width < imageSize.width || targetSize.height < imageSize.height)
	{
		CGFloat widthFactor = targetSize.width / imageSize.width;
		CGFloat heightFactor = targetSize.height / imageSize.height;
		CGFloat scaleFactor = (widthFactor < heightFactor) ? widthFactor : heightFactor;
		
		scaleSize = CGSizeMake(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
	}
	
	if (sourceImage.imageOrientation == UIImageOrientationLeft || sourceImage.imageOrientation == UIImageOrientationRight)
	{
		scaleSize = CGSizeMake(scaleSize.height, scaleSize.width);
	}
	
	CGContextRef bitmap;
	if (sourceImage.imageOrientation == UIImageOrientationLeft || sourceImage.imageOrientation == UIImageOrientationRight)
	{
		bitmap = MyCreateBitmapContext(scaleSize.height, scaleSize.width);
	}
	else
	{
		bitmap = MyCreateBitmapContext(scaleSize.width, scaleSize.height);
	}
	
	if (sourceImage.imageOrientation == UIImageOrientationLeft)
	{
		CGContextRotateCTM (bitmap, radians(90));
		CGContextTranslateCTM (bitmap, 0, -scaleSize.height);
	}
	else if (sourceImage.imageOrientation == UIImageOrientationRight)
	{
		CGContextRotateCTM (bitmap, radians(-90));
		CGContextTranslateCTM (bitmap, -scaleSize.width, 0);
	}
	else if (sourceImage.imageOrientation == UIImageOrientationUp)
	{
		// NOTHING
	}
	else if (sourceImage.imageOrientation == UIImageOrientationDown)
	{
		CGContextTranslateCTM (bitmap, scaleSize.width, scaleSize.height);
		CGContextRotateCTM (bitmap, radians(-180.));
	}
	
	CGContextDrawImage(bitmap, CGRectMake(0, 0, scaleSize.width, scaleSize.height), [sourceImage CGImage]);
	
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
	UIImage* newImage = [UIImage imageWithCGImage:ref];
	
	CGContextRelease(bitmap);
	CGImageRelease(ref);
	
	return newImage;
}


+(UIImage *)rotateImage:(UIImage *)aImage
{
	CGImageRef imgRef = aImage.CGImage;
	CGFloat width = CGImageGetWidth(imgRef);
	CGFloat height = CGImageGetHeight(imgRef);
	CGAffineTransform transform = CGAffineTransformIdentity;
	CGRect bounds = CGRectMake(0, 0, width, height);
	CGFloat scaleRatio = 1;
	CGFloat boundHeight;
	UIImageOrientation orient = aImage.imageOrientation;
	switch(orient)
	{
		case UIImageOrientationUp: //EXIF = 1
			transform = CGAffineTransformIdentity;
			break;
		case UIImageOrientationUpMirrored: //EXIF = 2
			transform = CGAffineTransformMakeTranslation(width, 0.0);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			break;
		case UIImageOrientationDown: //EXIF = 3
			transform = CGAffineTransformMakeTranslation(width, height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
		case UIImageOrientationDownMirrored: //EXIF = 4
			transform = CGAffineTransformMakeTranslation(0.0, height);
			transform = CGAffineTransformScale(transform, 1.0, -1.0);
			break;
		case UIImageOrientationLeftMirrored: //EXIF = 5
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(height, width);
			transform = CGAffineTransformScale(transform, -1.0, 1.0);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationLeft: //EXIF = 6
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(0.0, width);
			transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
			break;
		case UIImageOrientationRightMirrored: //EXIF = 7
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeScale(-1.0, 1.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		case UIImageOrientationRight: //EXIF = 8
			boundHeight = bounds.size.height;
			bounds.size.height = bounds.size.width;
			bounds.size.width = boundHeight;
			transform = CGAffineTransformMakeTranslation(height, 0.0);
			transform = CGAffineTransformRotate(transform, M_PI / 2.0);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
	}
	UIGraphicsBeginImageContext(bounds.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
		CGContextScaleCTM(context, -scaleRatio, scaleRatio);
		CGContextTranslateCTM(context, -height, 0);
	}
	else {
		CGContextScaleCTM(context, scaleRatio, -scaleRatio);
		CGContextTranslateCTM(context, 0, -height);
	}
	CGContextConcatCTM(context, transform);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
	UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return imageCopy;
}



+(CGFloat) colorComponentFrom:(NSString*)string start:(NSUInteger)start length:(NSUInteger)length
{
	NSString* substring = [string substringWithRange: NSMakeRange(start, length)];
	NSString* fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
	unsigned hexComponent;
	[[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
	return hexComponent / 255.0;
}

// 形如 #RGB, #ARGB, #RRGGBB, #AARRGGBB 这四类的颜色值解析
+(UIColor*) colorWithString:(NSString*)colorStr
{
	if (colorStr.length <= 0)
		return nil;
	
	NSString* colorString = [[colorStr stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
	CGFloat alpha, red, blue, green;
	switch ([colorString length])
	{
		case 3: // #RGB
			alpha = 1.0f;
			red   = [self colorComponentFrom: colorString start: 0 length: 1];
			green = [self colorComponentFrom: colorString start: 1 length: 1];
			blue  = [self colorComponentFrom: colorString start: 2 length: 1];
			break;
		case 4: // #ARGB
			alpha = [self colorComponentFrom: colorString start: 0 length: 1];
			red   = [self colorComponentFrom: colorString start: 1 length: 1];
			green = [self colorComponentFrom: colorString start: 2 length: 1];
			blue  = [self colorComponentFrom: colorString start: 3 length: 1];		  
			break;
		case 6: // #RRGGBB
			alpha = 1.0f;
			red   = [self colorComponentFrom: colorString start: 0 length: 2];
			green = [self colorComponentFrom: colorString start: 2 length: 2];
			blue  = [self colorComponentFrom: colorString start: 4 length: 2];					  
			break;
		case 8: // #AARRGGBB
			alpha = [self colorComponentFrom: colorString start: 0 length: 2];
			red   = [self colorComponentFrom: colorString start: 2 length: 2];
			green = [self colorComponentFrom: colorString start: 4 length: 2];
			blue  = [self colorComponentFrom: colorString start: 6 length: 2];					  
			break;
		default:
			return nil;
	}
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+(UIColor *)oppsiteColor:(UIColor *)color
{
	CGFloat red = 0.0f;
	CGFloat green = 0.0f;
	CGFloat blue = 0.0f;
	CGFloat alpha = 0.0f;
	CGColorRef colorRef = [color CGColor];
    int numComponents = CGColorGetNumberOfComponents(colorRef);
    
    if (numComponents >= 3)
    {
        const CGFloat *tmComponents = CGColorGetComponents(colorRef);
		red = tmComponents[0];
		green = tmComponents[1];
		blue = tmComponents[2];
        alpha = tmComponents[3];
	}
//	[color getRed:&red green:&green blue:&blue alpha:nil];
	CGFloat grayLevel = red * 0.299 + green * 0.587 + blue * 0.114;
	if (grayLevel >= 192/255.0) 
	{
		return [UIColor blackColor];
	}
	return [UIColor whiteColor];
}

+(BOOL)isDarkColor:(UIColor *)color
{
	CGFloat red = 0.0f;
	CGFloat green = 0.0f;
	CGFloat blue = 0.0f;
	CGFloat alpha = 0.0f;
	CGColorRef colorRef = [color CGColor];
    int numComponents = CGColorGetNumberOfComponents(colorRef);
    
    if (numComponents >= 3)
    {
        const CGFloat *tmComponents = CGColorGetComponents(colorRef);
		red = tmComponents[0];
		green = tmComponents[1];
		blue = tmComponents[2];
        alpha = tmComponents[3];
	}
	
	CGFloat grayLevel = red * 0.299 + green * 0.587 + blue * 0.114;
	
	if (grayLevel >= 192/255.0) 
	{
		return NO;
	}
	return YES;

}

+(UIImage*) imageWithColor:(UIColor*)color
{
	CGRect rect = CGRectMake(0, 0, 1.0f, 1.0f);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, rect);
	__autoreleasing UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return image;
}
@end

