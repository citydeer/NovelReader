//
//  Theme.h
//  Nemo
//
//  Created by zhihui zhao on 13-9-30.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//


#define CDColor(key, colorStr) [[Theme currentTheme] colorForKey:(key) defaultColorString:(colorStr)]
#define CDImage(name) [[Theme currentTheme] imageForName:(name)]
#define CDKeyImage(key) [[Theme currentTheme] imageForKey:(key)]


@interface Theme : NSObject

+ (Theme *) currentTheme;

- (UIColor *)colorForKey:(NSString *)key defaultColorString:(NSString *)colorStr;
- (UIImage *)imageForName:(NSString *)name;
- (UIImage *)imageForKey:(NSString *)key;

+(NSString*) onlineSkinPath;
+(UIImage*) imageWithName:(NSString*)name inPath:(NSString*)path;

@end
