//
//  MKFSQLTool.m
//  FMDBDemo
//
//  Created by Mike on 12/27/16.
//  Copyright © 2016 vera. All rights reserved.
//

#import "MKSQLQuery.h"
#import <objc/runtime.h>

@interface MKSQLQuery()

@property (nonatomic, copy, readwrite) NSString *sql;
@property (nonatomic, strong) NSDictionary *dataBaseConvertDic;

@end

@implementation MKSQLQuery

- (Select)select {

    return ^(NSArray<NSString *> *colums){
    
        if (colums.count) {
            
           _sql = [NSString stringWithFormat:@"SELECT %@",[colums componentsJoinedByString:@" , "]];
            
        }else{
        
            _sql = @"SELECT *";
            
        }
        
        return self;
    };
    
}

- (SelectM)selectM {

    return ^(NSString *tableName) {
    
        NSAssert(tableName.length, @"The Table's name can not be nil");
        _sql = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableName];
        
        return self;
    };

}

- (From)from {
    
    return ^(NSString *tableName){
    
        NSString *appendSql = [NSString stringWithFormat:@" FROM %@",tableName];
        _sql = [_sql stringByAppendingString:appendSql];
        
        return self;
    };

}

- (RplaceInserObj)replaceInsertObj {

    return ^(id dataModel){
    
        NSString *tableName = [self p_classNameFromObject:dataModel];
        NSDictionary *dataModelDic = [self p_propertyDicWithObjc:dataModel];
        return self.replaceInsertDic(tableName,dataModelDic);;
    };

    
   
}

- (ReplaceInsertDic)replaceInsertDic {

    return ^(NSString *table, NSDictionary *keyValueDic){
    
        NSArray *keys = [keyValueDic allKeys];
        NSString *keysString = [NSString stringWithFormat:@"'%@'", [keys componentsJoinedByString:@"','"]];
        
        NSArray *values = [keyValueDic allValues];
        // '1,2,3
        NSString *valuesString = [NSString stringWithFormat:@"'%@'",[values componentsJoinedByString:@"','"]];
        
        _sql = [NSString stringWithFormat:@"REPLACE INTO %@  ( %@ ) VALUES ( %@ )",table, keysString, valuesString];
    
        return self;
    };
}

- (InsertObj)insertObjc {

    return ^(id dataModel){
         
        NSString *tableName = [self p_classNameFromObject:dataModel];
        NSDictionary *dataModelDic = [self p_propertyDicWithObjc:dataModel];
        return self.insertDic(tableName,dataModelDic);
    
    };

}


- (InsertDic)insertDic {

    return ^(NSString *table,NSDictionary *keyValueDic){
    
        NSArray *keys = [keyValueDic allKeys];
        NSString *keysString = [NSString stringWithFormat:@"'%@'", [keys componentsJoinedByString:@"','"]];
        
        NSArray *values = [keyValueDic allValues];
        // '1,2,3
        NSString *valuesString = [NSString stringWithFormat:@"'%@'",[values componentsJoinedByString:@"','"]];
        
        _sql = [NSString stringWithFormat:@"INSERT INTO %@  ( %@ ) VALUES ( %@ )",table, keysString, valuesString];
        
        return self;
    };
    
}

- (Exist)exist {

    return ^(NSString *table){

       _sql = [NSString stringWithFormat:@"select name from sqlite_master where type = 'table' and name = '%@'",table];
        
        return self;
    };

}

- (Condition)condition {

    NSAssert(_sql.length, @"the condition can not exist alone");
    return ^(MKSql *condition){
    
    
        NSString *selectType = [_sql rangeOfString:@"WHERE"].length ? @" " : @"WHERE";
        _sql = [NSString stringWithFormat:@" %@ %@ %@",_sql ,selectType, condition.result];
        
        return self;
    };

}

- (Creat)creat{

    return ^(id dataModel){
    
        NSAssert(dataModel, @"MKSQLQuery: the data model cannot be nil");
        NSMutableString *sqlLanguage = [NSMutableString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement",[self p_classNameFromObject:dataModel]];
        
        // get all the properties
        NSArray *propertyNameTypeDictioanryArray = [self p_classAttributesFromClassName:[self p_classNameFromObject:dataModel]];
        
        // assemble the sql language
        for (NSDictionary *propertyDic in propertyNameTypeDictioanryArray) {
            
            NSString *propertyName = [[propertyDic allKeys] firstObject];
            NSString *propertyType = propertyDic[propertyName];
            [sqlLanguage appendString:[NSString stringWithFormat:@",%@ %@",propertyName,propertyType]];
        }
        
        [sqlLanguage appendString:@")"];
        _sql = sqlLanguage;
        return self;
    };
    

}

- (Update)update {
    
    return ^(NSString *tableName, NSDictionary *newKeyValue){
    
        NSString *newKeyValueString = [self p_equalStringFromeDic:newKeyValue];
        _sql = [NSString stringWithFormat:@"UPDATE %@ SET %@",tableName, newKeyValueString];
        
        return self;
    };

}

- (UpdateObj)updateObj {

    return ^(id tableObjc){
    
        NSString *tableString = [self p_classNameFromObject:tableObjc];
        NSDictionary *tableDic = [self p_propertyDicWithObjc:tableObjc];
        return self.update(tableString, tableDic);
        
    };


}

-(NSString *)sql{
    
    return _sql;
}

- (NSArray *)p_frontConditionIds {

    
    return @[@">=",@">=",@">",@">"];

}

- (NSArray *)p_trailConditionIds {

    return @[@"<=",@"<=",@"<",@"<"];

}

- (NSString *)p_equalStringFromeDic:(NSDictionary *)dictionary {


    NSMutableString *equalMString = [NSMutableString string];
    NSArray *conditionKeyArray = [dictionary allKeys];
    [conditionKeyArray enumerateObjectsUsingBlock:^(NSString * conditionKey, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *keyValueString = [NSString stringWithFormat:@" %@ = '%@'",conditionKey, dictionary[conditionKey]];
        [equalMString appendString:keyValueString];
        
        if (idx < conditionKeyArray.count - 1) {
            
            [equalMString appendString:@" ,"];
            
        }
    }];

    return [equalMString copy];

}

// append the conditionary sql string
- (NSMutableString *)p_coditionDicStringWithDic:(NSDictionary *)conditionDictionary{
    
    NSMutableString *sqlString = [NSMutableString string];
    
    NSArray *conditionKeyArray = [conditionDictionary allKeys];
    [conditionKeyArray enumerateObjectsUsingBlock:^(NSString * conditionKey, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *keyValueString = [NSString stringWithFormat:@" %@ = '%@'",conditionKey, conditionDictionary[conditionKey]];
        [sqlString appendString:keyValueString];
        
        if (idx < conditionKeyArray.count - 1) {
            
            [sqlString appendString:@" AND"];
            
        }
    }];
    return sqlString ;
    
}

- (Delete)deletes {

    return ^(NSString *tableName){
    
    
        _sql = [NSString stringWithFormat:@"DELETE FROM %@ ",tableName];
    
        return self;
    };

}

- (void)resetSql {

  _sql = @"";
    
}


#pragma mark- private method
// get the class's name
- (NSString *)p_classNameFromObject:(id)object
{
    return NSStringFromClass([object class]);
}

/**
 get all the attribute fo the class by the class's name, the content of the array the dictioanry, key is the property's name, value is the property's type
 */
- (NSArray *)p_classAttributesFromClassName:(NSString *)className
{
    // the attribute's number
    unsigned int outCount;
    
    // get all the attributes
    objc_property_t *properties = class_copyPropertyList([self p_classFromClassName:className], &outCount);
    // save all the names of the attributes
    NSMutableArray *attributes = [NSMutableArray array];
    
    // iterate all the attribute
    for (int i = 0; i < outCount; i++)
    {
        // the dictionary to store the property name and the type
        NSMutableDictionary *propertyDictioanry = [NSMutableDictionary dictionary];
        objc_property_t property = properties[i];
        // get the name of the attributes
        const char *propertyName = property_getName(property);
        
        NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
        // get the attributes of the property
        const char *type = property_getAttributes(property);
        
        NSString *propertOriginTypeString = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        
        NSArray *propertyAttributesArray = [propertOriginTypeString componentsSeparatedByString:@","];
        
        NSString *propertyOriginTypeName = [propertyAttributesArray firstObject];
        NSString *propertyResultTypeName = self.dataBaseConvertDic[propertyOriginTypeName];
        
        if (propertyResultTypeName.length) {
            
            [propertyDictioanry setObject:propertyResultTypeName forKey:propertyNameString];
            
            // add all the properties and the names to the attributes' array
            [attributes addObject:propertyDictioanry];
            
        }
        
    }
    free(properties);
    
    return attributes;
}

- (NSDictionary *)dataBaseConvertDic{
    
    if (!_dataBaseConvertDic) {
        
        _dataBaseConvertDic = @{@"Td":@"real",@"T@\"NSString\"":@"text",@"Tq":@"integer",@"Tf":@"real",@"Ti":@"integer"};
        
    }
    return  _dataBaseConvertDic;
    
}

- (Class)p_classFromClassName:(NSString *)className
{
    return NSClassFromString(className);
}

- (NSDictionary *)p_propertyDicWithObjc:(id)dataModel{
    
    NSAssert(dataModel, @"MKSQLQuery:the data model cannot be nil");
    NSMutableDictionary *dataModelMDic = [NSMutableDictionary dictionary];
    NSArray *propertyArray = [self p_propertyArrayWithClassName:[self p_classNameFromObject:dataModel]];
    for ( NSString *propery in propertyArray) {
        
        id value = [dataModel valueForKey:propery];
        if (!value) value = @"";
        [dataModelMDic setObject:value forKey:propery];
        
    }
    
    NSDictionary *resultDic = [dataModelMDic copy];
    return resultDic;
}

/**
 get all the attribute fo the class by the class's name, the content of the array the dictioanry, key is the property's name, value is the property's type
 */

- (NSArray *)p_propertyArrayWithClassName:(NSString *)className {
    
    
    // the attribute's number
    unsigned int outCount;
    
    // get all the attributes
    objc_property_t *properties = class_copyPropertyList([self p_classFromClassName:className], &outCount);
    // save all the names of the attributes
    NSMutableArray *attributes = [NSMutableArray array];
    
    // iterate all the attribute
    for (int i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        // get the name of the attributes
        const char *propertyName = property_getName(property);
        NSString *propertyNameString = [NSString stringWithUTF8String:propertyName];
        // add all the properties and the names to the attributes' array
        [attributes addObject:propertyNameString];
        
    }
    free(properties);
    
    
    return [NSArray arrayWithArray:attributes];
    
}

@end
