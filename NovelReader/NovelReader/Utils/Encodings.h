//
//  Encodings.h
//
//  Created by Pang Zhenyu on 09-4-15.
//  Copyright 2009 tenfen Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum _DATE_FORMAT_TYPE
{
	DateFormatMDHM = 0,	// 格式形如: 06-17 15:07
	DateFormatYMDHMS,	// 格式形如: 2009-06-17 15:07:49
	DateFormatYMD,		// 格式形如: 2009-06-17
	DateFormatYMDHM,	// 格式形如: 2009-06-17 15:07
}
DateFormat;


@interface NSString(NSStringEx)

-(NSString*) urlEncode:(NSStringEncoding)stringEncoding;

-(NSString*) md5;

-(NSString*) sha1;

// AzDG加密
-(NSString*) AzDGCrypt:(NSString*)key;

-(NSDate*) dateFromString:(DateFormat)format;

// 返回“两天前”，“一年前”， “三小时前”等描述相对时间的字符串
-(NSString*) relativeDateFromString:(DateFormat)format;

@end


@interface NSData(NSDataEx)

// MD5
-(NSString*) md5;

// 转为base64编码
-(NSString*) base64Encode;

// 转为base64编码并再urlencoding
-(NSString*) base64EncodeAndURLEncoding;

@end


@interface NSDate(Encodings)

// 返回“两天前”，“一年前”， “三小时前”等描述相对时间的字符串
-(NSString*) stringOfRelativeDate;

// 返回“昨天 23:12”，"今天 07:03"，"09月21日"等三天之内的具体时间或者三天之外的日期
-(NSString*) stringOfNewsDate;

-(NSString*) stringOfHMDate;
@end


@interface NSURL (Params)
- (NSDictionary*)paramsDictionaryUsingEncoding:(NSStringEncoding)encoding;

@end
