//
//  MKMemCacheTest.m
//  MKDataBase
//
//  Created by MIke on 07/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKMemCache.h"
@interface MKMemCacheTest : XCTestCase

@property (nonatomic, strong) MKMemCache *memCache;

@end

@implementation MKMemCacheTest

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *doucmentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"db path : %@",doucmentpath);
    NSString *dbPath = [doucmentpath stringByAppendingPathComponent:@"MKDBWrapper.db"];
    _memCache = [[MKMemCache alloc]init];
    _memCache.tableClasses = @[NSClassFromString(@"MKEmployee")];
    _memCache.dbPath = dbPath;
    [_memCache warmUpMemeCache];
    
}

- (void)testWarmUp {

    [_memCache warmUpMemeCache];
}

- (void)testProduceAndConsumer {

    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_barrier_async(queue, ^{
       
        
        for (int i = 0; i < 100000; i ++) {
            
            [array addObject:@(i)];
        }
    });
    
    dispatch_barrier_async(queue, ^{
        
        for (int i = 0; i < array.count; i ++) {
            
            sleep(0.01);
            NSLog(@"number %@",array[i]);
        }
        
    });
    
}

- (void)testQueryTableWithRegex {

    NSString *string = [NSString stringWithFormat:@" age BETWEEN {20, 30}"];
    NSArray *datas = [_memCache queryTable:@"MKEmployee" withRegx:string];
    XCTAssertTrue(datas,@"使用Predicate来查找MKEmployee");
}

- (void)testQueryAndUpdate {
    
    NSString *string = [NSString stringWithFormat:@" age BETWEEN {20, 30}"];
    NSArray *datas = [_memCache queryTable:@"MKEmployee" withRegx:string];
    XCTAssertTrue(datas,@"使用Predicate来查找MKEmployee");
    
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
