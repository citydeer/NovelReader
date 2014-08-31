//
//  RestfulAPIGetter.h
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-3.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "HttpGetter.h"


@interface RestfulAPIGetter : HttpGetter

@property (nonatomic, copy) NSString* host;
@property (nonatomic, copy) NSString* path;
@property (nonatomic, copy) NSDictionary* params;
@property (nonatomic, copy) NSString* method;

@property (readonly) NSDictionary* result;

+(void) setDefaultHost:(NSString*)host;
+(void) setSession:(NSString*)session;
+(void) setUserID:(NSNumber*)uid;

@end


@interface UploadFeedbackGetter : HttpGetter

@property (nonatomic, strong) NSData* data;
@property (nonatomic, strong) NSString* content;
@property (nonatomic, strong) NSString* account;

@end


