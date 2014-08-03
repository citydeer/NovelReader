//
//  BookCell.h
//  NovelReader
//
//  Created by Pang Zhenyu on 14-8-1.
//  Copyright (c) 2014年 citydeer. All rights reserved.
//



@interface BookCell : UICollectionViewCell

+(CGSize) measureModel:(id)model;
-(void) applyModel:(id)model;

@end

