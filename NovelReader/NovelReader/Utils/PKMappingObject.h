//
//  PKMappingObject.h
//  Nemo
//
//  Created by Pang Zhenyu on 13-8-20.
//  Copyright (c) 2013年 Kuyun Inc. All rights reserved.
//




/**
 这个类的作用是把Property映射到Dictionary的Key(PKMapping)
 这个类中声明的属性都会从一个NSDictionary中获取。
 属性的名字就是NSDictionary的key，属性值是key对应的value。
 注意声明的属性是需要用@dynamic关键字来生成的。
 目前支持的属性类型有：id，int，float，double，char(即BOOL)。
 如果使用不支持的类型，会抛出异常。
 如果声明的属性类型是PKMappingObject的子类，而该属性名称的key对应的value是NSDictionary类型，会调用initWithDictionary创建一个PKMappingObject实例并返回。
 
 需要注意的是，由于每次访问属性值，实际都是从字典里读取并转化为对应的类型，在涉及到大量操作时可能会造成性能问题，这个要注意。
 */

@interface PKMappingObject : NSObject
{
@protected
	NSMutableDictionary* _dic;
}

-(id) initWithDictionary:(NSDictionary*)dictionary;

/**
 把某个NSArray中的NSDictionary元素替换成为PKMappingObject元素。
 @param arrayPropertyName 要替换的NSArray属性名字。这个Array里的元素必须是NSDictionary的实例，否则没有效果。
 @param PKMappingObjectClass 必须是PKMappingObject或其子类，否则没有效果。
 */
-(void) replaceDictionaryItemsInArrayProperty:(NSString*)arrayPropertyName withPKMappingObjectItems:(Class)mappingObjectClass;

@end


