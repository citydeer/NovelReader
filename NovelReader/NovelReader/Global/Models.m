//
//  Models.m
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-3.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "Models.h"



@implementation Model

+(BOOL) checkGetter:(id<Getter>)getter onView:(UIView*)view showMsg:(NSString*)msg exitIfFailed:(BOOL)exitIfFailed
{
	if (getter.resultCode == KYResultCodeSuccess)
		return YES;
	
//	if (exitIfFailed && [getter isKindOfClass:[GlodonAPIGetter class]])
//	{
//		if ([[((GlodonAPIGetter*)getter).result objectForKey:@"status"] isEqualToString:@"failed"])
//		{
//			[(AppDelegate*)[UIApplication sharedApplication].delegate logoutWithMsg:@"距上次登录已经太久了，请重新登录"];
//		}
//	}
//	
//	if (getter != nil && view != nil)
//	{
//		switch (getter.resultCode)
//		{
//			case KYResultCodeNetworkError:
//				[view showPopMsg:@"请检查网络" timeout:3];
//				break;
//				
//			case KYResultCodeTimeout:
//				[view showPopMsg:@"网络请求超时，请重试" timeout:3];
//				break;
//				
//			case KYResultCodeCanceled:
//				break;
//				
//			default:
//				if (msg.length > 0)
//					[view showPopMsg:msg timeout:3];
//				else if (getter.resultMessage.length > 0)
//					[view showPopMsg:getter.resultMessage timeout:3];
//				else
//					[view showPopMsg:@"未能获取数据" timeout:3];
//				break;
//		}
//	}
	return NO;
}

+(NSString*) stringWithCost:(double)cost
{
	static NSNumberFormatter* numberFormatter = nil;
	if (numberFormatter == nil)
	{
		numberFormatter = [[NSNumberFormatter alloc] init];
		numberFormatter.maximumFractionDigits = 4;
		numberFormatter.minimumIntegerDigits = 1;
	}
	NSString* str = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:cost / 10000.0]];
	return [NSString stringWithFormat:@"%@万元", str];
}

@end



@implementation BookModel
@dynamic bookID, image, isNew, isPreview, name, path;
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



@implementation CostItemModel
@dynamic id, je, xmqs, htmc, mc;
@end


@implementation PictureModel
@dynamic mc, sltdz, tpdz;
@end


@implementation UserInfoModel
@dynamic bookmark, buynum, coin, yueduvip;
@end



@implementation ContractListModel
@dynamic htlb;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"htlb" withPKMappingObjectItems:[ContractInfoModel class]];
	}
	return self;
}
@end


@implementation ContractInfoModel
@dynamic htmc, htmx, id, je;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"htmx" withPKMappingObjectItems:[ContractDetailModel class]];
	}
	return self;
}
@end


@implementation ContractDetailModel
@dynamic je, id, mc, xxsm;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"xxsm" withPKMappingObjectItems:[CostItemModel class]];
	}
	return self;
}
@end



@implementation ReportListModel
@dynamic xmyblb;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"xmyblb" withPKMappingObjectItems:[ReportInfoModel class]];
	}
	return self;
}
@end


@implementation ReportInfoModel
@dynamic id, tp, xxjd, bqsf, bqyf, bqyfmx, hthz, jssj, kssj, qs;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"hthz" withPKMappingObjectItems:[ReportContractModel class]];
		[self replaceDictionaryItemsInArrayProperty:@"tp" withPKMappingObjectItems:[PictureModel class]];
		[self replaceDictionaryItemsInArrayProperty:@"bqyfmx" withPKMappingObjectItems:[CostItemModel class]];
	}
	return self;
}
@end


@implementation ReportContractModel
@dynamic htmc, bqbs, bqcz, bqczmx, bqss, bqys, bqysmx;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"bqczmx" withPKMappingObjectItems:[CostItemModel class]];
		[self replaceDictionaryItemsInArrayProperty:@"bqysmx" withPKMappingObjectItems:[CostItemModel class]];
	}
	return self;
}
@end


@implementation CheckUpdateModel
@dynamic needupdate, url;
@end



@implementation WarningInfoModel
@dynamic chtjyj, hkblyj, maxbgyj, minbgyj, szhbbl, xmczyj, ycbgyj;
-(id) initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	if (self)
	{
		[self replaceDictionaryItemsInArrayProperty:@"chtjyj" withPKMappingObjectItems:[OverPriceModel class]];
		[self replaceDictionaryItemsInArrayProperty:@"ycbgyj" withPKMappingObjectItems:[AbnormalChangeModel class]];
	}
	return self;
}
@end



@implementation OverPriceModel
@dynamic bl, fbhtmc, htj, jsj;
@end



@implementation AbnormalChangeModel
@dynamic bsje, qrje, tzmc;
@end



