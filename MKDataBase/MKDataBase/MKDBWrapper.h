//
//  MKDBWrapper.h
//  Pods
//
//  Created by Mike on 7/6/16.
//
//

#import <Foundation/Foundation.h>
#import "MKSQLQuery.h"
#import "MKSql.h"
@interface MKDBWrapper: NSObject

- (instancetype)init __attribute ((unavailable("init is not available call sharedDatabaseManager instead")));

@property (nonatomic, strong, readonly) MKSQLQuery *query;

+ (MKDBWrapper *)sharedInstance;

// if the table is exists
- (BOOL)isTableExistsWithName:(NSString *)tableName;

- (BOOL)isCreateTableSuccessWithObject:(id)object;

@end

@interface MKDBWrapper (Add)

- (BOOL)insertWithObject:(id)object;

- (BOOL)addColumWithTableName:(NSString *)tableName columName:(NSArray *)names type:(NSArray *)types defaluts:(NSArray *)defaultValues;

@end

@interface MKDBWrapper (Query)

- (NSArray *)queryObjectsWithName:(NSString *)className;

- (void)queryObjectsInBackGroundWithName:(NSString *)className callBack:(void(^)(NSArray *))callBackBlock;

- (NSArray *)queryObjectsWithCondition:(MKSql *)condition objName:(NSString *)className;

- (void)queryObjectsInBackGroundWithCondition:(MKSql *)condition objName:(NSString *)className callBack:(void(^)(NSArray *foundObjcts))callBackBlock;


- (id)queryObjectWithCondition:(MKSql *)condition objName:(NSString *)className;

- (void)queryObjectWithCondition:(MKSql *)condition objName:(NSString *)className callBackBlock:(void(^)(id objc))callBackBlock;

@end

@interface MKDBWrapper (Update)

- (BOOL)updateTable:(NSString *)tableName newKeyValue:(NSDictionary *)newValuesDic condition:(MKSql *)condition;

- (BOOL)updateTableWithNewObjc:(id)tableObject condition:(MKSql *)condition;

@end

@interface MKDBWrapper (Delete)

- (BOOL)deleteTable:(NSString *)tableName condition:(NSDictionary *)condition;

@end

