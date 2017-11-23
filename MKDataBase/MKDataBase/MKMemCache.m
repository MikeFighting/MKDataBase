//
//  MKMemCache.m
//  MKDataBase
//
//  Created by MIke on 07/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MKMemCache.h"
#import "MKDBConnector.h"
#import "MKRunTimeTool.h"
#import <UIKit/UIKit.h>
@interface MKMemCache()
{
    dispatch_queue_t _queue;
}

@property(nonatomic, strong, readwrite) NSMutableDictionary *tables;
@property(nonatomic, strong) NSMutableArray *updateDatas;
@property(nonatomic, strong) NSMutableDictionary *primaryKeys; // key:TableName value:PrimaryKey
@property(nonatomic, strong) NSMutableDictionary *tableColumns; // key:TableName value:ColumnNames
@property(nonatomic, strong) MKDBConnector *dbConnector;
@property(nonatomic, assign) dispatch_queue_t globalQueue;

@end

static NSString *const MKUPDATE_KEY = @"MK_UPDATE_KEY";
static NSString *const MKDELETE_KEY = @"MK_DELETE_KEY";
static NSString *const MKINSERT_KEY = @"MK_INSERT_KEY";

static dispatch_semaphore_t _memeCacheLock;

void UncaughtExceptionHandler(NSException *exception) {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    MKMemCache *memCache = [MKMemCache sharedInstance];
    [memCache performSelector:NSSelectorFromString(@"synMemAndDataBase")];
#pragma clang diagnostic pop
    
}

@implementation MKMemCache

+ (instancetype)sharedInstance {

    static MKMemCache *memCache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        memCache = [[MKMemCache alloc]init];
    
    });
    return memCache;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        [self p_initResources];
    }
    return self;
}

#pragma mark - public method
-(BOOL)warmUpMemeCache {
    
    NSAssert(self.tableClasses.count, @"Please set all the tables' name firstly");
    NSAssert(self.dbPath.length, @"Please set the database path firstly");
    @try {
        
        for (Class Table in self.tableClasses) {
            
            NSString *tableName = NSStringFromClass(Table);
            NSArray *models = [_dbConnector queryObjectsWithName:tableName];
            [self.tables setObject:models forKey:tableName];
            NSArray *properties = [MKRunTimeTool getPropertiesWithClassName:tableName];
            [self.tableColumns setObject:properties forKey:tableName];
            
        }
        
        return YES;
        
    } @catch (NSException *exception) {
        NSLog(@"MKDBConnector: %@--%@",exception.name, exception.reason);
        return NO;
    }
}

- (NSArray *)queryTable:(NSString *)table withRegx:(NSString *)regex {

    NSAssert(NSClassFromString(table), @"The table name you input is wrong!");
    NSAssert(regex.length, @"the regx you use cannot be nil");
    
    __block NSArray *resultArray = nil;
    dispatch_sync(_globalQueue, ^{
        
        NSArray *tableDatas = [self.tables objectForKey:table];
        NSPredicate *predicte = [NSPredicate predicateWithFormat:regex];
        resultArray = [tableDatas filteredArrayUsingPredicate:predicte];
    });
    
    return resultArray;
}

- (NSArray *)queryTable:(NSString *)table withPredicate:(NSPredicate *)prediact {
    
    NSAssert(NSClassFromString(table), @"The table name you input is wrong!");
    NSAssert(prediact != nil, @"the regx you use cannot be nil");
    __block NSArray *resultArray = nil;
    dispatch_sync(_globalQueue, ^{
        
        NSArray *tableDatas = [self.tables objectForKey:table];
        resultArray = [tableDatas filteredArrayUsingPredicate:prediact];
        
    });
    
    return resultArray;
}

- (void)insertObject:(id)object primaryKey:(NSString *)property {
    
    NSString *tableName = NSStringFromClass([object class]);
    NSAssert([[_tables allKeys] containsObject:tableName], @"The object you inset did not exist!");
    NSArray *tableColumns = [self.tableColumns objectForKey:tableName];

    if (![tableColumns containsObject:property]) {
        
        [NSException raise:NSInvalidArgumentException format:@"The primary key you set is illegel"];
    }
    
    dispatch_barrier_async(_globalQueue, ^{
        
        [_updateDatas addObject:@{MKINSERT_KEY:object}];
        NSMutableArray *originArray = [NSMutableArray arrayWithArray:[_tables objectForKey:tableName]];
        [originArray addObject:object];
        [_tables setObject:originArray forKey:tableName];
        [_primaryKeys setObject:property forKey:tableName];
        
    });
}

- (void)insertObject:(id)object primaryKey:(NSString *)property handler:(MKOperationResultBlock)resultBlock {

    NSString *tableName = NSStringFromClass([object class]);
    NSAssert([[_tables allKeys] containsObject:tableName], @"The object you inset did not exist!");
    dispatch_barrier_async(_globalQueue, ^{
        
        [_updateDatas addObject:@{MKINSERT_KEY:object}];
        NSMutableArray *originArray = [NSMutableArray arrayWithArray:[_tables objectForKey:tableName]];
        [originArray addObject:object];
        [_tables setObject:originArray forKey:tableName];
        [_primaryKeys setObject:property forKey:tableName];
        resultBlock(YES);
    });
}

- (void)deletObject:(id)object {
    
    NSString *tableName = NSStringFromClass([object class]);
    NSAssert([[_tables allKeys] containsObject:tableName], @"The object you inset did not exist!");
    dispatch_barrier_async(_globalQueue, ^{
        
        [_updateDatas addObject:@{MKDELETE_KEY:object}];
        NSMutableArray *originArray = [NSMutableArray arrayWithArray:[_tables objectForKey:tableName]];
        [originArray removeObject:object];
        [_tables setObject:originArray forKey:tableName];
        
    });
}

- (void)updateObject:(id)object withDic:(NSDictionary *)newDic {
    
    dispatch_barrier_async(_globalQueue, ^{
        
        [_updateDatas addObject:@{MKUPDATE_KEY:object}];
        NSLog(@"Called the UpdateObject method");
        
    });
    
}

- (void)p_updateDataBase {

    if (_updateDatas.count == 0) {
        return;
    }
    
    NSInteger updateNum = 0;
    for (int i = 0 ; i < _updateDatas.count; i ++) {
        
        NSDictionary *updateDic = _updateDatas[i];
        [updateDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * _Nonnull stop) {
            
            if ([key isEqualToString:MKUPDATE_KEY]) {
                NSLog(@"更新了一条数据");
                
                [_dbConnector updateTableWithNewObjc:obj condition:nil];
                
            }else if ([key isEqualToString:MKINSERT_KEY]) {
                
                NSLog(@"准备添加一条数据");
                [_dbConnector insertWithObject:obj];
                NSLog(@"添加了一条数据");
                
            }else if ([key isEqualToString:MKDELETE_KEY]) {
                
                [_dbConnector deleteOjbect:obj];
                NSLog(@"删除了一条数据");
            }
            
        }];
        
        updateNum += 1;
    }
    [_updateDatas removeObjectsInRange:NSMakeRange(0, updateNum)];
}

- (void)asynMemAndDataBase {
    
    dispatch_async(_queue, ^{
       
        [self p_updateDataBase];
    });
    
}

- (void)synMemAndDataBase {

    dispatch_sync(_queue, ^{
        
        [self p_updateDataBase];
    });
}

#pragma mark - private method
- (void)p_initResources {
    
    [self tables];
    [self dbConnector];
    [self globalQueue];
    [self queue];
    [self updateDatas];
    [self tableColumns];
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    /*
     *Update the database if the App enter background or we received memory warning.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asynMemAndDataBase) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(asynMemAndDataBase) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    //TODO:asynMemAndDataBase if the runloop is idel.
    
}

#pragma mark - getter & setter
- (NSMutableDictionary *)tables {
    
    if (!_tables) {
        _tables = [NSMutableDictionary dictionary];
    }
    return _tables;
}

- (MKDBConnector *)dbConnector {

    if (!_dbConnector) {
        _dbConnector = [MKDBConnector sharedInstance];
    }
    return _dbConnector;
}

- (dispatch_queue_t)globalQueue {

    if (!_globalQueue) {
        _globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return _globalQueue;
}

- (dispatch_queue_t)queue {

    if (!_queue) {
        _queue = dispatch_queue_create([[NSString stringWithFormat:@"mkmemcache.%@",self] UTF8String], NULL);
    }
    return _queue;
}

- (NSMutableArray *)updateDatas {

    if (!_updateDatas) {
        _updateDatas = [NSMutableArray array];
    }
    return _updateDatas;
}

- (NSMutableDictionary *)primaryKeys {

    if (!_primaryKeys) {
        _primaryKeys = [NSMutableDictionary dictionary];
    }
    return _primaryKeys;
}

- (NSMutableDictionary *)tableColumns {

    if (!_tableColumns) {
        _tableColumns = [NSMutableDictionary dictionary];
    }
    return _tableColumns;
}
@end
