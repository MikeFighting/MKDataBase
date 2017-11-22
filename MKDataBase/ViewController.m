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

@property (nonatomic, strong) MKDBWrapper *dataWrapper;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    _dataWrapper = [MKDBWrapper sharedInstance];
    
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
