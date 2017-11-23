//
//  MKRangeSql.h
//  MKDataBase
//
//  Created by MIke on 31/10/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKRangeSql;

typedef MKRangeSql *(^Equ)(NSString *colume,id value);
typedef MKRangeSql *(^Less)(NSString *colume,id value);
typedef MKRangeSql *(^EquLess)(NSString *colume,id value);
typedef MKRangeSql *(^Great)(NSString *colume,id value);
typedef MKRangeSql *(^EquGreat)(NSString *colume, id value);
typedef MKRangeSql *(^NotEqu)(NSString *colume, id value);

@interface MKRangeSql : NSObject

+ (instancetype)make;
/**
 * Equal
 * colume, value
 */
@property (nonatomic, copy) Equ equ;
@property (nonatomic, copy) Less less;
@property (nonatomic, copy) EquLess equLess;
@property (nonatomic, copy) Great great;
@property (nonatomic, copy) EquGreat equGreat;
@property (nonatomic, copy) NotEqu notEqu;

@property (nonatomic, copy) NSString *result;

@end
