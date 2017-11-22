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

    if ([_mutableSql rangeOfString:@"AND"].length > 0) {
        
        [_mutableSql appendString:@" AND "];
    }
}

@end
