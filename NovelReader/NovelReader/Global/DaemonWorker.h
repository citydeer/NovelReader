//
//  DaemonWorker.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-9-8.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//


#import "GetterController.h"


@interface DaemonWorker : NSObject

@property (readonly) GetterController* getterController;

+(DaemonWorker*) worker;

-(void) checkAppUpdateInfo:(BOOL)showAlert;
-(void) getRecommendBooks;

@end

