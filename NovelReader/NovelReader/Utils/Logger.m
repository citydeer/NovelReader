//
//  Logger.m
//
//  Created by Pang Zhenyu on 10-9-14.
//  Copyright 2010 tenfen Inc. All rights reserved.
//

#import "Logger.h"

#define __API_LOG_ENABLE__

@implementation Logger

+ (void) file:(char*)sourceFile function:(char*)functionName lineNumber:(int)lineNumber format:(NSString*)format, ...
{
#ifdef __API_LOG_ENABLE__
	@autoreleasepool {
		va_list ap;
		NSString *print, *file, *function;
		
		va_start(ap,format);
		file = [[NSString alloc] initWithBytes: sourceFile length: strlen(sourceFile) encoding: NSUTF8StringEncoding];
		function = [NSString stringWithCString:functionName encoding:NSUTF8StringEncoding];
		print = [[NSString alloc] initWithFormat: format arguments: ap];
		va_end(ap);
		
		NSLog(@"%@:%d %@;\n%@\n\n", [file lastPathComponent], lineNumber, function, print);
	}
#endif
}

@end
