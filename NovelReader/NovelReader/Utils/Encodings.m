//
//  Encodings.m
//
//  Created by Pang Zhenyu on 09-4-15.
//  Copyright 2009 tenfen Inc. All rights reserved.
//

#import "Encodings.h"
#import <CommonCrypto/CommonDigest.h>
//#import "des_encrypt.h"


@implementation NSString(NSStringEx)


- (NSString*) urlEncode:(NSStringEncoding)stringEncoding
{
	
	NSArray *escapeChars = [NSArray arrayWithObjects:@";", @"/", @"?", @":", /*@".",*/
							@"@", @"&", @"=", @"+", @"$", @",", @"!",
							@"'", @"(", @")", /*@"*", @"-",*/ @"~",
							nil];
	
	NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B", @"%2F", @"%3F", @"%3A", /*@"2E",*/
							 @"%40", @"%26", @"%3D", @"%2B", @"%24", @"%2C", @"%21",
							@"%27", @"%28", @"%29", /*@"%2A", @"%2D",*/ @"%7E",
							 nil];
	
	int len = [escapeChars count];
	
	NSString *tempStr = [self stringByAddingPercentEscapesUsingEncoding:stringEncoding];
	
	if (tempStr == nil) {
		return nil;
	}
	
	NSMutableString *temp = [tempStr mutableCopy];	
	
	int i;
	for (i = 0; i < len; i++) {
		
		[temp replaceOccurrencesOfString:[escapeChars objectAtIndex:i]
							  withString:[replaceChars objectAtIndex:i]
								 options:NSLiteralSearch
								   range:NSMakeRange(0, [temp length])];
	}
	
	NSString *outStr = [NSString stringWithString: temp];
		
	return outStr;
}

- (NSString*) md5
{
	const char *cStr = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			 ] uppercaseString];
}

-(NSString*) sha1
{
	const char* str = [self UTF8String];
	unsigned char result[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(str, strlen(str), result);
	return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15],
			 result[16], result[17], result[18], result[19]
			 ] uppercaseString];
}


// AzDG加密
- (NSString*) AzDGCrypt:(NSString*)key
{
	if (self == nil || key == nil)
		return nil;
	
	// 先找个随机数对原串加密
	int rand = ((int)[NSDate timeIntervalSinceReferenceDate]) % 3200;
	NSString* encryptKey = [[NSString stringWithFormat:@"%d", rand] md5];
	
	const char* pRandomKey = [encryptKey UTF8String];
	int rKeyLength = strlen(pRandomKey);
	
	const char* pStr = [self UTF8String];
	int dataLength = strlen(pStr);
	
	//NSMutableData* buf = [[NSMutableData alloc] initWithCapacity:2*dataLength];
	
	char* buf = malloc(2*dataLength);
	
	for (int i=0; i<dataLength; ++i)
	{
		char tmp1 = pRandomKey[i % rKeyLength];
		char tmp2 = (char) (pStr[i] ^ tmp1);
		buf[i*2] = tmp1;
		buf[i*2+1] = tmp2;
//		[buf appendBytes:(void*)&tmp1 length:1];
//		[buf appendBytes:(void*)&tmp2 length:1];
	}
	
	// 然后再用密钥key对一次加密后的串加密
//	NSString* text = [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] autorelease];
	
//	[buf release];
	
	const char* pEncryptKey = [[key md5] UTF8String];
	int eKeyLength = strlen(pEncryptKey);
	
//	const char* pText = [text UTF8String];
//	int textLength = strlen(pText);
	int textLength = 2*dataLength;
	
//	buf = [[NSMutableData alloc] initWithCapacity:textLength];
	for (int i=0; i<textLength; ++i)
	{
		char c = (char) (buf[i] ^ pEncryptKey[i % eKeyLength]);
//		[buf appendBytes:(void*)&c length:1];
		buf[i] = c;
	}
	
//	NSString* ret = [[[NSString alloc] initWithData:buf encoding:NSUTF8StringEncoding] autorelease];
	NSData* ret = [NSData dataWithBytes:buf length:textLength];
	
	free(buf);
	
	return [ret base64Encode];
}

-(NSDate*) dateFromString:(DateFormat)format
{
	if (format == DateFormatMDHM)
	{
		NSArray* se = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :"]];
		if ([se count] == 4)
		{
			int month = [[se objectAtIndex:0] intValue];
			int day = [[se objectAtIndex:1] intValue];
			int hour = [[se objectAtIndex:2] intValue];
			int minute = [[se objectAtIndex:3] intValue];
			NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
			NSDate* date = [NSDate date];
			NSDateComponents* comps = [gregorian components:unitFlags fromDate:date];
			int year = [comps year];
			if (([comps month] < month) || ([comps month] == month && [comps day] < day))
				year--;
			
			NSDateComponents *comps1 = [[NSDateComponents alloc] init];
			[comps1 setYear:year];
			[comps1 setMonth:month];
			[comps1 setDay:day];
			[comps1 setHour:hour];
			[comps1 setMinute:minute];
			[comps1 setSecond:0];
			NSDate* ret = [gregorian dateFromComponents:comps1];
			
			return ret;
		}
	}
	else if (format == DateFormatYMDHMS)
	{
		NSArray* se = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :"]];
		if ([se count] == 6)
		{
			NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			
			NSDateComponents* comps = [[NSDateComponents alloc] init];
			
			[comps setYear:[[se objectAtIndex:0] intValue]];
			[comps setMonth:[[se objectAtIndex:1] intValue]];
			[comps setDay:[[se objectAtIndex:2] intValue]];
			[comps setHour:[[se objectAtIndex:3] intValue]];
			[comps setMinute:[[se objectAtIndex:4] intValue]];
			[comps setSecond:[[se objectAtIndex:5] intValue]];
			
			NSDate* ret = [gregorian dateFromComponents:comps];
			
			return ret;
		}
	}
	else if (format == DateFormatYMD)
	{
		NSArray* se = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
		if ([se count] == 3)
		{
			NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			
			NSDateComponents* comps = [[NSDateComponents alloc] init];
			
			[comps setYear:[[se objectAtIndex:0] intValue]];
			[comps setMonth:[[se objectAtIndex:1] intValue]];
			[comps setDay:[[se objectAtIndex:2] intValue]];
			[comps setHour:0];
			[comps setMinute:0];
			[comps setSecond:0];
			
			NSDate* ret = [gregorian dateFromComponents:comps];
			
			return ret;
		}
	}
	else if (format == DateFormatYMDHM)
	{
		NSArray* se = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- :"]];
		if ([se count] == 5)
		{
			NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			
			NSDateComponents* comps = [[NSDateComponents alloc] init];
			
			[comps setYear:[[se objectAtIndex:0] intValue]];
			[comps setMonth:[[se objectAtIndex:1] intValue]];
			[comps setDay:[[se objectAtIndex:2] intValue]];
			[comps setHour:[[se objectAtIndex:3] intValue]];
			[comps setMinute:[[se objectAtIndex:4] intValue]];
			[comps setSecond:0];
			
			NSDate* ret = [gregorian dateFromComponents:comps];
			
			return ret;
		}
	}
	
	return nil;
}

// 返回“2天前”，“1年前”， “3小时前”等描述相对时间的字符串
-(NSString*) relativeDateFromString:(DateFormat)format
{
	return [[self dateFromString:format] stringOfRelativeDate];
}

-(id) JSONValue
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] JSONValue];
}

@end



@implementation NSDate(Encodings)

#define ONEYEAR 31104000.0
#define ONEMONTH 2592000.0
#define ONEDAY 86400.0
#define ONEHOUR 3600.0
#define ONEMINUTE 60.0

// 返回“两天前”，“一年前”， “三小时前”等描述相对时间的字符串
-(NSString*) stringOfRelativeDate
{
	NSString* ret = nil;
	NSTimeInterval interval = [self timeIntervalSinceNow];
	if (interval < 0)
	{
		interval = 0 - interval;
		
		if (interval >= ONEYEAR)
			ret = [NSString stringWithFormat:@"%d年前", ((NSInteger)(interval/ONEYEAR))];
		else if (interval >= ONEMONTH)
			ret = [NSString stringWithFormat:@"%d个月前", ((NSInteger)(interval/ONEMONTH))];
		else if (interval >= ONEDAY)
			ret = [NSString stringWithFormat:@"%d天前", ((NSInteger)(interval/ONEDAY))];
		else if (interval >= ONEHOUR)
			ret = [NSString stringWithFormat:@"%d小时前", ((NSInteger)(interval/ONEHOUR))];
		else if (interval >= ONEMINUTE)
			ret = [NSString stringWithFormat:@"%d分钟前", ((NSInteger)(interval/ONEMINUTE))];
		else
			ret = [NSString stringWithFormat:@"%d秒前", ((NSInteger)interval)];
	}
	else
	{
		ret = @"刚刚";
	}
	return ret;
}

// 返回“昨天 23:12”，"今天 07:03"，"09月21日"等三天之内的具体时间或者三天之外的日期
-(NSString*) stringOfNewsDate
{
	NSString* ret = nil;
	
	NSDate* now = [NSDate date];
	NSTimeInterval interval = [self timeIntervalSinceDate:now];
	if (interval < 0)
	{
		interval = 0 - interval;
		
		if (interval < ONEDAY * 3)
		{
			NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDateComponents* nowComponents = [gregorian components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSSecondCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:now];
			nowComponents.hour = 0;
			nowComponents.minute = 0;
			nowComponents.second = 0;
			NSDate* dawn = [gregorian dateFromComponents:nowComponents];
			NSTimeInterval todayInterval = [self timeIntervalSinceDate:dawn];
			NSString* relativeStr = nil;
			if (todayInterval >= 0)
				relativeStr = @"今天";
			else if (-todayInterval <= ONEDAY)
				relativeStr = @"昨天";
			else if (-todayInterval <= ONEDAY * 2)
				relativeStr = @"前天";
			if (relativeStr != nil)
			{
				NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
				NSString* formatStr = [NSString stringWithFormat:@"%@ HH:mm", relativeStr];
				[formatter setDateFormat:formatStr];
				ret = [formatter stringFromDate:self];
				return ret;
			}
		}
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"MM-dd"];
		ret = [formatter stringFromDate:self];
	}
	else
	{
		NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"HH:mm"];
		ret = [formatter stringFromDate:self];
	}
	return ret;
}

-(NSString*) stringOfHMDate
{
	NSString* ret = nil;
	
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm"];
	ret = [formatter stringFromDate:self];
	return ret;
}

@end


@implementation NSData(NSDataEx)

-(NSString*) md5
{
	NSUInteger length = [self length];
	if (length <= 0) return nil;
	
	const void* pData = [self bytes];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( pData, length, result );
	return [[NSString stringWithFormat:
			 @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			 result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			 result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			 ] uppercaseString];
}

// 转为base64编码
- (NSString*) base64Encode
{
	static char* encodingTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	
	char* pStr = (char*)[self bytes];
	int l = [self length];
	
//	NSMutableData* buf;
	
	int modulus = l % 3;
	int bufLength;
	if (modulus == 0)
	{
//		buf = [[NSMutableData alloc] initWithCapacity:4*l/3];
//		buf = malloc(4*l/3);
		bufLength = 4*l/3;
	}
	else
	{
//		buf = [[NSMutableData alloc] initWithCapacity:4*((l/3)+1)];
//		buf = malloc(4*(l/3+1));
		bufLength = 4*(l/3+1);
	}
	
	char* buf = malloc(bufLength);
	
	int dataLength = (l - modulus);
	
	char b1, b2, b3, b4;
	
	for (int i=0, j=0; i<dataLength; i+=3, j+=4)
	{
		int a1 = pStr[i] & 0xff;
		int a2 = pStr[i+1] & 0xff;
		int a3 = pStr[i+2] & 0xff;
		b1 = encodingTable[(a1 >> 2) & 0x3f];
		b2 = encodingTable[((a1 << 4) | (a2 >> 4)) & 0x3f];
		b3 = encodingTable[((a2 << 2) | (a3 >> 6)) & 0x3f];
		b4 = encodingTable[a3 & 0x3f];
		
		buf[j] = b1;
		buf[j+1] = b2;
		buf[j+2] = b3;
		buf[j+3] = b4;
		
//		[buf appendBytes:(void*)&b1 length:1];
//		[buf appendBytes:(void*)&b2 length:1];
//		[buf appendBytes:(void*)&b3 length:1];
//		[buf appendBytes:(void*)&b4 length:1];
	}
	
	int d1, d2;
	switch (modulus) {
		case 0:
			break;
		case 1:
			d1 = pStr[l-1] & 0xff;
			b1 = encodingTable[(d1 >> 2) & 0x3f];
			b2 = encodingTable[(d1 << 4) & 0x3f];
			b3 = '=';
			b4 = '=';
			buf[bufLength-4] = b1;
			buf[bufLength-3] = b2;
			buf[bufLength-2] = b3;
			buf[bufLength-1] = b4;
//			[buf appendBytes:(void*)&b1 length:1];
//			[buf appendBytes:(void*)&b2 length:1];
//			[buf appendBytes:(void*)&b3 length:1];
//			[buf appendBytes:(void*)&b4 length:1];
			break;
		case 2:
			d1 = pStr[l-2] & 0xff;
			d2 = pStr[l-1] & 0xff;
			b1 = encodingTable[(d1 >> 2) & 0x3f];
			b2 = encodingTable[((d1 << 4) | (d2 >> 4)) & 0x3f];
			b3 = encodingTable[(d2 << 2) & 0x3f];
			b4 = '=';
			buf[bufLength-4] = b1;
			buf[bufLength-3] = b2;
			buf[bufLength-2] = b3;
			buf[bufLength-1] = b4;
//			[buf appendBytes:(void*)&b1 length:1];
//			[buf appendBytes:(void*)&b2 length:1];
//			[buf appendBytes:(void*)&b3 length:1];
//			[buf appendBytes:(void*)&b4 length:1];
			break;
	}
	
	NSString* ret = [[NSString alloc] initWithData:[NSData dataWithBytes:buf length:bufLength] encoding:NSUTF8StringEncoding];
	
	free(buf);
	
//	[buf release];
	
	return ret;
}

-(NSString*) base64EncodeAndURLEncoding
{
	NSMutableString* base64 = [[self base64Encode] mutableCopy];
	[base64 replaceOccurrencesOfString:@"+" withString:@"%2B" options:NSLiteralSearch range:NSMakeRange(0, [base64 length])];
	[base64 replaceOccurrencesOfString:@"/" withString:@"%2F" options:NSLiteralSearch range:NSMakeRange(0, [base64 length])];
	[base64 replaceOccurrencesOfString:@"=" withString:@"%3D" options:NSLiteralSearch range:NSMakeRange(0, [base64 length])];
	return base64;
}

- (id)JSONValue
{
	NSError* error;
	id json = [NSJSONSerialization JSONObjectWithData:self options:0 error:&error];
	if (error)
		LOG_debug(@"-JSONValue failed. Error is: %@", error);
	return json;
}


//- (NSData*) des3:(NSString*)key encrypt:(BOOL)isEncrypt
//{
//	if (key == nil)
//		return nil;
//	
//	NSUInteger length = [self length];
//	char* buf = (char*)malloc(length);
//	bool type = isEncrypt ? ENCRYPT: DECRYPT;
//	NSData* ret = nil;
//	
//	if (DoDES(buf, (char*)[self bytes], length, [key UTF8String], [key length], type)) {
//		ret = [NSData dataWithBytes:buf length:length];
//		printf("%s", buf);
//	}
//	
//	free(buf);
//	
//	return ret;
//}

@end

@implementation NSURL (Params)

-(NSDictionary *)paramsDictionaryUsingEncoding:(NSStringEncoding)encoding
{
	NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
	NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
	NSScanner* scanner = [[NSScanner alloc] initWithString:self.parameterString];
	while (![scanner isAtEnd]) {
		NSString* pairString = nil;
		[scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
		[scanner scanCharactersFromSet:delimiterSet intoString:NULL];
		NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
		if (kvPair.count == 2) {
			NSString* key = [[kvPair objectAtIndex:0]
							 stringByReplacingPercentEscapesUsingEncoding:encoding];
			NSString* value = [[kvPair objectAtIndex:1]
							   stringByReplacingPercentEscapesUsingEncoding:encoding];
			[pairs setObject:value forKey:key];
		}
	}
	return [NSDictionary dictionaryWithDictionary:pairs];
}

-(NSDictionary*) queryDictionary
{
	NSArray* query = [self.query componentsSeparatedByString:@"&"];
	NSMutableDictionary* params = [NSMutableDictionary dictionary];
	for (NSString* str in query)
	{
		NSArray* kv = [str componentsSeparatedByString:@"="];
		if (kv.count == 2)
		{
			NSString* key = [kv[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString* value = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[params setObject:value forKey:key];
		}
	}
	return [NSDictionary dictionaryWithDictionary:params];
}

@end
