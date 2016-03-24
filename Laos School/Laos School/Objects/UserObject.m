//
//  UserObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserObject.h"

/*
 @property (nonatomic, strong) NSString *userID;
 @property (nonatomic, strong) NSString *username;
 @property (nonatomic, strong) NSString *displayName;
 @property (nonatomic, strong) NSString *nickName;
 @property (nonatomic, strong) NSString *avatarPath;
 @property (nonatomic, strong) NSString *phoneNumber;
 @property (nonatomic, assign) USER_ROLE userRole;
 @property (nonatomic, assign) PERMISSION_GRANTED permission;
 @property (nonatomic, strong) NSString *shoolID;    //current shcool
 @property (nonatomic, strong) NSString *schoolName;
 @property (nonatomic, strong) ClassObject *classObj;
 @property (nonatomic, strong) NSString *currentTerm;
 @property (nonatomic, strong) NSArray *classArray; //array of classID that user belong to
 */
@implementation UserObject

- (id)init {
    self = [super init];
    if (self) {
        self.userID = @"";
        self.username = @"";
        self.displayName = @"";
        self.nickName = @"";
        self.avatarPath = @"";
        self.phoneNumber = @"";
        self.userRole = UserRole_Student;
        self.permission = Permission_Normal;
        
        self.shoolID = @"";
        self.schoolName = @"";
        self.classObj = nil;
        self.currentTerm = @"";
        self.classArray = nil;
        
        self.selected = NO;
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
//    [encoder encodeObject:self.wordid forKey:@"wordid"];
//    [encoder encodeObject:self.gid forKey:@"gid"];
//    [encoder encodeObject:self.question forKey:@"question"];
//    [encoder encodeObject:self.answers forKey:@"answers"];
//    [encoder encodeObject:self.subcats forKey:@"subcats"];
//    [encoder encodeObject:self.status forKey:@"status"];
//    [encoder encodeObject:self.package forKey:@"package"];
//    [encoder encodeObject:self.level forKey:@"level"];
//    [encoder encodeObject:self.queue forKey:@"queue"];
//    [encoder encodeObject:self.due forKey:@"due"];
//    [encoder encodeObject:self.revCount forKey:@"revCount"];
//    [encoder encodeObject:self.lastInterval forKey:@"lastInterval"];
//    [encoder encodeObject:self.eFactor forKey:@"eFactor"];
//    [encoder encodeObject:self.langVN forKey:@"langVN"];
//    [encoder encodeObject:self.langEN forKey:@"langEN"];
//    [encoder encodeObject:self.userNote forKey:@"userNote"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
//        self.wordid = [decoder decodeObjectForKey:@"wordid"];
//        self.gid = [decoder decodeObjectForKey:@"gid"];
//        self.question = [decoder decodeObjectForKey:@"question"];
//        self.answers = [decoder decodeObjectForKey:@"answers"];
//        self.subcats = [decoder decodeObjectForKey:@"subcats"];
//        self.status = [decoder decodeObjectForKey:@"status"];
//        self.package = [decoder decodeObjectForKey:@"package"];
//        self.level = [decoder decodeObjectForKey:@"level"];
//        self.queue = [decoder decodeObjectForKey:@"queue"];
//        self.due = [decoder decodeObjectForKey:@"due"];
//        self.revCount = [decoder decodeObjectForKey:@"revCount"];
//        self.lastInterval = [decoder decodeObjectForKey:@"lastInterval"];
//        self.eFactor = [decoder decodeObjectForKey:@"eFactor"];
//        self.langVN = [decoder decodeObjectForKey:@"langVN"];
//        self.langEN = [decoder decodeObjectForKey:@"langEN"];
//        self.userNote = [decoder decodeObjectForKey:@"userNote"];
    }
    
    return self;
}
@end