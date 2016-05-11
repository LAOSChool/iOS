//
//  ScoreObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreObject.h"

/*
 @property (nonatomic, strong) NSString *scoreID;
 @property (nonatomic, strong) NSString *score;
 @property (nonatomic, assign) SCORE_TYPE scoreType;
 @property (nonatomic, strong) NSString *month;
 @property (nonatomic, assign) NSInteger weight;
 */
@implementation ScoreObject

- (id)init {
    self = [super init];
    if (self) {
        self.scoreID = @"";
        self.score = @"";
        self.scoreType = ScoreType_Normal;
        self.month = @"0";
        self.weight = 1;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.scoreID forKey:@"scoreID"];
    [encoder encodeObject:self.score forKey:@"score"];
    [encoder encodeInteger:self.scoreType forKey:@"scoreType"];
    [encoder encodeObject:self.month forKey:@"month"];
    [encoder encodeInteger:self.weight forKey:@"weight"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.scoreID = [decoder decodeObjectForKey:@"scoreID"];
        self.score = [decoder decodeObjectForKey:@"score"];
        self.scoreType = (SCORE_TYPE)[decoder decodeIntegerForKey:@"scoreType"];
        self.score = [decoder decodeObjectForKey:@"score"];
        self.weight = [decoder decodeIntegerForKey:@"weight"];
    }
    
    return self;
}
@end