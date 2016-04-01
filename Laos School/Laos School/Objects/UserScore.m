//
//  UserScore.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserScore.h"

/*
 @property (nonatomic, strong) NSString *userID;
 @property (nonatomic, strong) NSString *username;
 @property (nonatomic, strong) NSString *additionalInfo;
 @property (nonatomic, strong) NSMutableArray *scoreArray;
 */
@implementation UserScore

- (id)init {
    self = [super init];
    if (self) {
        self.userID = @"";
        self.username = @"";
        self.additionalInfo = @"";
        self.scoreArray = [[NSMutableArray alloc] init];
        self.averageScore = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.additionalInfo forKey:@"additionalInfo"];
    [encoder encodeObject:self.scoreArray forKey:@"scoreArray"];
    [encoder encodeObject:self.averageScore forKey:@"averageScore"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.additionalInfo = [decoder decodeObjectForKey:@"additionalInfo"];
        self.scoreArray = [decoder decodeObjectForKey:@"scoreArray"];
        self.averageScore = [decoder decodeObjectForKey:@"averageScore"];
    }
    
    return self;
}
@end