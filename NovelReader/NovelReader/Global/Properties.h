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
#define PropUserBalance @"user.balance"
#define PropUserVIP @"user.isvip"
#define PropUserFavCount @"user.fav.count"
#define PropUserBuyCount @"user.buy.count"

#define PropPayLastType @"pay.lasttype"

#define PropAppCommentURL @"app.comment.url"
#define PropAppStartFirst @"app.start.isfirst"
#define PropAppStartBooks @"app.start.books"
#define PropAppDeviceToken @"app.device.token"

#define PropReaderBrightness @"reader.brightness"
#define PropReaderFontSize @"reader.font.size"
#define PropReaderNightMode @"reader.nightmode"

#define PropStoreChannel @"store.channel"


@interface Properties : NSObject

+(Properties*) appProperties;

@property (readonly) NSString* APIHost;
@property (readonly) NSInteger XLMemberAppID;
@property (readonly) NSString* APPVersion;
@property (readonly) NSString* XLWebHost;

@property (nonatomic, strong) NSDate* lastVerifyDate;
@property (readonly) NSTimeInterval minVerifyInterval;

-(id) propertyForKey:(NSString*)key;
-(void) setProperty:(id)property forKey:(NSString *)key;

@end

