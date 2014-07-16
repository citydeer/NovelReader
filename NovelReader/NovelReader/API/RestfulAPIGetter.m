//
//  RestfulAPIGetter.m
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-3.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "RestfulAPIGetter.h"
#import "Encodings.h"



@interface RestfulAPIGetter()

@end


@implementation RestfulAPIGetter

-(id)init
{
	self = [super init];
	if (self)
	{
		self.path = @"";
		self.method = @"GET";
	}
	return self;
}

static NSString* _host_address = @"";
static NSString* _user_token = @"";

+(void) setHost:(NSString*)host
{
	_host_address = host;
}

+(void) setUserToken:(NSString*)userToken
{
	_user_token = userToken;
}

-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy
{
	if (_host_address.length <= 0)
		return nil;
	
	NSString* fullURL = [NSString stringWithFormat:@"%@%@", _host_address, self.path];
	
	NSMutableDictionary* query = [NSMutableDictionary dictionary];
	[query addEntriesFromDictionary:self.params];
	if (_user_token.length > 0 && !_doNotSendUserToken)
		[query setObject:_user_token forKey:@"user_token"];
	
	NSArray* keys = query.allKeys;
	NSMutableString* buffer = [[NSMutableString alloc] initWithCapacity:0];
	for (NSUInteger i = 0; i < keys.count; ++i)
	{
		if (i > 0)
			[buffer appendString:@"&"];
		NSString* key = [keys objectAtIndex:i];
		[buffer appendFormat:@"%@=%@", key, [(NSString*)[query objectForKey:key] urlEncode:NSUTF8StringEncoding]];
	}
	
	NSString* queryStr = [NSString stringWithString:buffer];
	
	NSLog(@"%@?%@", fullURL, queryStr);
	
	NSMutableURLRequest* request = nil;
	if ([self.method.uppercaseString isEqualToString:@"POST"])
	{
		NSURL* url = [NSURL URLWithString:fullURL];
		request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
		request.HTTPMethod = @"POST";
		request.HTTPBody = [queryStr dataUsingEncoding:NSUTF8StringEncoding];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
	else
	{
		if (queryStr.length > 0)
			fullURL = [NSString stringWithFormat:@"%@?%@", fullURL, queryStr];
		
		NSURL* url = [NSURL URLWithString:fullURL];
		request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
		request.HTTPMethod = @"GET";
	}
	
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	
	return request;
}

-(NSInteger) _fillModelWithData:(NSData*)data
{
	NSInteger retCode = KYResultCodeParseError;
	
	id json = [data JSONValue];
	if ([json isKindOfClass:[NSDictionary class]])
	{
		_result = [(NSDictionary*)json copy];
		NSString* status = [_result objectForKey:@"status"];
		if ([status isEqualToString:@"success"])
		{
			retCode = KYResultCodeSuccess;
		}
		else
		{
			retCode = [[_result objectForKey:@"error_type"] intValue];
			_resultMessage = [_result objectForKey:@"message"];
		}
	}
	return retCode;
}

@end



#define kBoundary @"KCuQJwvbcAU9lGs05FU0N9uX7u5Pmo6N"

@interface UploadFeedbackGetter ()

-(NSData*) multipartBody;

@end


@implementation UploadFeedbackGetter

-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy
{
	if (_host_address.length <= 0)
		return nil;
	
	NSString* fullURL = [NSString stringWithFormat:@"%@%@", _host_address, @"users/upload"];
	
	NSURL* url = [NSURL URLWithString:fullURL];
	
	NSData* body = [self multipartBody];
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:body];
	[request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", kBoundary] forHTTPHeaderField:@"Content-Type"];
	
	return request;
}

- (NSInteger)_fillModelWithData:(NSData *)data
{
	NSInteger retCode = KYResultCodeParseError;
	
	id json = [data JSONValue];
	if ([json isKindOfClass:[NSDictionary class]])
	{
		NSDictionary* result = [(NSDictionary*)json copy];
		NSString* status = [result objectForKey:@"status"];
		if ([status isEqualToString:@"success"])
		{
			retCode = KYResultCodeSuccess;
		}
		else
		{
			retCode = [[result objectForKey:@"error_type"] intValue];
			_resultMessage = [result objectForKey:@"message"];
		}
	}
	return retCode;
}

-(NSData*) multipartBody
{
	NSMutableData* body = [NSMutableData data];
	
	NSData* boundary = [[NSString stringWithFormat:@"--%@\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding];
	[body appendData:boundary];
	NSString* formString = @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n";
	
	[body appendData:[[NSString stringWithFormat:formString, @"user_token", _user_token] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:boundary];
	
	[body appendData:[[NSString stringWithFormat:formString, @"user_account", self.account] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:boundary];
	
	if (_content.length <= 0) self.content = @"";
	[body appendData:[[NSString stringWithFormat:formString, @"content", self.content] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:boundary];
	
	[body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"record.wav\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n", self.data.length] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: audio/wav\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:self.data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", kBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return body;
}

@end


