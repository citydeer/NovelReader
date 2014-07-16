//
//  KYAPIImageGetter.h
//  Kuyun
//
//  Created by Pang Zhenyu on 11-9-22.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//


#import "HttpGetter.h"


@interface KYAPIImageGetter : HttpGetter

@property (nonatomic, copy) NSString* imageId;
@property (nonatomic, copy) NSString* referUrl;
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, assign) CGSize imageSize;

@end

