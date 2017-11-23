//
//  MKRunTimeTool.m
//  MKDataBase
//
//  Created by Mike on 23/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MKRunTimeTool.h"
#import <objc/runtime.h>
@implementation MKRunTimeTool

+ (NSArray *)getPropertiesWithClassName:(NSString *)className {
    
    Class MyClass = NSClassFromString(className);
    NSAssert(MyClass, @"The class name you set is wrong");
    // store all the properties
    NSMutableArray *resultProperties = [NSMutableArray array];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(MyClass, &outCount);
    
    for (int i = 0 ; i < outCount; i ++) {
        
        objc_property_t property = properties[i];
        const char *propertName = property_getName(property);
        NSString *propertyNameString = [NSString stringWithUTF8String:propertName];
        [resultProperties addObject:propertyNameString];
    }
    return [NSArray arrayWithArray:resultProperties];
}

@end
