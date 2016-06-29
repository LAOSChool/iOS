//
//  ScoreObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScoreObject.h"
#import "LocalizeHelper.h"

/*
 @property (nonatomic, strong) NSString *scoreID;
 @property (nonatomic, strong) NSString *score;
 @property (nonatomic, strong) NSString *subjectID;
 @property (nonatomic, strong) NSString *subject;
 @property (nonatomic, strong) NSString *dateTime;
 @property (nonatomic, strong) ScoreTypeObject *scoreTypeObj;
 @property (nonatomic, strong) NSString *scoreDisplayName;
 @property (nonatomic, strong) NSString *comment;
 */
@implementation ScoreObject

- (id)init {
    self = [super init];
    if (self) {
        self.scoreID = @"";
        self.score = @"";
        self.subjectID = @"";
        self.subject = @"";
        self.dateTime = @"";
        self.scoreDisplayName = @"";
        self.scoreTypeObj = [[ScoreTypeObject alloc] init];
        self.comment = @"";
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

@end