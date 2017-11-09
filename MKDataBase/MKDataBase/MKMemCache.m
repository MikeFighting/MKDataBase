//
//  MKMemCache.m
//  MKDataBase
//
//  Created by MIke on 07/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MKMemCache.h"
#import "MKDBWrapper.h"

@interface MKMemCache()
{
    dispatch_queue_t _queue;
}

@property(nonatomic, strong, readwrite) NSMutableDictionary *tables;
@property(nonatomic, strong) NSMutableArray *updateDatas;
@property(nonatomic, strong) MKDBWrapper *dbWrapper;
@property(nonatomic, assign) dispatch_queue_t globalQueue;

@end

static NSString const *MKUPDATE_KEY = @"MK_UPDATE_KEY";
static NSString const *MKDELETE_KEY = @"MK_DELETE_KEY";
static NSString const *MKINSERT_KEY = @"MK_INSERT_KEY";

static dispatch_semaphore_t _memeCacheL

void UncaughtExceptionHandler(NSException *exception) {

    [[MKMemCache sharedInstance] updateDatas];
}

@implementation MKMemCache

+ (instancetype)sharedInstance {

    __block MKMemCache *memCache = nil;
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
-(void)warmUpMemeCache {
    
    NSAssert(self.tableClasses.count, @"Please set all the tables' name firstly");
    NSAssert(self.dbPath.length, @"Please set the database path firstly");
    
    for (Class Table in self.tableClasses) {
        
        NSString *tableName = NSStringFromClass(Table);
        NSArray *models = [_dbWrapper queryObjectsWithName:tableName];
        [self.tables setObject:models forKey:tableName];
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


- (void)insertObject:(id<MKDBModelProtocol>)object {

   NSStringFromClass(object.class);
   dispatch_barrier_async(_globalQueue, ^{
       
       [_updateDatas addObject:@{MKINSERT_KEY:object}];
       
   });
    
}

- (void)deletObject:(id)object {
    
    dispatch_barrier_async(_globalQueue, ^{
        
        [_updateDatas addObject:@{MKDELETE_KEY:object}];
        
    });

}

- (void)updateObject:(id)object withDic:(NSDictionary *)newDic {
    
    dispatch_barrier_async(_globalQueue, ^{
        
        [_updateDatas addObject:@{MKUPDATE_KEY:object}];
        NSLog(@"Called the UpdateObject method");
        
    });
    
}

- (void)synMemAndDataBase {
    
    dispatch_async(_queue, ^{
       
        if (_updateDatas.count == 0) {
            return;
        }
        
        NSInteger updateNum = 0;
        
        for (int i = 0 ; i < _updateDatas.count; i ++) {
           
            NSDictionary *updateDic = _updateDatas[i];
            [updateDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * _Nonnull stop) {
                
                if ([key isEqualToString:@"MK_UPDATE_KEY"]) {
                    NSLog(@"更新了一条数据");
                    
                    [_dbWrapper updateTableWithNewObjc:obj condition:nil];
                }else if ([key isEqualToString:@"MKINSERT_KEY"]) {
                    NSLog(@"添加了一条数据");
                    [_dbWrapper insertWithObject:obj];
                }else if ([key isEqualToString:MKDELETE_KEY]) {
                    NSLog(@"更新了一条数据");
                    
        
                }
                
            }];
            
            updateNum += 1;
        }
        
        
        
        
    
    });
    
}

#pragma mark - private method
- (void)p_initResources {
    
    [self tables];
    [self dbWrapper];
    [self globalQueue];
    [self updateDatas];
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    /*
     *Update the database if the App enter background or we received memory warning.
     */
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synMemAndDataBase) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(synMemAndDataBase) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    //TODO:synMemAndDataBase if the runloop is idel.
    
}

#pragma mark - getter & setter
- (NSMutableDictionary *)tables {
    
    if (!_tables) {
        _tables = [NSMutableDictionary dictionary];
    }
    return _tables;
}

- (MKDBWrapper *)dbWrapper {

    if (!_dbWrapper) {
        _dbWrapper = [MKDBWrapper sharedInstance];
    }
    return _dbWrapper;
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

@end
