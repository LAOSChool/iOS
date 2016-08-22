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
 @property (nonatomic, strong) NSString *displayName;
 @property (nonatomic, strong) NSString *additionalInfo;
 @property (nonatomic, strong) NSString *avatarLink;
 @property (nonatomic, strong) NSMutableArray *scoreArray;
 @property (nonatomic, strong) NSString *subjectID;
 @property (nonatomic, strong) NSString *subject;
 */
@implementation UserScore

- (id)init {
    self = [super init];
    if (self) {
        self.userID = @"";
        self.username = @"";
        self.displayName = @"";
        self.additionalInfo = @"";
        self.avatarLink = @"";
        self.scoreArray = [[NSMutableArray alloc] init];
        self.subjectID = @"";
        self.subject = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.userID forKey:@"userID"];
    [encoder encodeObject:self.username forKey:@"username"];
    [encoder encodeObject:self.displayName forKey:@"displayName"];
    [encoder encodeObject:self.additionalInfo forKey:@"additionalInfo"];
    [encoder encodeObject:self.avatarLink forKey:@"avatarLink"];
    [encoder encodeObject:self.scoreArray forKey:@"scoreArray"];
    [encoder encodeObject:self.subjectID forKey:@"subjectID"];
    [encoder encodeObject:self.subject forKey:@"subject"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.userID = [decoder decodeObjectForKey:@"userID"];
        self.username = [decoder decodeObjectForKey:@"username"];
        self.displayName = [decoder decodeObjectForKey:@"displayName"];
        self.additionalInfo = [decoder decodeObjectForKey:@"additionalInfo"];
        self.avatarLink = [decoder decodeObjectForKey:@"avatarLink"];
        self.scoreArray = [decoder decodeObjectForKey:@"scoreArray"];
        self.subjectID = [decoder decodeObjectForKey:@"subjectID"];
        self.subject = [decoder decodeObjectForKey:@"subject"];
    }
    
    return self;
}

- (NSString *)avatarLink {
    NSString *res = _avatarLink;
    
    if (res.length > 0) {
        NSString *tmp = [res stringByDeletingPathExtension];
        NSString *extension = [res pathExtension];
        res = [tmp stringByAppendingFormat:@"_90.%@", extension];
    }
    
    return res;
}
@end