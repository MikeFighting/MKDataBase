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

@property(nonatomic, strong, readwrite) NSMutableDictionary *tables;
@property(nonatomic, strong) MKDBWrapper *dbWrapper;

@end

@implementation MKMemCache

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
    
    NSArray *tableDatas = [self.tables objectForKey:table];
    NSPredicate *predicte = [NSPredicate predicateWithFormat:regex];
    NSArray *resultArray = [tableDatas filteredArrayUsingPredicate:predicte];
    return resultArray;
}

- (NSArray *)queryTable:(NSString *)table withPredicate:(NSPredicate *)prediact {
    
    NSAssert(NSClassFromString(table), @"The table name you input is wrong!");
    NSAssert(prediact != nil, @"the regx you use cannot be nil");
    NSArray *tableDatas = [self.tables objectForKey:table];
    NSArray *resultArray = [tableDatas filteredArrayUsingPredicate:prediact];
    return resultArray;
}


- (void)insertObject:(id<MKDBModelProtocol>)object {

    NSStringFromClass(object.class);
    
    
}

- (void)deletObject:(id)object {
    
    

}

- (void)updateObject:(id)object withDic:(NSDictionary *)newDic {

}

- (void)p_initResources {

    [self tables];
    [self dbWrapper];
}

#pragma mark - private method



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
@end
