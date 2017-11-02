//
//  MKSql.m
//  MKDataBase
//
//  Created by MIke on 31/10/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MKSql.h"
@interface MKSql ()

@property (nonatomic, copy) NSMutableString *mutableSql;

@end

@implementation MKSql

#pragma mark - setter
+ (instancetype)make {
    
    return [[MKSql alloc]init];
}
- (instancetype)init {

    self = [super init];
    if (self) {
        [self mutableSql];
    
    }
    return self;
}

- (Equ)equ {

    return ^(NSString *colume, id value){
    
        [self p_appendANDifNeed];
        [_mutableSql appendFormat:@"%@", [NSString stringWithFormat:@"%@ = %@",colume,value]];
        return self;
    };
}

- (NotEqu)notEqu {

    return ^(NSString *colume, id object) {
    
        [self p_appendANDifNeed];
        
        [_mutableSql appendString:[NSString stringWithFormat:@"%@ != @ %@",colume,object]];
        
        return self;
    };
}

- (Less)less {

    return ^(NSString *colume, id value) {
    
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ < %@",colume,value]];
        return self;
    };
    
}

- (EquLess)equLess {

    return ^(NSString *colume, id value) {
        
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ <= %@",colume,value]];
        return self;
    };
}

- (Great)great {

    return ^(NSString *colume, id value) {
        
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ > %@",colume,value]];
        return self;
    };
}

- (EquGreat)equGreat {

    return ^(NSString *colume, id value) {
        
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ >= %@",colume,value]];
        return self;
    };
}


#pragma mark - getter
- (NSMutableString *)mutableSql {

    if (!_mutableSql) {
        _mutableSql = [NSMutableString string];
    }
    return _mutableSql;
}

- (NSString *)result {

    return [_mutableSql copy];
}

- (void)p_appendANDifNeed {

    if ([_mutableSql rangeOfString:@"AND"].length > 0) {
        
        [_mutableSql appendString:@" AND "];
    }
}

@end
