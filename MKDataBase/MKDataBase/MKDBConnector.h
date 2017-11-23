//
//  MKDBConnector.h
//  Pods
//
//  Created by Mike on 7/6/16.
//
//

#import <Foundation/Foundation.h>
#import "MKQuerySql.h"
#import "MKRangeSql.h"

NS_ASSUME_NONNULL_BEGIN
/**
 This adaptor is used for connet with data base tool such as FMDB, Realm etc.
 */
@interface MKDBConnector: NSObject

- (instancetype)init __attribute ((unavailable("init is not available call sharedDatabaseManager instead")));

@property (nonatomic, strong, readonly) MKQuerySql *query;

+ (MKDBConnector *)sharedInstance;

/**
 You MUST launch the data base before you use it.

 @param dbPath The database's path
 */
- (void)launchDataBaseWithPath:(NSString *)dbPath;
// if the table is exists
- (BOOL)isTableExistsWithName:(NSString *)tableName ;
- (BOOL)isCreateTableSuccessWithObject:(id)object;

@end

@interface MKDBConnector (Add)

- (BOOL)insertWithObject:(id)object;

- (BOOL)addColumWithTableName:(NSString *)tableName columName:(NSArray *)names type:(NSArray *)types defaluts:(NSArray *)defaultValues;

@end

@interface MKDBConnector (Query)

- (NSArray *)queryObjectsWithName:(NSString *)className;

- (void)queryObjectsInBackGroundWithName:(NSString *)className callBack:(void(^)(NSArray *))callBackBlock;

- (NSArray *)queryObjectsWithCondition:(MKRangeSql *)condition objName:(NSString *)className;

- (void)queryObjectsInBackGroundWithCondition:(MKRangeSql *)condition objName:(NSString *)className callBack:(void(^)(NSArray *foundObjcts))callBackBlock;

- (id)queryObjectWithCondition:(MKRangeSql *)condition objName:(NSString *)className;

- (void)queryObjectWithCondition:(MKRangeSql *)condition objName:(NSString *)className callBackBlock:(void(^)(id objc))callBackBlock;

@end

@interface MKDBConnector (Update)

- (BOOL)updateTable:(NSString *)tableName newKeyValue:(NSDictionary *)newValuesDic condition:(MKRangeSql *)condition;

- (BOOL)updateTableWithNewObjc:(id)tableObject condition:(MKRangeSql *)condition;

@end

@interface MKDBConnector (Delete)

- (BOOL)deleteOjbect:(id)object;
- (BOOL)deleteTable:(NSString *)tableName condition:(MKRangeSql *)condition;

@end

NS_ASSUME_NONNULL_END
