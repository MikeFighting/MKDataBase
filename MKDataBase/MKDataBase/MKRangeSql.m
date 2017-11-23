//
//  MKRangeSql.m
//  MKDataBase
//
//  Created by MIke on 31/10/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MKRangeSql.h"
@interface MKRangeSql ()

@property (nonatomic, copy) NSMutableString *mutableSql;

@end

@implementation MKRangeSql

#pragma mark - setter
+ (instancetype)make {
    
    return [[MKRangeSql alloc]init];
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
        [self p_addExtraInfoForObj:value TargetString:@"="];
        return self;
    };
}

- (NotEqu)notEqu {

    return ^(NSString *colume, id value) {
    
        [self p_appendANDifNeed];
        
        [_mutableSql appendString:[NSString stringWithFormat:@"%@ != %@",colume,value]];
        [self p_addExtraInfoForObj:value TargetString:@"!="];
        
        return self;
    };
}

- (Less)less {

    return ^(NSString *colume, id value) {
    
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ < %@",colume,value]];
        [self p_addExtraInfoForObj:value TargetString:@"<"];
        return self;
    };
    
}

- (EquLess)equLess {

    return ^(NSString *colume, id value) {
        
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ <= %@",colume,value]];
        [self p_addExtraInfoForObj:value TargetString:@"<="];
        return self;
    };
}

- (Great)great {

    return ^(NSString *colume, id value) {
        
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ > %@",colume,value]];
        [self p_addExtraInfoForObj:value TargetString:@">"];
        return self;
    };
}

- (EquGreat)equGreat {

    return ^(NSString *colume, id value) {
        
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ >= %@",colume,value]];
        [self p_addExtraInfoForObj:value TargetString:@">="];
        return self;
    };
}

- (Include)include {

    return ^(NSString *colume, NSArray *valueSet) {
        
        NSString *valuesString = [valueSet componentsJoinedByString:@","];
        [self p_appendANDifNeed];
        [_mutableSql appendString:[NSString stringWithFormat:@" %@ in ( %@ )",colume,valuesString]];
        return self;
    };
}

// The ' should be add if the colume is String Type. Otherwise, the 'no such column' will occur.
- (void)p_addExtraInfoForObj:(id)obj TargetString:(NSString *)target {

    if (![obj isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSRange targetRange = [_mutableSql rangeOfString:target options:NSBackwardsSearch];
    [_mutableSql insertString:@"'" atIndex:targetRange.location + targetRange.length + 1];
    [_mutableSql appendString:@"'"];
    
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

     NSCharacterSet *compareSet = [NSCharacterSet characterSetWithCharactersInString:@">=<"];
     NSRange compareRange = [_mutableSql rangeOfCharacterFromSet:compareSet options:NSCaseInsensitiveSearch range:NSMakeRange(0, _mutableSql.length)];
    
    if (compareRange.length > 0) {
        
        [_mutableSql appendString:@" AND "];
    }
}

@end
