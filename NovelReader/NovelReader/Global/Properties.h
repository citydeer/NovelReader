//
//  Properties.h
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-2.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//



#define CDProp(key) ((NSString*)[[Properties appProperties] propertyForKey:(key)])
#define CDSetProp(key, value) ([[Properties appProperties] setProperty:(value) forKey:(key)])
#define CDIDProp(key) ([[Properties appProperties] propertyForKey:(key)])


#define PropUserSession @"user.session"
#define PropUserName @"user.name"
#define PropUserID @"user.id"
#define PropUserAccount @"user.account"
#define PropUserImage @"user.image"

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

-(id) propertyForKey:(NSString*)key;
-(void) setProperty:(id)property forKey:(NSString *)key;

@end

