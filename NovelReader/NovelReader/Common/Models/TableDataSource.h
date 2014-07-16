//
//  TableDataSource.h
//
//  Created by Pang Zhenyu on 11-6-16.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Getter.h"


@protocol TableDataSource <NSObject>

@property (nonatomic, copy) NSDate* lastUpdateTime;
@property (nonatomic, copy) NSArray* sectionRows;
@property (nonatomic, copy) NSArray* sections;

-(NSInteger) numberOfSections;
-(NSInteger) numberOfRowsInSection:(NSUInteger)section;
-(NSArray*) rowsForSection:(NSUInteger)section;
-(NSObject*) modelForRow:(NSUInteger)row inSection:(NSUInteger)section;
-(NSObject*) modelForSectionHeader:(NSUInteger)section;
-(void) removeModelForRow:(NSUInteger)row inSection:(NSUInteger)section;
-(void) removeModelsForSection:(NSUInteger)section;
-(void) appendRows:(NSArray*)rows atSection:(NSUInteger)section;

@end


@interface TableDataSource : NSObject <TableDataSource>
{
	NSDate* _lastUpdateTime;
	NSArray* _sectionRows;		// NSMutableArray filled with row models
	NSArray* _sections;			// Section header models
}

@end


typedef enum
{
	ModelDestinationRow = 1,
	ModelDestinationSection,
	ModelDestinationThirdParty,
}
ModelDestination;


@interface NSObject (TableDataSource)

// Return a array filled with objects implemented Model
-(NSArray*) gettersForLoad;

// Reture YES if model belongs to Loadable.
-(BOOL) containsGetter:(id<Getter>)getter;

// Release memory when warning
-(void) onMemoryWarning;

@end
