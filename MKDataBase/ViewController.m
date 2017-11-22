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
#import "MKMemCache.h"

@interface ViewController ()

@property (nonatomic, strong) MKDBWrapper *dataWrapper;
@property (nonatomic, strong) MKMemCache *memCache;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _dataWrapper = [MKDBWrapper sharedInstance];
    
    _memCache = [MKMemCache sharedInstance];
    _memCache.tableClasses = @[NSClassFromString(@"MKEmployee")];
    
    NSString *doucmentpath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSLog(@"db path : %@",doucmentpath);
    NSString *dbPath = [doucmentpath stringByAppendingPathComponent:@"MKDBWrapper.db"];
    _memCache.dbPath = dbPath;
    BOOL warmUpSuccess = [_memCache warmUpMemeCache];
    
    NSLog(@"warm up result: %d",warmUpSuccess);
    [self testInsertObject];
    
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

- (void)testInsertObject {
    
    MKEmployee *insertEmployee = [[MKEmployee alloc]init];
    insertEmployee.name = @"战狼5";
    insertEmployee.age = 28;
    insertEmployee.position = @"Auditing";
    insertEmployee.experience = 2.4;
    insertEmployee.degree = 12;
    [_memCache insertObject:insertEmployee handler:^(BOOL result) {
        
        NSAssert(result,@"MemCache insert Failure");
        
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
