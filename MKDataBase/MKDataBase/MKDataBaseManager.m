//
//  MKDataBaseManager.m
//  Pods
//
//  Created by Mike on 7/6/16.
//
//

#import "MKDataBaseManager.h"
#import "FMDatabase.h"
#import "MKSQLQuery.h"
#import <objc/runtime.h>

@interface MKDataBaseManager ()

{
    FMDatabase *_database;
    dispatch_queue_t _mkqueue;
    NSLock *_lock;
    
    
}

@property (nonatomic, strong, readwrite) MKSQLQuery *query;

@end

@implementation MKDataBaseManager
static MKDataBaseManager *manager = nil;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _database = [FMDatabase databaseWithPath:[self p_databasePath]];
        _query = [[MKSQLQuery alloc]init];
        _mkqueue = dispatch_queue_create("com.mike.mkdatabase.queue", DISPATCH_QUEUE_CONCURRENT);
        _lock = [[NSLock alloc]init];
        
    }
    return self;
}

- (NSString *)p_databasePath
{
    NSString *doucmentpath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSLog(@"db path : %@",doucmentpath);
    return [doucmentpath stringByAppendingPathComponent:@"MKDataBaseManager.db"];
}

/**
 This method will be executed finally.

 @param sql sql language

 @return If the operation is success
 */

- (BOOL)p_executeUpdateSQL:(NSString *)sql{
    
    [_lock lock];
    if (![_database open]) return NO;
    NSAssert(sql.length > 1, @"the sql language can not be empty");
    BOOL isExecuteSuccess = [_database executeUpdate:sql];
    [_query resetSql];
    [_database close];
    [_lock unlock];
    return isExecuteSuccess;
}

/**
 This method will be executed finally.
 
 @param sql sql language
 
 @return If the operation is success
 */
- (FMResultSet *)p_executeQuerySQL:(NSString *)sql{
    
    if (![_database open]) return nil;
    NSAssert(sql.length > 1, @"the sql language can not be empty");
    FMResultSet *resultSet = [_database executeQuery:sql];
    [_query resetSql];
    
    return resultSet;
    
}

/**
  create the database manager
 */
+ (MKDataBaseManager *)sharedDatabaseManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

/**
  if the talbe is exist
 */
- (BOOL)isTableExistsWithName:(NSString *)tableName
{
    [_lock lock];
    NSString *sql = _query.exist(tableName).sql;
    FMResultSet *results = [self p_executeQuerySQL:sql];
    
    if (results.next)
    {
        [_database close];
        [_lock unlock];
        return YES;
    }
    [_database close];
    [_lock unlock];
    
    return NO;
}

/**
  create talbe with object
 */
- (BOOL)isCreateTableSuccessWithObject:(id)object
{
    
    NSString *sql = _query.creat(object).sql;
    BOOL isCreatSuccess = [self p_executeUpdateSQL:sql];
    return isCreatSuccess;

}

// get the class's name
- (NSString *)p_classNameFromObject:(id)object
{
    return NSStringFromClass([object class]);
}

- (Class)p_classFromClassName:(NSString *)className
{
    return NSClassFromString(className);
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

// append the conditionary sql string
- (NSMutableString *)appendConditionSqulString:(NSMutableString *)sqlString FromConditionary:(NSDictionary *)conditionDictionary{
    
    NSArray *conditionKeyArray = [conditionDictionary allKeys];
    
    [conditionKeyArray enumerateObjectsUsingBlock:^(NSString * conditionKey, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *keyValueString = [NSString stringWithFormat:@" %@ = '%@'",conditionKey, conditionDictionary[conditionKey]];
        [sqlString appendString:keyValueString];
        
        if (idx < conditionKeyArray.count - 1) {
            
            [sqlString appendString:@" AND"];
            
        }
    }];
    return sqlString;
    
}

@end

@implementation MKDataBaseManager (Add)

/**
 insert the data
 */
- (BOOL)insertWithObject:(id)object
{
    
    // the database cannot be opened
    if (![_database open]) return NO;
    
    NSString *tableName = [self p_classNameFromObject:object];
    if (![self isTableExistsWithName:tableName])
    {
        // it is failure to create the table
        if (![self isCreateTableSuccessWithObject:object])
        {
            return NO;
        }
    }
    NSString *sql = _query.insertObjc(object).sql;
    // execute the insert language
    BOOL isInsertSuccessed = [self p_executeUpdateSQL:sql];;

    return isInsertSuccessed;
}

- (BOOL)addColumWithTableName:(NSString *)tableName columName:(NSArray *)names type:(NSArray *)types defaluts:(NSArray *)defaultValues{
    
    if (![_database open]) return NO;
    
    __block NSMutableString *sql = [NSMutableString stringWithFormat:@"ALTER TABLE %@ ADD ",tableName];
    [names enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [sql appendString:[NSString stringWithFormat:@"%@ %@ ", names[idx], types[idx]]];
        if (defaultValues.count)
            [sql appendString:[NSString stringWithFormat:@"DEFAULT %@",defaultValues[idx]]];
        
        if (idx != names.count - 1) [sql appendString:@", "];
        else[sql appendString:@""];
        
    }];
    
    BOOL isAddSuccess = [self p_executeUpdateSQL:sql];;
    return isAddSuccess;
    
}

@end

@implementation MKDataBaseManager (Query)

/**
 query all the objects, which satisfy the conditions
 */
- (NSArray *)queryObjectsWithCondition:(NSDictionary *)condition objName:(NSString *)objcName {

    [_lock lock];
    NSString *sqlLanguage = _query.selectM(objcName).condition(condition).sql;
    FMResultSet *results = [self p_executeQuerySQL:sqlLanguage];
    NSArray *reultModels = [self p_getObjcsWithResutltSet:results className:objcName];
    [_database close];
    [_lock unlock];
    return reultModels;
    

}

- (void)queryObjectsInBackGroundWithCondition:(NSDictionary *)condition objName:(NSString *)objcName callBack:(void(^)(NSArray *foundObjcts))callBackBlock{
    
    if (!callBackBlock) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_mkqueue, ^{
    
        __strong typeof(weakSelf) self = weakSelf;
        NSArray *foundObjs = [self queryObjectsWithCondition:condition objName:objcName];
        callBackBlock(foundObjs);
    });
    
    
}

- (NSArray *)queryObjectsWithRange:(MKRange *)range condition:(NSDictionary *)conditionDic objName:(NSString *)objcName{

    [_lock lock];
    NSString *sqlLanguage = _query.selectM(objcName).range(MKRangeTypeDefault,range).condition(conditionDic).sql;
    FMResultSet *results = [self p_executeQuerySQL:sqlLanguage];
    NSArray *resultModels = [self p_getObjcsWithResutltSet:results className:objcName];
    [_database close];
    [_lock unlock];
    return resultModels;
    
}

- (void)queryObjectsWithRange:(MKRange *)range condition:(NSDictionary *)conditionDic objName:(NSString *)objcName callBackBlock:(void(^)(NSArray *foundObjcs))callBackBlock{

    if (!callBackBlock) return;
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(_mkqueue, ^{
        
        __strong typeof(weakSelf) self = weakSelf;
        NSArray *foundObjs = [self queryObjectsWithRange:range condition:conditionDic objName:objcName];
        callBackBlock(foundObjs);
    });
}

#warning The selection type MKRangeType should be open to user, how can I do it ?
- (NSArray *)queryObjectsWithRanges:(NSArray <MKRange *> *)ranges condition:(NSDictionary *)conditionDic objName:(NSString *)objcName {
    
    [_lock lock];
    _query.selectM(objcName);
    for (MKRange *temptRagne in ranges) {
        
        _query.range(MKRangeTypeDefault,temptRagne);
    }
    
    _query.condition (conditionDic);
    NSString *sqlLanguage = _query.sql;
    FMResultSet *results = [self p_executeQuerySQL:sqlLanguage];
    NSArray *resultModels = [self p_getObjcsWithResutltSet:results className:objcName];
    [_database close];
    [_lock unlock];
    return resultModels;

};


- (void)queryObjectsWithRanges:(NSArray <MKRange *> *)ranges condition:(NSDictionary *)conditionDic objName:(NSString *)objcName callBackBlock:(void(^)(NSArray *foundObjcs))callBackBlock{

    if (!callBackBlock) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_mkqueue, ^{
        
        __strong typeof(weakSelf) self = weakSelf;
        NSArray *foundObjcs = [self queryObjectsWithRanges:ranges condition:conditionDic objName:objcName];
        callBackBlock(foundObjcs);
        
    });
    

}

- (NSArray *)p_getObjcsWithResutltSet:(FMResultSet *)resultSet className:(NSString *)className {

    
    NSArray *attributes = [self p_propertyArrayWithClassName:className];
    // iterate all the resuts and creat object
    NSMutableArray *resultModels = [NSMutableArray array];
    while (resultSet.next)
    {
        // convert to class
        Class cls = [self p_classFromClassName:className];
        
        //  create model
        id obj = [[cls alloc] init];
        
        for (int i = 0; i < attributes.count; i++)
        {
            NSString *valueString = [resultSet stringForColumn:attributes[i]];
            if (valueString.length == 0) valueString = @"";
            // set the value
            [obj setValue:valueString forKey:attributes[i]];
        }
        // add to the datasource
        [resultModels addObject:obj];
    }

    return [NSArray arrayWithArray:resultModels];

}

- (void)queryObjectsInBackGroundWithName:(NSString *)className callBack:(void(^)(NSArray *))callBackBlock{

    if (!callBackBlock) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_mkqueue, ^{

        __strong typeof(weakSelf) self = weakSelf;
        NSArray *foundObjcs = [self queryObjectsWithName:className];
        callBackBlock(foundObjcs);
        
        
    });
   
}

/**
 query all the data modle, and get them from the retured array
 */
- (NSArray *)queryObjectsWithName:(NSString *)className
{
    [_lock lock];
    if (![_database open]) return nil;
    NSString *sql = _query.selectM(className).sql;
    FMResultSet *results = [self p_executeQuerySQL:sql];
    NSArray *reultModels =  [self p_getObjcsWithResutltSet:results className:className];
    [_database close];
    [_lock unlock];
    return reultModels;
    
}


/**
 query the object which satisfy the conditioan
 */
- (id)queryObjectWithCondition:(NSDictionary *)condition objName:(NSString *)objcName {

    NSArray *conditionResultArray =  [self queryObjectsWithCondition:condition objName:objcName];
    return [conditionResultArray firstObject];

}

- (void)queryObjectWithCondition:(NSDictionary *)condition objName:(NSString *)objcName callBackBlock:(void(^)(id objc))callBackBlock{
    
    if (!callBackBlock) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_mkqueue, ^{
       
        __strong typeof(weakSelf) self = weakSelf;
        id objc = [self queryObjectWithCondition:condition objName:objcName];
        callBackBlock(objc);
        
    });
    
}

@end

#pragma mark - update database
@implementation MKDataBaseManager (Update)

- (BOOL)updateTable:(NSString *)tableName newKeyValue:(NSDictionary *)newValuesDic condition:(NSDictionary *)condition {

    /**
     * Example: UPDATE Person SET Address = 'Zhongshan 23', City = 'Nanjing' WHERE LastName = 'Wilson'
     */
    NSString *sqlLanguage = _query.update(tableName,newValuesDic).condition(condition).sql;
    // assemble the sql language
    BOOL isUpdateSuccess = [self p_executeUpdateSQL:sqlLanguage];
    return isUpdateSuccess;

}

/**
 * update the database by object
 */
- (BOOL)updateTableWithNewObjc:(id)tableObject condition:(NSDictionary *)condition{


    NSString *sqlLanguage = _query.updateObj(tableObject).condition(condition).sql;
    // assemble the sql language
    BOOL isUpdateSuccess = [self p_executeUpdateSQL:sqlLanguage];
    [_database close];
    return isUpdateSuccess;

}

@end

@implementation MKDataBaseManager (Delete)

- (BOOL)deleteTable:(NSString *)tableName range:(MKRange *)range condition:(NSDictionary *)condition {
    
    /**
     * Example: DELETE FROM Person WHERE LastName = 'Wilson'
     */

    NSString *sqlLanguage = _query.deletes(tableName).range(MKRangeTypeDefault,range).condition(condition).sql;
    BOOL isDeleteSuccess =  [self p_executeUpdateSQL:sqlLanguage];
    
    return isDeleteSuccess;
    
}

- (BOOL)deleteTable:(NSString *)tableName condition:(NSDictionary *)condition {
    
    NSString *sqlLanguage = _query.deletes(tableName).condition(condition).sql;
    BOOL isDeleteSuccess =  [self p_executeUpdateSQL:sqlLanguage];
    
    return isDeleteSuccess;
    

    
}

@end



