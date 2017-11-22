//
//  MFDBCacher.m
//  MKDataBase
//
//  Created by Mike on 21/11/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MKEmployee.h"
#import "MKDBWrapper.h"
@interface MKDBCacherTest : XCTestCase

@property (nonatomic, strong) MKDBWrapper *dataWrapper;
@property (nonatomic, assign) double beginTime;

@end

@implementation MKDBCacherTest

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _dataWrapper = [MKDBWrapper sharedInstance];
    _beginTime = CFAbsoluteTimeGetCurrent();
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInsertSomeObjecs{
    
    for (int i = 0; i < 50; i ++) {
        
        MKEmployee *employee = [[MKEmployee alloc]init];
        employee.name = [NSString stringWithFormat:@"name%d",i];
        employee.experience = i + 0.5f;
        employee.age = i + 20;
        employee.degree = i % 8;
        employee.position = [NSString stringWithFormat:@"position%d",i];
        BOOL success = [_dataWrapper insertWithObject:employee];
        NSLog(@"insert result: %@",success ? @"success":@"failure");
        
    }
}

- (void)testQueryObjectWithName {
    
    NSArray *models = [_dataWrapper queryObjectsWithName:@"MKEmployee"];
    XCTAssert(models.count, @"Failer at fetch models from database");
}

- (void)testQueryWithCondition{
    
    CFAbsoluteTime beginTime = CFAbsoluteTimeGetCurrent();
    for (int i = 0 ; i < 100; i ++) {
        
        MKSql *sql = [MKSql make].equ(@"age",@"36");
        NSArray *conditionResult = [_dataWrapper queryObjectsWithCondition:sql objName:@"MKEmployee"];
        NSLog(@"find result:%@",conditionResult);
        if (i == 99) {
            
            CFAbsoluteTime current = CFAbsoluteTimeGetCurrent();
            NSLog(@"consume time = %f",(current - beginTime) * 1000);
        }
    }
}

- (void)testUpdateWithNewCondition0{
    
    MKSql *sqlCondition = [MKSql make].equ(@"age",@"40");
    BOOL updateSuccessWithNewKeys = [_dataWrapper updateTable:@"MKEmployee" newKeyValue:@{@"name":@"MFDataBase",@"age":@(122)} condition:sqlCondition];
    NSAssert(updateSuccessWithNewKeys, @"update database failure");
}

- (void)testUpdateWithNewCondition{
    
    MKSql *sqlCondition = [MKSql make].equ(@"degree",@(7));
    BOOL updateSuccessWithNewKeys = [_dataWrapper updateTable:@"MKEmployee" newKeyValue:@{@"name":@"MJike",@"position":@"topCoder"} condition:sqlCondition];
    XCTAssert(updateSuccessWithNewKeys, @"update database failure");
    
}

- (void)testUpdateWithObject{
    
    MKEmployee *employee = [[MKEmployee alloc]init];
    employee.name = @"Jimme";
    employee.age = 132;
    employee.experience = 12.3;
    employee.degree = 10;
    employee.position = @"Coder";
    MKSql *sqlCondition = [MKSql make].equ(@"degree",@(132));
    BOOL updateSuccess = [_dataWrapper updateTableWithNewObjc:employee condition:sqlCondition];
    XCTAssert(updateSuccess, @"update with new Employee failure");
    
}

- (void)testQueryWithCondition2{
    
        for (int i = 0 ; i < 1000; i ++) {
    
            MKSql *sql = [[MKSql alloc]init].equGreat(@"age",@"10").equLess(@"age",@"80");
            [_dataWrapper queryObjectWithCondition:sql objName:@"MKEmployee" callBackBlock:^(id objc) {
                
            }];
            
            if (i == 999) {
    
                double current = CFAbsoluteTimeGetCurrent();
                NSLog(@"consume time = %f",(current - _beginTime) * 1000.0f);
                
                
            }
            
        }
    
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
