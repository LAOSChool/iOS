//
//  ScoreTypeObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreTypeObject.h"
#import "LocalizeHelper.h"

/*
 @property (nonatomic, strong) NSString *typeID;
 @property (nonatomic, strong) NSString *scoreName;
 @property (nonatomic, strong) NSString *scoreType;
 @property (nonatomic, strong) NSString *scoreMonth;
 */
@implementation ScoreTypeObject

- (id)init {
    self = [super init];
    if (self) {
        self.typeID = @"";
        self.scoreName = @"";
        self.scoreType = ScoreType_Normal;
        self.scoreMonth = 0;
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {

    }
    
    return self;
}

- (NSString *)scoreName {
    NSString *res = @"";
    
    if ([_scoreName isEqualToString:@"September score"]) {
        res = LocalizedString(@"September score");
        
    } else if ([_scoreName isEqualToString:@"October score"]) {
        res = LocalizedString(@"October score");
        
    } else if ([_scoreName isEqualToString:@"November score"]) {
        res = LocalizedString(@"November score");
        
    } else if ([_scoreName isEqualToString:@"December score"]) {
        res = LocalizedString(@"December score");
        
    } else if ([_scoreName isEqualToString:@"Average 4 months"]) {
        res = LocalizedString(@"Average 4 months");
        
    } else if ([_scoreName isEqualToString:@"Term exam 1"]) {
        res = LocalizedString(@"Term exam 1");
        
    } else if ([_scoreName isEqualToString:@"Average term 1"]) {
        res = LocalizedString(@"Average term 1");
        
    } else if ([_scoreName isEqualToString:@"February score"]) {
        res = LocalizedString(@"February score");
        
    } else if ([_scoreName isEqualToString:@"March score"]) {
        res = LocalizedString(@"March score");
        
    } else if ([_scoreName isEqualToString:@"April score"]) {
        res = LocalizedString(@"April score");
        
    } else if ([_scoreName isEqualToString:@"May score"]) {
        res = LocalizedString(@"May score");
        
    } else if ([_scoreName isEqualToString:@"Average 4 months"]) {
        res = LocalizedString(@"Average 4 months");
        
    } else if ([_scoreName isEqualToString:@"Term exam 2"]) {
        res = LocalizedString(@"Term exam 2");
        
    } else if ([_scoreName isEqualToString:@"Average term 2"]) {
        res = LocalizedString(@"Average term 2");
        
    } else if ([_scoreName isEqualToString:@"Overall"]) {
        res = LocalizedString(@"Overall");
        
    } else if ([_scoreName isEqualToString:@"Retest"]) {
        res = LocalizedString(@"Retest");
        
    } else if ([_scoreName isEqualToString:@"Graduation"]) {
        res = LocalizedString(@"Graduation");
        
    }
    
    return res;
}

@end