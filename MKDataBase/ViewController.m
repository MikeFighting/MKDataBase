//
//  ViewController.m
//  FMDBDemo
//
//  Created by vera on 15/8/5.
//  Copyright (c) 2015年 vera. All rights reserved.
//

#import "ViewController.h"
#import "MKDBConnector.h"
#import "MKEmployee.h"
#import "MKMemCache.h"

@interface ViewController ()

@property (nonatomic, strong) MKDBConnector *dbConnector;
@property (nonatomic, strong) MKMemCache *memCache;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
//    _dbConnector = [MKDBConnector sharedInstance];
//    _memCache = [MKMemCache sharedInstance];
//    _memCache.tableClasses = @[NSClassFromString(@"MKEmployee")];
//    BOOL isCreatScuccess = [_dbConnector isCreateTableSuccessWithObject:[MKEmployee new]];
//    BOOL warmUpSuccess = [_memCache warmUpMemeCache];
 //   [self testInsertObject];
    
//    [self testDeletedObject];
//    [self testUpdateObject];
//    [self crashAfterAWhile];
//    [self testUpdateObjectWithDic];
//
    [self testQueryAndAdd];
    
}

- (void)crashAfterAWhile {
 
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSArray *wrongArray = @[@"1",@"2"];
        NSString *tempt = [wrongArray objectAtIndex:2];
        NSLog(@"tempt == %@",tempt);
    });
    
}

- (void)testQueryAndAdd {

    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_barrier_async(queue, ^{
  
        for (int i = 0; i < 1000; i ++) {
            
            [array addObject:@(i)];
        }
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i < 100; i ++) {
            
            NSInteger count = array.count;
            [array removeObjectsInRange:NSMakeRange(0, count)];
            NSLog(@"array: %@",array);
        }
        
    });
}

- (void)testDeletedObject {
    
    MKEmployee *insertEmployee = [[MKEmployee alloc]init];
    insertEmployee.name = @"战狼5";
    insertEmployee.age = 28;
    insertEmployee.position = @"Auditing";
    insertEmployee.experience = 2.4;
    insertEmployee.degree = 12;
    [_memCache deletObject:insertEmployee];
}

- (void)testInsertObject {
    
    MKEmployee *insertEmployee = [[MKEmployee alloc]init];
    insertEmployee.name = @"战狼5";
    insertEmployee.age = 28;
    insertEmployee.position = @"Auditing";
    insertEmployee.experience = 2.4;
    insertEmployee.degree = 12;

    [_memCache insertObject:insertEmployee handler:^(BOOL result) {
    
    }];
}

- (void)testUpdateObjectWithDic {

    MKEmployee *insertEmployee = [[MKEmployee alloc]init];
    insertEmployee.name = @"战狼5";
    insertEmployee.age = 28;
    insertEmployee.position = @"Auditing";
    insertEmployee.experience = 2.4;
    insertEmployee.degree = 12;
    [_memCache update:@"MKEmployee" WithId:1 newDic:@{@"name":@"new战狼"}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
