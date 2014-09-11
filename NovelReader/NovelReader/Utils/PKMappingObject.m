//
//  PKMappingObject.m
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-20.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//

#import "PKMappingObject.h"
#import <objc/runtime.h>



@interface PKMappingObject ()

@property (readonly) NSMutableDictionary* rawDictionary;
-(NSString*) keyFromSetterString:(SEL)selector;

@end



id propertyGetter_Id(PKMappingObject* _self, SEL _cmd);
char propertyGetter_Char(PKMappingObject* _self, SEL _cmd);
int propertyGetter_Int(PKMappingObject* _self, SEL _cmd);
float propertyGetter_Float(PKMappingObject* _self, SEL _cmd);
double propertyGetter_Double(PKMappingObject* _self, SEL _cmd);
void propertySetter_Id(PKMappingObject* _self, SEL _cmd, id value);
void propertySetter_Char(PKMappingObject* _self, SEL _cmd, char value);
void propertySetter_Int(PKMappingObject* _self, SEL _cmd, int value);
void propertySetter_Float(PKMappingObject* _self, SEL _cmd, float value);
void propertySetter_Double(PKMappingObject* _self, SEL _cmd, double value);

char getPropertyTypeChar(objc_property_t property);
Class getPropertyTypeClass(objc_property_t property);



@implementation PKMappingObject

@synthesize rawDictionary = _dic;

-(id) init
{
	self = [super init];
	if (self)
	{
		_dic = [NSMutableDictionary dictionary];
	}
	return self;
}


-(id) initWithDictionary:(NSDictionary*)dictionary
{
	self = [super init];
	if (self)
	{
		_dic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
	}
	return self;
}

-(id) initWithContentsOfFile:(NSString*)path
{
	NSDictionary* dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
	if (dictionary == nil)
		return nil;
	
	self = [self initWithDictionary:dictionary];
	return self;
}

-(BOOL) writeToFile:(NSString*)path
{
	return [_dic writeToFile:path atomically:YES];
}

-(void) replaceDictionaryItemsInArrayProperty:(NSString*)arrayPropertyName withPKMappingObjectItems:(Class)mappingObjectClass
{
	if (arrayPropertyName != nil && [mappingObjectClass isSubclassOfClass:[PKMappingObject class]])
	{
		NSArray* array = [_dic objectForKey:arrayPropertyName];
		if ([array isKindOfClass:[NSArray class]])
			[_dic setObject:[array arrayByConvertToPKMappingObject:mappingObjectClass] forKey:arrayPropertyName];
	}
}

-(id) rawValue:(NSString*)propertyName
{
	return [_dic objectForKey:propertyName];
}

-(NSString*) keyFromSetterString:(SEL)selector
{
	NSString* selStr = NSStringFromSelector(selector);
	NSString* firstPropertyChar = [selStr substringWithRange:NSMakeRange(3, 1)].lowercaseString;
	NSString* propertyName = [firstPropertyChar stringByAppendingString:[selStr substringWithRange:NSMakeRange(4, selStr.length-5)]];
	objc_property_t property = class_getProperty([self class], propertyName.UTF8String);
	if (property)
		return propertyName;
	
	return [firstPropertyChar.uppercaseString stringByAppendingString:[selStr substringWithRange:NSMakeRange(4, selStr.length-5)]];
}


+(BOOL) resolveInstanceMethod:(SEL)sel
{
	NSString* selStr = NSStringFromSelector(sel);
	
	if ([selStr hasPrefix:@"set"])
	{
		NSUInteger colonIndex = [selStr rangeOfString:@":"].location;
		if (colonIndex == selStr.length - 1 && colonIndex >= 4)
		{
			NSString* firstPropertyChar = [selStr substringWithRange:NSMakeRange(3, 1)].lowercaseString;
			NSString* propertyName = [firstPropertyChar stringByAppendingString:[selStr substringWithRange:NSMakeRange(4, colonIndex-4)]];
			objc_property_t property = class_getProperty([self class], propertyName.UTF8String);
			if (property == NULL)
			{
				propertyName = [firstPropertyChar.uppercaseString stringByAppendingString:[selStr substringWithRange:NSMakeRange(4, colonIndex)]];
				property = class_getProperty([self class], propertyName.UTF8String);
			}
			char type = getPropertyTypeChar(property);
			switch (type)
			{
				case _C_ID:
					class_addMethod([self class], sel, (IMP)propertySetter_Id, "v@:@");
					return YES;
				case _C_CHR:
					class_addMethod([self class], sel, (IMP)propertySetter_Char, "v@:c");
					return YES;
				case _C_INT:
					class_addMethod([self class], sel, (IMP)propertySetter_Int, "v@:i");
					return YES;
				case _C_FLT:
					class_addMethod([self class], sel, (IMP)propertySetter_Float, "v@:f");
					return YES;
				case _C_DBL:
					class_addMethod([self class], sel, (IMP)propertySetter_Double, "v@:d");
					return YES;
				default:
					break;
			}
		}
	}
	else
	{
		objc_property_t property = class_getProperty([self class], selStr.UTF8String);
		char type = getPropertyTypeChar(property);
		switch (type)
		{
			case _C_ID:
				class_addMethod([self class], sel, (IMP)propertyGetter_Id, "@@:");
				return YES;
			case _C_CHR:
				class_addMethod([self class], sel, (IMP)propertyGetter_Char, "c@:");
				return YES;
			case _C_INT:
				class_addMethod([self class], sel, (IMP)propertyGetter_Int, "i@:");
				return YES;
			case _C_FLT:
				class_addMethod([self class], sel, (IMP)propertyGetter_Float, "f@:");
				return YES;
			case _C_DBL:
				class_addMethod([self class], sel, (IMP)propertyGetter_Double, "d@:");
				return YES;
			default:
				break;
		}
	}
	
	return [super resolveInstanceMethod:sel];
}

char getPropertyTypeChar(objc_property_t property)
{
	if (property)
	{
		const char* attr = property_getAttributes(property);
		if (attr && *attr == 'T')
		{
			return *(attr+1);
		}
	}
	return 0;
}

Class getPropertyTypeClass(objc_property_t property)
{
	if (property)
	{
		const char* attr = property_getAttributes(property);
		if (strlen(attr) > 4 && attr[0] == 'T' && attr[1] == '@' && attr[2] == '"')
		{
			char* closingQuoteLoc = strchr(attr+3, '"');
			if (closingQuoteLoc)
			{
				size_t classNameLen = closingQuoteLoc - attr - 2;
				char className[classNameLen];
				memcpy(className, attr+3, classNameLen-1);
				className[classNameLen-1] = '\0';
				return objc_getClass(className);
			}
		}
	}
	return Nil;
}


id propertyGetter_Id(PKMappingObject* _self, SEL _cmd)
{
	NSString* key = NSStringFromSelector(_cmd);
	id value = [_self->_dic objectForKey:key];
	if ([value isKindOfClass:[NSDictionary class]])
	{
		Class propertyClass = getPropertyTypeClass(class_getProperty([_self class], key.UTF8String));
		if ([propertyClass isSubclassOfClass:[PKMappingObject class]])
		{
			id newValue = [[propertyClass alloc] initWithDictionary:value];
			if (newValue)
			{
				[_self->_dic setObject:newValue forKey:key];
				value = newValue;
			}
		}
	}
	if (value == [NSNull null])
		value = nil;
	return value;
}

char propertyGetter_Char(PKMappingObject* _self, SEL _cmd)
{
	id value = [_self->_dic objectForKey:NSStringFromSelector(_cmd)];
	return value == [NSNull null] ? 0 : [value charValue];
}

int propertyGetter_Int(PKMappingObject* _self, SEL _cmd)
{
	id value = [_self->_dic objectForKey:NSStringFromSelector(_cmd)];
	return value == [NSNull null] ? 0 : [value intValue];
}

float propertyGetter_Float(PKMappingObject* _self, SEL _cmd)
{
	id value = [_self->_dic objectForKey:NSStringFromSelector(_cmd)];
	return value == [NSNull null] ? 0 : [value floatValue];
}

double propertyGetter_Double(PKMappingObject* _self, SEL _cmd)
{
	id value = [_self->_dic objectForKey:NSStringFromSelector(_cmd)];
	return value == [NSNull null] ? 0 : [value doubleValue];
}

void propertySetter_Id(PKMappingObject* _self, SEL _cmd, id value)
{
	if (value)
		[_self->_dic setObject:value forKey:[_self keyFromSetterString:_cmd]];
	else
		[_self->_dic removeObjectForKey:[_self keyFromSetterString:_cmd]];
}

void propertySetter_Char(PKMappingObject* _self, SEL _cmd, char value)
{
	[_self->_dic setObject:[NSNumber numberWithChar:value] forKey:[_self keyFromSetterString:_cmd]];
}

void propertySetter_Int(PKMappingObject* _self, SEL _cmd, int value)
{
	[_self->_dic setObject:[NSNumber numberWithInt:value] forKey:[_self keyFromSetterString:_cmd]];
}

void propertySetter_Float(PKMappingObject* _self, SEL _cmd, float value)
{
	[_self->_dic setObject:[NSNumber numberWithFloat:value] forKey:[_self keyFromSetterString:_cmd]];
}

void propertySetter_Double(PKMappingObject* _self, SEL _cmd, double value)
{
	[_self->_dic setObject:[NSNumber numberWithDouble:value] forKey:[_self keyFromSetterString:_cmd]];
}

@end




@implementation NSArray (PKMappingExtension)

-(NSArray*) arrayByConvertToPKMappingObject:(Class)PKMappingObjectClass
{
	if (![PKMappingObjectClass isSubclassOfClass:[PKMappingObject class]])
	{
		@throw [NSException exceptionWithName:@"Invalid Class" reason:[NSString stringWithFormat:@"%@ is not subclass of PKMappingObject", NSStringFromClass(PKMappingObjectClass)] userInfo:nil];
	}
	
	NSMutableArray* mArray = [NSMutableArray arrayWithCapacity:self.count];
	for (int i = 0; i < self.count; ++i)
	{
		id item = [self objectAtIndex:i];
		if ([item isKindOfClass:[NSDictionary class]])
			[mArray addObject:[[PKMappingObjectClass alloc] initWithDictionary:item]];
	}
	return [NSArray arrayWithArray:mArray];
}

-(NSArray*) arrayByConvertToDictionary
{
	NSMutableArray* mArray = [NSMutableArray arrayWithCapacity:self.count];
	for (int i = 0; i < self.count; ++i)
	{
		id item = [self objectAtIndex:i];
		if ([item isKindOfClass:[PKMappingObject class]])
			[mArray addObject:((PKMappingObject*)item).rawDictionary];
	}
	return [NSArray arrayWithArray:mArray];
}

@end


