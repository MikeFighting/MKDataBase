//
//  MKDataBaseTests.m
//  MKDataBaseTests
//
//  Created by Mike on 12/29/16.
//  Copyright © 2016 Mike. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKSql.h"
@interface MKDataBaseTests : XCTestCase

@property (nonatomic, strong) MKSql *sql;

@end

@implementation MKDataBaseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)testSql{

    _sql = [[MKSql alloc]init];
    
    NSLog(@"-----%@",_sql.equ(@"12",@"12").result);
    
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
