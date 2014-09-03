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

static NSString* _default_host = @"";
static NSString* _user_session = @"";
static NSString* _user_account = @"";
static NSString* _user_name = @"";
static NSString* _user_id = @"";

+(void) setDefaultHost:(NSString*)host
{
	_default_host = host;
}

+(void) setSession:(NSString*)session
{
	_user_session = (session == nil ? @"" : session);
}

+(void) setUserAccount:(NSString *)account
{
	_user_account = (account == nil ? @"" : account);
}

+(void) setUserName:(NSString *)name
{
	_user_name = (name == nil ? @"" : name);
}

+(void) setUserID:(NSNumber*)uid
{
	_user_id = (uid == nil ? @"" : uid.stringValue);
}

-(NSURLRequest*) _createRequest:(KYHttpCachePolicy)cachePolicy
{
	NSString* host = _host;
	if (host.length <= 0) host = _default_host;
	if (host.length <= 0)
		return nil;
	
	NSString* fullURL = [NSString stringWithFormat:@"%@%@", host, self.path];
	
	NSMutableDictionary* query = [NSMutableDictionary dictionary];
	[query addEntriesFromDictionary:self.params];
	query[@"ver"] = @"1.0";;
	
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
		request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
		request.HTTPMethod = @"POST";
		request.HTTPBody = [queryStr dataUsingEncoding:NSUTF8StringEncoding];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	}
	else
	{
		if (queryStr.length > 0)
			fullURL = [NSString stringWithFormat:@"%@?%@", fullURL, queryStr];
		
		NSURL* url = [NSURL URLWithString:fullURL];
		request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
		request.HTTPMethod = @"GET";
	}
	
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	if (_user_id.length > 0 && _user_session.length > 0)
	{
		NSString* cookieStr = [NSString stringWithFormat:@"userid=%@; sessionid=%@; usrname=%@; nickname=%@", _user_id, _user_session, _user_account, _user_name];
		[request setValue:cookieStr forHTTPHeaderField:@"Cookie"];
		NSLog(@"Cookie string: %@", cookieStr);
	}
	
	return request;
}

-(NSInteger) _fillModelWithData:(NSData*)data
{
	NSInteger retCode = KYResultCodeParseError;
	
	id json = [data JSONValue];
	if ([json isKindOfClass:[NSDictionary class]])
	{
		_result = [json copy];
		_resultMessage = json[@"message"];
		id status = json[@"result"];
		if ([status respondsToSelector:@selector(intValue)])
		{
			if ([status intValue] == 0)
				retCode = KYResultCodeSuccess;
			else
				retCode = [status intValue];
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
	if (_default_host.length <= 0)
		return nil;
	
	NSString* fullURL = [NSString stringWithFormat:@"%@%@", _default_host, @"users/upload"];
	
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


