//
//  ViewController.m
//  FMDBDemo
//
//  Created by vera on 15/8/5.
//  Copyright (c) 2015年 vera. All rights reserved.
//

#import "ViewController.h"
#import "MKDataBaseManager.h"
#import "MKEmployee.h"
@interface ViewController ()

@property (nonatomic, strong) MKDataBaseManager *dataManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _dataManager = [MKDataBaseManager sharedDatabaseManager];
    [self insertSomeObjecs];
    //[self queryWithCondition];
    //[self unpdateWithCondition];
    
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

- (void)queryWithCondition{
    
    MKRange *range = [[MKRange alloc]init];
    range.name = @"age";
    range.start = 10;
    range.end = 80;
    
    NSDictionary *condition = @{@"degree":@"4"};
    NSArray *conditionResult = [_dataManager findObjectsWithRange:range condition:condition objName:@"MKEmployee"];
    NSLog(@"find result:%@",conditionResult);
    
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
