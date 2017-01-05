//
//  MKDataBaseManager.h
//  Pods
//
//  Created by Mike on 7/6/16.
//
//

#import <Foundation/Foundation.h>
#import "MKSQLQuery.h"
#import "MKRange.h"

@interface MKDataBaseManager: NSObject

- (instancetype)init __attribute ((unavailable("init is not available call sharedDatabaseManager instead")));

@property (nonatomic, strong, readonly) MKSQLQuery *query;

+ (MKDataBaseManager *)sharedDatabaseManager;

// if the table is exists
- (BOOL)isTableExistsWithName:(NSString *)tableName;

/**
 *  @param the object need to creat table
 *
 *  @return is success
 */
- (BOOL)isCreateTableSuccessWithObject:(id)object;

@end

@interface MKDataBaseManager (Add)

/**
 insert object
 */
- (BOOL)insertWithObject:(id)object;

/*
 add colum when update version
 */
- (BOOL)addColumWithTableName:(NSString *)tableName columName:(NSArray *)names type:(NSArray *)types defaluts:(NSArray *)defaultValues;


@end

@interface MKDataBaseManager (Query)

/**
 *  query all the datas
 *
 *  @param className the class name
 *
 *  @return the object's array
 */
- (NSArray *)queryObjectsWithName:(NSString *)className;

- (void)queryObjectsInBackGroundWithName:(NSString *)className callBack:(void(^)(NSArray *))callBackBlock;


/**
 *  query all the datas wich can satisfy the conditionary
 *
 *  @param className    the class name
 *  @param conditionary the condition
 *
 *  @return the arrary contains all the objects
 */
- (NSArray *)queryObjectsWithCondition:(NSDictionary *)condition objName:(NSString *)objcName;

- (void)queryObjectsInBackGroundWithCondition:(NSDictionary *)condition objName:(NSString *)objcName callBack:(void(^)(NSArray *foundObjcts))callBackBlock;
/**
 *
 *  @param className the tableName
 *  @param startDate the starting period
 *  @param endDate   the end period
 *  @param condition the condition, the userid, typically
 *
 *  @return the objects array
 */
- (NSArray *)queryObjectsWithRange:(MKRange *)range condition:(NSDictionary *)conditionDic objName:(NSString *)objcName;


- (void)queryObjectsWithRange:(MKRange *)range condition:(NSDictionary *)conditionDic objName:(NSString *)objcName callBackBlock:(void(^)(NSArray *foundObjcs))callBackBlock;

/**
 *  @param className the tableName
 *  @param startDate the starting period
 *  @param endDate   the end period
 *  @param condition the condition, the userid, typically
 *  @param startId the start id
 *  @param endId the end id
 *  @return the objects array
 *
 */

- (NSArray *)queryObjectsWithRanges:(NSArray <MKRange *> *)ranges condition:(NSDictionary *)conditionDic objName:(NSString *)objcName;

- (void)queryObjectsWithRanges:(NSArray <MKRange *> *)ranges condition:(NSDictionary *)conditionDic objName:(NSString *)objcName callBackBlock:(void(^)(NSArray *foundObjcs))callBackBlock;

/**
 *  query one object frome the database
 *
 *  @param className           the class name is the table name
 *  @param conditionDictionary the condition for filter
 *
 *  @return the object which satisfy the condition
 */

- (id)queryObjectWithCondition:(NSDictionary *)condition objName:(NSString *)objcName;

- (void)queryObjectWithCondition:(NSDictionary *)condition objName:(NSString *)objcName callBackBlock:(void(^)(id objc))callBackBlock;

@end

@interface MKDataBaseManager (Update)

/**
 Update  some database models for some propertys with the new dictionary, and the models are filtered by the conditionary.
 
 @param tableObject            the database model object
 @param newValuesDic           property and its new values
 @param conditioanryDictionary the condition to filter the objects.

 @return if the update operation is susccess.
 */

- (BOOL)updateTable:(NSString *)tableName newKeyValue:(NSDictionary *)newValuesDic condition:(NSDictionary *)condition;

/**
 * update the datebase with a new tableObject
 */
/**
 Update the specific model which is filtered by the condition with the condition, by the new database model.

 @param tableObject            the new database model
 @param conditioanryDictionary the dictionary to filter the specific model

 @return if the update operation is success.
 */
- (BOOL)updateTableWithNewObjc:(id)tableObject condition:(NSDictionary *)condition;

@end

@interface MKDataBaseManager (Delete)

/**
 *  delte the data from some database
 */

- (BOOL)deleteTable:(NSString *)tableName condition:(NSDictionary *)condition;

- (BOOL)deleteTable:(NSString *)tableName range:(MKRange *)range condition:(NSDictionary *)condition;

@end

