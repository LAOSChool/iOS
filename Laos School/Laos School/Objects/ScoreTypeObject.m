//
//  ScoreTypeObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreTypeObject.h"

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
        self.scoreMonth = @"";
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
@end