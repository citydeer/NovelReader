//
//  CDCustomViews.m
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-29.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//

#import "CDCustomViews.h"



@implementation CDCustomTextField

-(void) drawPlaceholderInRect:(CGRect)rect
{
	[self.placeHolderColor setFill];
	UIFont* fnt = ((_placeHolderFont ? _placeHolderFont : self.font));
	CGFloat height = [self.placeholder sizeWithFont:fnt].height;
	[self.placeholder drawAtPoint:CGPointMake(rect.origin.x, rect.origin.y+(rect.size.height-height)*0.5) withFont:fnt];
}

@end

