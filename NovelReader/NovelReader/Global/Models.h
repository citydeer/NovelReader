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

+(BOOL) checkGetter:(id<Getter>)getter onView:(UIView*)view showMsg:(NSString*)msg;

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
@property (readwrite) NSInteger ret;
@property (readwrite) double prize;
@property (readwrite) NSArray* amount_list;
@end



@interface VIPPriceModel : PKMappingObject
@property (readwrite) NSInteger ret;
@property (readwrite) double monthprice;
@property (readwrite) NSArray* price_list;
@end


@interface PriceItemModel : PKMappingObject
@property (readonly) NSInteger amount;
@property (readonly) float price;
@end



@interface UserInfoModel : PKMappingObject
@property (readonly) NSInteger buynum;
@property (readonly) NSInteger coin;
@property (readonly) BOOL yueduvip;
@property (readonly) NSInteger bookmark;
@end



@interface AppInfoModel : PKMappingObject
@property (readonly) BOOL isupdate;
@property (readonly) NSString* downurl;
@property (readonly) NSString* commurl;
@end







