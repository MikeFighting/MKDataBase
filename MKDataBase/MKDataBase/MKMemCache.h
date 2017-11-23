//
//  MKMemCache.h
//  MKDataBase
//
//  Created by MIke on 07/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MKOperationResultBlock)(BOOL result);
@interface MKMemCache : NSObject

@property(nonatomic, strong, readonly) NSMutableDictionary *tables;
@property(nonatomic, strong) NSArray *tableClasses;

/**
 The data base's path, default: NSDocumentDirectory
 */

+ (instancetype)sharedInstance;
- (BOOL)warmUpMemeCache;

- (NSArray *)queryTable:(NSString *)table withPredicate:(NSPredicate *)prediact;
- (NSArray *)queryTable:(NSString *)table withRegx:(NSString *)regx;

- (void)insertObject:(id)object;
- (void)insertObject:(id)object handler:(MKOperationResultBlock)resultBlock;

- (void)deletObject:(id)object;
- (void)updateWithNewObject:(id)object;
- (void)update:(NSString *)table WithId:(NSInteger)ID newDic:(NSDictionary *)newDic;
- (void)updateObject:(id)object withDic:(NSDictionary *)newDic;

@end
