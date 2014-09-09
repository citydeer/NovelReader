//
//  Models.m
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-3.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "Models.h"
#import "KYTipsView.h"



@implementation Model

+(BOOL) checkGetter:(id<Getter>)getter onView:(UIView*)view showMsg:(NSString*)msg
{
	if (getter.resultCode == KYResultCodeSuccess)
		return YES;
	
	switch (getter.resultCode)
	{
		case KYResultCodeNetworkError:
			[view showPopMsg:@"请检查网络设置" timeout:3];
			break;
			
		case KYResultCodeTimeout:
			[view showPopMsg:@"网络请求超时，请重试" timeout:3];
			break;
			
		case KYResultCodeCanceled:
			break;
			
		default:
			if (msg.length > 0)
				[view showPopMsg:msg timeout:3];
			else if (getter.resultMessage.length > 0)
				[view showPopMsg:getter.resultMessage timeout:3];
			else
				[view showPopMsg:@"未能获取数据" timeout:3];
			break;
	}
	
	return NO;
}

@end



@implementation RechargePriceModel
@dynamic amount_list, prize, ret;
@end



@implementation VIPPriceModel
@dynamic monthprice, price_list, ret;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"price_list" withPKMappingObjectItems:[PriceItemModel class]];
	}
	return self;
}
@end



@implementation PriceItemModel
@dynamic amount, price;
@end



@implementation UserInfoModel
@dynamic bookmark, buynum, coin, yueduvip;
@end



@implementation AppInfoModel
@dynamic commurl, downurl, isupdate;
@end





