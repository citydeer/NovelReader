//
//  Properties.h
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-2.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//



#define CDProp(key) ([[Properties appProperties] propertyForKey:(key)])
#define CDSetProp(key, value) ([[Properties appProperties] setProperty:(value) forKey:(key)])


#define PropUserToken @"user.token"
#define PropUserName @"user.name"
#define PropUserAccount @"user.account"
#define PropUserPassword @"user.password"

#define PropSettingServiceURL @"setting.service.url"

#define PropDeviceToken @"device.token"

#define PropReaderBrightness @"reader.brightness"
#define PropReaderFontSize @"reader.font.size"
#define PropReaderNightMode @"reader.nightmode"


@interface Properties : NSObject

+(Properties*) appProperties;

@property (readonly) NSString* apiHost;
@property (readonly) NSString* imageHost;
@property (readonly) NSInteger maxWrongCodeCount;
@property (nonatomic, assign) NSInteger numberOfWrongPatternCodeInput;
@property (nonatomic, strong) NSDate* lastVerifyDate;
@property (readonly) NSTimeInterval minVerifyInterval;

-(NSString*) propertyForKey:(NSString*)key;
-(void) setProperty:(NSString*)property forKey:(NSString *)key;

@end

