//
//  Models.h
//  CostPalmGear
//
//  Created by Pang Zhenyu on 14-3-3.
//  Copyright (c) 2014年 Glodon Inc. All rights reserved.
//

#import "PKMappingObject.h"
#import "GetterController.h"



@interface Model : NSObject

+(BOOL) checkGetter:(id<Getter>)getter onView:(UIView*)view showMsg:(NSString*)msg exitIfFailed:(BOOL)exitIfFailed;
+(NSString*) stringWithCost:(double)cost;

@end



@interface BookModel : PKMappingObject

@property (readwrite) NSString* bookID;
@property (readwrite) NSString* name;
@property (readwrite) NSString* image;
@property (readwrite) NSString* path;
@property (readwrite) BOOL isNew;
@property (readwrite) BOOL isPreview;

@end




@interface RechargePriceModel : PKMappingObject

@property (readwrite) double price;
@property (readwrite) NSArray* amount_list;

@end



@interface VIPPriceModel : PKMappingObject

@property (readwrite) double monthprice;
@property (readwrite) NSArray* price_list;

@end



@interface CostItemModel : PKMappingObject

@property (readonly) NSInteger id;
@property (readonly) NSString* htmc;
@property (readonly) NSString* mc;
@property (readonly) NSInteger xmqs;
@property (readonly) double je;

@end



@interface PictureModel : PKMappingObject

@property (readonly) NSString* sltdz;
@property (readonly) NSString* tpdz;
@property (readonly) NSString* mc;

@end



@interface ContractListModel : PKMappingObject

@property (readonly) NSArray* htlb;

@end


@interface ContractInfoModel : PKMappingObject

@property (readonly) NSInteger id;
@property (readonly) NSString* htmc;
@property (readonly) double je;
@property (readonly) NSArray* htmx;

@end


@interface ContractDetailModel : PKMappingObject

@property (readonly) NSInteger id;
@property (readonly) NSString* mc;
@property (readonly) double je;
@property (readonly) NSArray* xxsm;

@end


@interface ReportListModel : PKMappingObject

@property (readonly) NSArray* xmyblb;

@end


@interface ReportInfoModel : PKMappingObject

@property (readonly) NSInteger id;
@property (readonly) NSString* kssj;
@property (readonly) NSString* jssj;
@property (readonly) NSInteger qs;
@property (readonly) NSArray* hthz;
@property (readonly) double bqyf;
@property (readonly) double bqsf;
@property (readonly) NSString* xxjd;
@property (readonly) NSArray* tp;
@property (readonly) NSArray* bqyfmx;

@end


@interface ReportContractModel : PKMappingObject

@property (readonly) NSString* htmc;
@property (readonly) double bqcz;
@property (readonly) double bqbs;
@property (readonly) double bqys;
@property (readonly) double bqss;
@property (readonly) NSArray* bqczmx;
@property (readonly) NSArray* bqysmx;

@end



@interface CheckUpdateModel : PKMappingObject

@property (readonly) BOOL needupdate;
@property (readonly) NSString* url;

@end



@interface WarningInfoModel : PKMappingObject

@property (readonly) BOOL xmczyj;
@property (readonly) NSString* hkblyj;
@property (readonly) double szhbbl;
@property (readonly) double maxbgyj;
@property (readonly) double minbgyj;
@property (readonly) NSArray* chtjyj;
@property (readonly) NSArray* ycbgyj;

@end



@interface OverPriceModel : PKMappingObject

@property (readonly) NSString* fbhtmc;
@property (readonly) double jsj;
@property (readonly) double htj;
@property (readonly) double bl;

@end



@interface AbnormalChangeModel : PKMappingObject

@property (readonly) NSString* tzmc;
@property (readonly) double bsje;
@property (readonly) double qrje;

@end





