//
//  MKSql.h
//  MKDataBase
//
//  Created by MIke on 31/10/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKSql;

typedef MKSql *(^Equ)(NSString *colume,id value);
typedef MKSql *(^Less)(NSString *colume,id value);
typedef MKSql *(^EquLess)(NSString *colume,id value);
typedef MKSql *(^Great)(NSString *colume,id value);
typedef MKSql *(^EquGreat)(NSString *colume, id value);
typedef MKSql *(^NotEqu)(NSString *colume, id value);

@interface MKSql : NSObject

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
