//
//  ViewController.m
//  FMDBDemo
//
//  Created by vera on 15/8/5.
//  Copyright (c) 2015年 vera. All rights reserved.
//

#import "ViewController.h"
#import "MKDBWrapper.h"
#import "MKEmployee.h"
@interface ViewController ()

@property (nonatomic, strong) MKDBWrapper *dataManager;
@property (nonatomic, assign) double beginTime;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _dataManager = [MKDBWrapper sharedInstance];
    //[self insertSomeObjecs];
    //[self queryWithCondition];
    //[self unpdateWithCondition];
    //[self queryWithCondition2];
    //[self queryWithCondition];
    //[self queryObjectWithName];
    
//   [self insertSomeObjecs];
//    [self queryWithCondition];
    //[self queryObjectWithName];
    
    [self testQueryAndAdd];

    _beginTime = CFAbsoluteTimeGetCurrent();
}

- (void)testQueryAndAdd {

    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_barrier_async(queue, ^{
        
        sleep(0.01);
        for (int i = 0; i < 1000; i ++) {
            
            [array addObject:@(i)];
        }
    });
    
    dispatch_sync(queue, ^{
        
        for (int i = 0; i < array.count; i ++) {
            
            NSLog(@"number %@",array[i]);
        }
        
    });

}

- (void)insertSomeObjecs{
    
    for (int i = 0; i < 50; i ++) {
        
        MKEmployee *employee = [[MKEmployee alloc]init];
        employee.name = [NSString stringWithFormat:@"name%d",i];
        employee.experience = i + 0.5f;
        employee.age = i + 20;
        employee.degree = i % 8;
        employee.position = [NSString stringWithFormat:@"position%d",i];
        BOOL success = [_dataManager insertWithObject:employee];
        NSLog(@"insert result: %@",success ? @"success":@"failure");
        
    }
}

- (void)queryObjectWithName {

    NSArray *models = [_dataManager queryObjectsWithName:@"MKEmployee"];
}

- (void)queryWithCondition{
    
    for (int i = 0 ; i < 1000; i ++) {
        
        MKSql *sql = [MKSql make].equ(@"age",@"36");
        NSArray *conditionResult = [_dataManager queryObjectsWithCondition:sql objName:@"MKEmployee"];
        NSLog(@"find result:%@",conditionResult);
        if (i == 999) {
            
            CFAbsoluteTime current = CFAbsoluteTimeGetCurrent();
            NSLog(@"consume time = %f",(current - _beginTime) * 1000);
            
        }
        
    }
  
}

- (void)queryWithCondition2{
//    
//    for (int i = 0 ; i < 1000; i ++) {
//        
//        MKRange *range = [[MKRange alloc]init];
//        range.name = @"age";
//        range.start = 10;
//        range.end = 80;
//        
//        NSDictionary *condition = @{@"degree":@"4"};
//        [_dataManager queryObjectsWithRange:range condition:condition objName:@"MKEmployee" callBackBlock:^(NSArray *foundObjcs) {
//            
//        }];
//        
//        if (i == 999) {
//            
//            double current = CFAbsoluteTimeGetCurrent();
//            NSLog(@"consume time = %f",(current - _beginTime) * 1000.0f);
//            
//            
//        }
//        
//    }

}
- (void)unpdateWithCondition{
    
    MKEmployee *employee = [[MKEmployee alloc]init];
    employee.name = @"Jimme";
    employee.age = 132;
    employee.experience = 12.3;
    employee.degree = 10;
    employee.position = @"Coder";
    BOOL updateSuccess = [_dataManager updateTableWithNewObjc:employee condition:@{@"position":@"position44"}];
    NSLog(@"update result:%@",updateSuccess ? @"success":@"failure");
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
