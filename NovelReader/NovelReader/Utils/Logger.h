//
//  Logger.h
//
//  Created by Pang Zhenyu on 10-9-14.
//  Copyright 2010 tenfen Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Logger : NSObject

+ (void) file:(char*)sourceFile function:(char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...;

#define LOG_fatal(s,...) [Logger file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LOG_error(s,...) [Logger file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LOG_warn(s,...) [Logger file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LOG_info(s,...) [Logger file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]
#define LOG_debug(s,...) [Logger file:__FILE__ function: (char *)__FUNCTION__ lineNumber:__LINE__ format:(s),##__VA_ARGS__]

@end

