//
//  TableDataSource.m
//
//  Created by Pang Zhenyu on 11-6-16.
//  Copyright 2011年 Tenfen Inc. All rights reserved.
//

#import "TableDataSource.h"


@implementation TableDataSource
 
@synthesize lastUpdateTime = _lastUpdateTime;
@synthesize sectionRows = _sectionRows;
@synthesize sections = _sections;

-(NSInteger) numberOfSections
{
	return _sectionRows.count;
}

-(NSArray*) rowsForSection:(NSUInteger)section
{
	if (section < _sectionRows.count)
		return (NSArray*)[_sectionRows objectAtIndex:section];
	return nil;
}

-(NSInteger) numberOfRowsInSection:(NSUInteger)section
{
	if (section < _sectionRows.count)
		return ((NSArray*)[_sectionRows objectAtIndex:section]).count;
	return 0;
}

-(NSObject*) modelForRow:(NSUInteger)row inSection:(NSUInteger)section
{
	if (section < _sectionRows.count)
	{
		NSArray* rows = [_sectionRows objectAtIndex:section];
		if (row < rows.count)
			return [rows objectAtIndex:row];
	}
	return nil;
}

-(NSObject*) modelForSectionHeader:(NSUInteger)section
{
	if (section < _sections.count)
		return [_sections objectAtIndex:section];
	return nil;
}

-(void) removeModelForRow:(NSUInteger)row inSection:(NSUInteger)section
{
	NSMutableArray* sections = [_sectionRows mutableCopy];
	NSMutableArray* rows = [(NSArray*)[sections objectAtIndex:section] mutableCopy];
	[rows removeObjectAtIndex:row];
	[sections removeObjectAtIndex:section];
	[sections insertObject:[NSArray arrayWithArray:rows] atIndex:section];
	self.sectionRows = sections;
}

-(void) removeModelsForSection:(NSUInteger)section
{
	NSMutableArray* sections = [_sectionRows mutableCopy];
	[sections removeObjectAtIndex:section];
	self.sectionRows = sections;
	if (_sections)
	{
		sections = [_sections mutableCopy];
		[sections removeObjectAtIndex:section];
		self.sections = sections;
	}
}

-(void) appendRows:(NSArray*)rows atSection:(NSUInteger)section
{
	if (section < self.sectionRows.count)
	{
		NSArray* rawRows = [self.sectionRows objectAtIndex:section];
		rawRows = [rawRows arrayByAddingObjectsFromArray:rows];
		NSMutableArray* sectionsCopy = [self.sectionRows mutableCopy];
		[sectionsCopy removeObjectAtIndex:section];
		[sectionsCopy insertObject:rawRows atIndex:section];
		self.sectionRows = sectionsCopy;
	}
}

@end


@implementation NSObject (TableDataSource)

-(NSArray*) gettersForLoad
{
	return nil;
}

-(BOOL) containsGetter:(id<Getter>)getter
{
	return NO;
}

-(void) onMemoryWarning
{
}

@end
