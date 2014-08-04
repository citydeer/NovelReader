//
//  ReaderLayoutInfo.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-3.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//



@interface TextRenderContext : NSObject <NSCoding>

@property (nonatomic, assign) CGFloat ParagraphOffset;		//段落缩进
@property (nonatomic, assign) CGFloat ParagraphSpace;		//段间距
@property (nonatomic, assign) CGFloat TextLineHeight;		//行高度
@property (nonatomic, assign) CGFloat TextLineSpace;		//行间距
@property (nonatomic, assign) CGFloat TextMargin;			//文章边距
@property (nonatomic, assign) CGFloat BeginTextTopMargin;	//文章上间距

@property (nonatomic, assign) CGFloat textSize;				//文字字号
@property (nonatomic, copy) NSString* textFontName;			//文字字体

@property (nonatomic, assign) CGSize pageSize;				//页面大小
@property (nonatomic, strong) UIColor* textColor;

+(id) contextWithContext:(TextRenderContext*)context;

@end



@interface ReaderLayoutInfo : NSObject
{
	CFTypeRef _typesetter;
}

@property (nonatomic, copy) NSAttributedString* attributedContent;
@property (nonatomic, copy) NSArray* pages;				// Item: NSArray
@property (nonatomic) CFTypeRef typesetter;

-(id) initWithText:(NSString*)text inContext:(TextRenderContext*)context;

-(NSInteger) findIndexForLocation:(CFIndex)location inRange:(NSRange)range;

+(NSLock*) getLock;

@end


@interface RenderLine : NSObject

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CFRange range;
@property (nonatomic, assign) BOOL justified;
@property (nonatomic, assign) CGFloat width;

@end

