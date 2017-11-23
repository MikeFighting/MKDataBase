//
//  MKFSQLTool.h
//  FMDBDemo
//
//  Created by Mike on 12/27/16.
//  Copyright © 2016 vera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRangeSql.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MKRangeType){
    
    MKRangeTypeDefault = 0, // >= && <=
    MKRangeTypeMoreEquleAndLess = 1, // >= && <
    MKRangeTypeMoreAndLessEqule = 2, // > && <=
    MKRangeTypeMoreAndLess = 3  // > && <
    
};

NS_ASSUME_NONNULL_END


@class MKQuerySql;

typedef MKQuerySql *_Nonnull(^Select)(NSArray <NSString *> * _Nonnull colums);
typedef MKQuerySql *_Nonnull(^SelectM)(NSString * _Nullable tableName);
typedef MKQuerySql *_Nonnull(^From)(NSString * _Nonnull tableName);
typedef MKQuerySql *_Nonnull(^InsertDic)(NSString * _Nullable _Nonnulltable, NSDictionary * _Nonnull keyValueDic);
typedef MKQuerySql *_Nonnull(^InsertObj)(id _Nonnull dataModel);
typedef MKQuerySql *_Nonnull(^ReplaceInsertDic)(NSString * _Nullable table, NSDictionary * _Nonnull keyValueDic);
typedef MKQuerySql *_Nonnull(^RplaceInserObj)(id _Nonnull dataModel);
typedef MKQuerySql *_Nonnull(^Exist)(NSString * _Nonnull table);
typedef MKQuerySql *_Nonnull(^Condition)(MKRangeSql * _Nonnull sqlCondition);
typedef MKQuerySql *_Nonnull(^Creat) (id _Nonnull dataBaseModel);
typedef MKQuerySql *_Nonnull(^Update) (NSString * _Nonnull tableName,NSDictionary * _Nonnull newKeyValue);
typedef MKQuerySql *_Nonnull(^UpdateObj)(id _Nonnull tableObjc);
typedef MKQuerySql *_Nonnull(^Delete)(NSString * _Nonnull tableName);
typedef MKQuerySql *_Nonnull(^DeleteObj)(id _Nonnull dataModel);

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *const MKDBCacherPrimaryKey;

@interface MKQuerySql : NSObject

@property (nonatomic, copy) NSArray *array;

/**
 The result sql language to be executed.
 */
@property (nonatomic, copy, readonly) NSString *sql;

/**
 The select syntax for database.
 Parameter: (NSArray <NSString *> *colums
 */
@property (nonatomic, copy) Select select;

/**
 Select the model in the database.
 Parameter: NSString *tableName
 */
@property (nonatomic, copy) SelectM selectM;

/**
 The table's name needed to be query.
 Parameter: NSString *tableName
 */
@property (nonatomic, copy) From from;

/**
 Insert into new data from dictionary.
 Parameter: NSString *table, NSDictionary *keyValueDic
 */
@property (nonatomic, copy) InsertDic insertDic;

/**
 Insert into new data from objc.
 id dataModel
 */
@property (nonatomic, copy) InsertObj insertObjc;

/**
 Replace insert new data from dictionary.
 NSString *table, NSDictionary *keyValueDic
 */
@property (nonatomic, copy) ReplaceInsertDic replaceInsertDic;
/**
 Replce the object saved to database and isnert the new object
 id dataModel
 */
@property (nonatomic, copy) RplaceInserObj replaceInsertObj;

/**
 If the table exist.
 Parameter: NSString *table
 */
@property (nonatomic, copy) Exist exist;

/**
 Set the condition for the query.
 Parameter: NSDictionary *condition
 */
@property (nonatomic, copy) Condition condition;

/**
 Creat table by object.
 Parameter: id dataBaseModel
 */
@property (nonatomic, copy) Creat creat;


/**
 Update the table.
 NSString *tableName
 */

@property (nonatomic, copy) Update update;

/**
 Update table with the new objcet.
 id tableObjc
 */
@property (nonatomic, copy) UpdateObj updateObj;

/**
 Delete data model
 NSString *tableName
 */
@property (nonatomic, copy) Delete deletes;

/**
 Delte data model
 id dataModel
 */
@property (nonatomic, copy) DeleteObj deleteObj;

/**
 Reset the sql language to empty.
 */
- (void)resetSql;



@end

NS_ASSUME_NONNULL_END
