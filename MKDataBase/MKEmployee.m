//
//  MKEmployee.m
//  FMDBDemo
//
//  Created by Mike on 12/29/16.
//  Copyright © 2016 vera. All rights reserved.
//

#import "MKEmployee.h"

@implementation MKEmployee

- (NSString *)primaryKey  {

    return @"name";
}

- (NSString *)description{

    return [NSString stringWithFormat:@"%@:%@",[self class],
        
                                                 @{@"name":_name,
                                                  @"age":@(_age),
                                                  @"experience":@(_experience),
                                                  @"degree":@(_degree),
                                                  @"position":_position
                                                  }];
}
@end
