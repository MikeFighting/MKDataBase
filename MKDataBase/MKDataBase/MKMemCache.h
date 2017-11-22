//
//  MKMemCache.h
//  MKDataBase
//
//  Created by MIke on 07/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDBModelProtocol.h"

typedef void(^MKOperationResultBlock)(BOOL result);
@interface MKMemCache : NSObject

@property(nonatomic, strong, readonly) NSMutableDictionary *tables;
@property(nonatomic, strong) NSArray *tableClasses;
@property(nonatomic, copy) NSString *dbPath;

+ (instancetype)sharedInstance;
- (BOOL)warmUpMemeCache;
- (NSArray *)queryTable:(NSString *)table withPredicate:(NSPredicate *)prediact;
- (NSArray *)queryTable:(NSString *)table withRegx:(NSString *)regx;

- (void)insertObject:(id<MKDBModelProtocol>)object;
- (void)insertObject:(id<MKDBModelProtocol>)object handler:(MKOperationResultBlock)resultBlock;
- (void)deletObject:(id)object;
- (void)updateObject:(id)object withDic:(NSDictionary *)newDic;

@end
