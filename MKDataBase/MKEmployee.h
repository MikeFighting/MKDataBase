//
//  MKEmployee.h
//  FMDBDemo
//
//  Created by Mike on 12/29/16.
//  Copyright © 2016 vera. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MKEmployee : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) CGFloat experience;
@property (nonatomic, assign) NSInteger degree;
@property (nonatomic, copy) NSString *position;

@end
