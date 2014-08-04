//
//  ReaderLayoutInfo.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "ReaderLayoutInfo.h"
#import "Theme.h"
#import <CoreText/CoreText.h>


@implementation RenderLine
@end


@implementation TextRenderContext

-(id) init
{
	self = [super init];
	if (self)
	{
		self.ParagraphOffset = 30.0f;
		self.ParagraphSpace = 18.0f;
		self.TextLineHeight = 15.0f;
		self.TextLineSpace = 18.0f;
		self.TextMargin = 14.0f;
		self.BeginTextTopMargin = 34.0f;
		
		self.textSize = 15.0f;
		self.textFontName = @"STHeitiSC-Light";
		self.pageSize = [UIScreen mainScreen].bounds.size;
	}
	return self;
}

-(void) applyTextSize:(CGFloat)size
{
	CGFloat space = roundf(size*0.6)+5;
	if (space < 12.0f) space = 12.0f;
	self.ParagraphOffset = size * 2.0f;
	self.ParagraphSpace = space;
	self.TextLineHeight = size;
	self.TextLineSpace = space;
	self.textSize = size;
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self)
	{
		self.ParagraphOffset = [aDecoder decodeFloatForKey:@"1"];
		self.ParagraphSpace = [aDecoder decodeFloatForKey:@"2"];
		self.TextLineHeight = [aDecoder decodeFloatForKey:@"3"];
		self.TextLineSpace = [aDecoder decodeFloatForKey:@"4"];
		self.TextMargin = [aDecoder decodeFloatForKey:@"11"];
		self.BeginTextTopMargin = [aDecoder decodeFloatForKey:@"12"];
		
		self.textSize = [aDecoder decodeFloatForKey:@"13"];
		self.textFontName = [aDecoder decodeObjectForKey:@"15"];
	}
	return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeFloat:self.ParagraphOffset forKey:@"1"];
	[aCoder encodeFloat:self.ParagraphSpace forKey:@"2"];
	[aCoder encodeFloat:self.TextLineHeight forKey:@"3"];
	[aCoder encodeFloat:self.TextLineSpace forKey:@"4"];
	[aCoder encodeFloat:self.TextMargin forKey:@"11"];
	[aCoder encodeFloat:self.BeginTextTopMargin forKey:@"12"];
	
	[aCoder encodeFloat:self.textSize forKey:@"13"];
	[aCoder encodeObject:self.textFontName forKey:@"15"];
}

+(id) contextWithContext:(TextRenderContext*)context
{
	TextRenderContext* c = [[TextRenderContext alloc] init];
	
	c.ParagraphSpace = context.ParagraphSpace;
	c.ParagraphOffset = context.ParagraphOffset;
	c.TextLineHeight = context.TextLineHeight;
	c.TextLineSpace = context.TextLineSpace;
	c.TextMargin = context.TextMargin;
	c.BeginTextTopMargin = context.BeginTextTopMargin;
	
	c.textSize = context.textSize;
	c.textFontName = context.textFontName;
	c.pageSize = context.pageSize;
	c.textColor = context.textColor;
	
	return c;
}

@end



@implementation ReaderLayoutInfo

-(id) initWithText:(NSString*)text inContext:(TextRenderContext*)context
{
	self = [super init];
	
	if (self != nil && text.length > 0 && context != nil)
	{
		[[ReaderLayoutInfo getLock] lock];
		
		/*******************************************************************************
		 *      Process enter character
		 *******************************************************************************/
		
		NSMutableString* targetContent = [NSMutableString stringWithCapacity:text.length];
		NSMutableArray* ranges = [NSMutableArray arrayWithCapacity:0];
		NSUInteger targetLocation = 0, srcLocation = 0;
		NSInteger length = text.length;
		NSCharacterSet* set = [NSCharacterSet newlineCharacterSet];
		NSCharacterSet* blankSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
		
		while (srcLocation < length && [blankSet characterIsMember:[text characterAtIndex:srcLocation]]) srcLocation++;
		NSRange range = [text rangeOfCharacterFromSet:set options:0 range:NSMakeRange(srcLocation, length-srcLocation)];
		while (range.location != NSNotFound)
		{
			NSUInteger realLength = range.location - srcLocation;
			if (realLength > 0)
			{
				[targetContent appendString:[text substringWithRange:NSMakeRange(srcLocation, realLength)]];
				[ranges addObject:[NSValue valueWithRange:NSMakeRange(targetLocation, realLength)]];
				targetLocation += realLength;
				srcLocation += realLength;
			}
			srcLocation++;
			while (srcLocation < length && [blankSet characterIsMember:[text characterAtIndex:srcLocation]]) srcLocation++;
			range = [text rangeOfCharacterFromSet:set options:0 range:NSMakeRange(srcLocation, length-srcLocation)];
		}
		NSUInteger realLength = length - srcLocation;
		if (realLength > 0)
		{
			[targetContent appendString:[text substringWithRange:NSMakeRange(srcLocation, realLength)]];
			[ranges addObject:[NSValue valueWithRange:NSMakeRange(targetLocation, realLength)]];
			targetLocation += realLength;
			srcLocation += realLength;
		}
		
		CFStringRef str = (__bridge CFStringRef)targetContent;
		CFRange fullRange = CFRangeMake(0, CFStringGetLength(str));
		CFMutableAttributedStringRef attr = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
		CFAttributedStringReplaceString(attr, CFRangeMake(0, 0), str);
		
		CTFontRef defaultFont = CTFontCreateWithName((CFStringRef)context.textFontName, context.textSize, NULL);
		CFAttributedStringSetAttribute(attr, fullRange, kCTFontAttributeName, defaultFont);
		UIColor* theColor = context.textColor;
		if (theColor == nil) theColor = CDColor(nil, @"562a16");
		CFAttributedStringSetAttribute(attr, fullRange, kCTForegroundColorAttributeName, theColor.CGColor);
		
		CFRelease(defaultFont);
		
		self.attributedContent = (__bridge NSAttributedString*)attr;
		CFRelease(attr);
		
		
		/*******************************************************************************
		 *      Layout begin
		 *******************************************************************************/
		
		CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedContent);
		
		NSMutableArray* pages = [NSMutableArray array];
		NSMutableArray* lines = [NSMutableArray array];
		
		CGFloat currentWidth = context.pageSize.width - 2 * context.TextMargin;
		CGFloat lineHeight = context.TextLineHeight;
		CGFloat lineSpace = context.TextLineSpace;
		
		CGFloat height = context.BeginTextTopMargin;
		
		for (NSUInteger i = 0; i < ranges.count; ++i)
		{
			NSRange lineRange = [[ranges objectAtIndex:i] rangeValue];
			
			CGFloat offset = context.ParagraphOffset;
			if (lines.count > 0)
			{
				height += context.ParagraphSpace;
				if (height + lineHeight > context.pageSize.height)
				{
					height = context.BeginTextTopMargin;
					[pages addObject:[NSArray arrayWithArray:lines]];
					[lines removeAllObjects];
				}
			}
			
			CFIndex currentIndex = lineRange.location, currentLength = 0;
			while (currentLength < lineRange.length)
			{
				if (currentLength > 0 && lines.count > 0)
				{
					height += lineSpace;
					if (height + lineHeight > context.pageSize.height)
					{
						height = context.BeginTextTopMargin;
						[pages addObject:[NSArray arrayWithArray:lines]];
						[lines removeAllObjects];
					}
				}
				
				CFIndex length = CTTypesetterSuggestLineBreak(typesetter, currentIndex, currentWidth - offset);
				BOOL shouldAdjust = YES;
				if (length + currentLength >= lineRange.length)
				{
					length = lineRange.length - currentLength;
					shouldAdjust = NO;
				}
				
				RenderLine* line = [[RenderLine alloc] init];
				line.range = CFRangeMake(currentIndex, length);
				line.origin = CGPointMake(context.TextMargin + offset, height);
				line.justified = shouldAdjust;
				line.width = currentWidth - offset;
				[lines addObject:line];
				
				if (offset > 0.0) offset = 0;
				height += lineHeight;
				currentIndex += length;
				currentLength += length;
			}
		}
		
		self.typesetter = typesetter;
		CFRelease(typesetter);
		
		self.pages = pages;
		
		[[ReaderLayoutInfo getLock] unlock];
		
		/*******************************************************************************
		 *      Layout end
		 *******************************************************************************/
	}
	
	return self;
}

-(void) setTypesetter:(CFTypeRef)typesetter
{
	if (_typesetter != typesetter)
	{
		if (typesetter)
			CFRetain(typesetter);
		if (_typesetter)
			CFRelease(_typesetter);
		_typesetter = typesetter;
	}
}

-(NSInteger) findIndexForLocation:(CFIndex)location inRange:(NSRange)range
{
	NSUInteger i = range.location;
	for (; i < range.location + range.length; ++i)
	{
		RenderLine* fl = ((NSArray*)[_pages objectAtIndex:i]).firstObject;
		RenderLine* ll = ((NSArray*)[_pages objectAtIndex:i]).lastObject;
		if (location >= fl.range.location && location < ll.range.location + ll.range.length)
			break;
	}
	return i < range.location + range.length ? i : -1;
}

+(NSLock*) getLock
{
	static NSLock* _coreTextLock = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_coreTextLock = [[NSLock alloc] init];
	});
	return _coreTextLock;
}

@end


