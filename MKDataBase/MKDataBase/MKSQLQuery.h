//
//  MKFSQLTool.h
//  FMDBDemo
//
//  Created by Mike on 12/27/16.
//  Copyright © 2016 vera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKRange.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MKRangeType){
    
    MKRangeTypeDefault = 0, // >= && <=
    MKRangeTypeMoreEquleAndLess = 1, // >= && <
    MKRangeTypeMoreAndLessEqule = 2, // > && <=
    MKRangeTypeMoreAndLess = 3  // > && <
    
};

NS_ASSUME_NONNULL_END


@class MKSQLQuery;

typedef MKSQLQuery *(^Select)(NSArray <NSString *> *colums);
typedef MKSQLQuery *(^SelectM)(NSString *tableName);
typedef MKSQLQuery *(^From)(NSString *tableName);
typedef MKSQLQuery *(^InsertDic)(NSString *table, NSDictionary *keyValueDic);
typedef MKSQLQuery *(^InsertObj)(id dataModel);
typedef MKSQLQuery *(^ReplaceInsertDic)(NSString *table, NSDictionary *keyValueDic);
typedef MKSQLQuery *(^RplaceInserObj)(id dataModel);
typedef MKSQLQuery *(^Exist)(NSString *table);
typedef MKSQLQuery *(^Condition)(NSDictionary *condition);
typedef MKSQLQuery *(^Range)(MKRangeType type,MKRange *range);
typedef MKSQLQuery *(^Creat) (id dataBaseModel);
typedef MKSQLQuery *(^Update) (NSString *tableName,NSDictionary *newKeyValue);
typedef MKSQLQuery *(^UpdateObj)(id tableObjc);
typedef MKSQLQuery *(^Delete)(NSString *tableName);

NS_ASSUME_NONNULL_BEGIN
@interface MKSQLQuery : NSObject

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
 Set the range of for the query.
 Parameter: MKRangeType type,MKRange *range
 */
@property (nonatomic, copy) Range range;

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
 Reset the sql language to empty.
 */
- (void)resetSql;



@end

NS_ASSUME_NONNULL_END
