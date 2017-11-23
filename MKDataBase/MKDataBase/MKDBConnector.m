//
//  MKDBConnector.m
//  Pods
//
//  Created by Mike on 7/6/16.
//
//

#import "MKDBConnector.h"
#import "FMDatabase.h"
#import "MKQuerySql.h"
#import <objc/runtime.h>

@interface MKDBConnector () {
    
    FMDatabase *_database;
    dispatch_queue_t _mkqueue;
    NSLock *_lock;
    NSArray *_ignoreProperties;
}

@property (nonatomic, strong, readwrite) MKQuerySql *query;

@end

@implementation MKDBConnector


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
        _query = [[MKQuerySql alloc]init];
        _mkqueue = dispatch_queue_create("com.mike.mkdatabase.queue", DISPATCH_QUEUE_CONCURRENT);
        _lock = [[NSLock alloc]init];
        _ignoreProperties = @[@"hash",@"description",@"superclass",@"debugDescription"];
    }
    return self;
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
+ (MKDBConnector *)sharedInstance
{
    static dispatch_once_t onceToken;
    static MKDBConnector *connector = nil;
    dispatch_once(&onceToken, ^{
        connector = [[self alloc] init];
    });
    return connector;
}

- (void)launchDataBaseWithPath:(NSString *)dbPath {

    _database = [FMDatabase databaseWithPath:dbPath];
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

@implementation MKDBConnector (Add)

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

@implementation MKDBConnector (Query)

/**
 query all the objects, which satisfy the conditions
 */
- (NSArray *)queryObjectsWithCondition:(MKRangeSql *)condition objName:(NSString *)objcName {

    [_lock lock];
    NSString *sqlLanguage = _query.selectM(objcName).condition(condition).sql;
    FMResultSet *results = [self p_executeQuerySQL:sqlLanguage];
    NSArray *reultModels = [self p_getObjcsWithResutltSet:results className:objcName];
    [_database close];
    [_lock unlock];
    return reultModels;
    

}

- (void)queryObjectsInBackGroundWithCondition:(MKRangeSql *)condition objName:(NSString *)objcName callBack:(void(^)(NSArray *foundObjcts))callBackBlock{
    
    if (!callBackBlock) return;
    __weak typeof(self) weakSelf = self;
    dispatch_async(_mkqueue, ^{
    
        __strong typeof(weakSelf) self = weakSelf;
        NSArray *foundObjs = [self queryObjectsWithCondition:condition objName:objcName];
        callBackBlock(foundObjs);
    });
    
    
}

- (NSArray *)p_getObjcsWithResutltSet:(FMResultSet *)resultSet className:(NSString *)className {

    NSAssert(resultSet, @"The inputed resultSet can not be Nil");
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
            NSString *attributeName = attributes[i];
            NSString *valueString = [resultSet stringForColumn:attributeName];
            if (valueString.length == 0) valueString = @"";
            // set the value
            if (![_ignoreProperties containsObject:attributeName]) {
               [obj setValue:valueString forKey:attributeName];
            }
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
- (id)queryObjectWithCondition:(MKRangeSql *)condition objName:(NSString *)objcName {

    NSArray *conditionResultArray =  [self queryObjectsWithCondition:condition objName:objcName];
    return [conditionResultArray firstObject];
}

- (void)queryObjectWithCondition:(MKRangeSql *)condition objName:(NSString *)objcName callBackBlock:(void(^)(id objc))callBackBlock{
    
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
@implementation MKDBConnector (Update)

- (BOOL)updateTable:(NSString *)tableName newKeyValue:(NSDictionary *)newValuesDic condition:(MKRangeSql *)condition {

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
- (BOOL)updateTableWithNewObjc:(id)tableObject condition:(MKRangeSql *)condition{

    NSString *sqlLanguage = _query.updateObj(tableObject).condition(condition).sql;
    // assemble the sql language
    BOOL isUpdateSuccess = [self p_executeUpdateSQL:sqlLanguage];
    [_database close];
    return isUpdateSuccess;
}

@end

@implementation MKDBConnector (Delete)

- (BOOL)deleteTable:(NSString *)tableName condition:(MKRangeSql *)condition {
    
    NSString *sqlLanguage = _query.deletes(tableName).condition(condition).sql;
    BOOL isDeleteSuccess =  [self p_executeUpdateSQL:sqlLanguage];
    return isDeleteSuccess;
}

- (BOOL)deleteOjbect:(id)object {

    NSString *sqlLanguage = _query.deleteObj(object).sql;
    BOOL isDeleteSuccess =  [self p_executeUpdateSQL:sqlLanguage];
    return isDeleteSuccess;
    
}

@end



