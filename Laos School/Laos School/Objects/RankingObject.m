//
//  RankingObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RankingObject.h"
#import "LocalizeHelper.h"

/*

 */
@implementation RankingObject

- (id)init {
    self = [super init];
    if (self) {
        self.averageScore = @"";
        self.grade = @"";
        self.scoreTypeObj = [[ScoreTypeObject alloc] init];
        self.ranking = @"";
    }
    return self;
}

//- (void)encodeWithCoder:(NSCoder *)encoder {
//    
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    if ((self = [super init])) // Superclass init
//    {
//
//    }
//    
//    return self;
//}

- (SCORE_TYPE)scoreType {
    return _scoreTypeObj.scoreType;
}

- (NSInteger)term {
    return _scoreTypeObj.term;
}
@end