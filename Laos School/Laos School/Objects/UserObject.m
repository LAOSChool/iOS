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

 */
@implementation UserObject

- (id)init {
    self = [super init];
    if (self) {
        self.userID = @"";
        self.username = @"";
        self.displayName = @"";
        self.nickName = @"";
        self.gender = @"";
        self.avatarPath = @"";
        self.phoneNumber = @"";
        self.userRole = UserRole_Student;
        self.permission = Permission_Normal;
        
        self.shoolID = @"";
        self.schoolName = @"";
        self.classObj = nil;
        self.classArray = nil;
        
        self.selected = NO;
        
        //additional
        self.email = @"";
        self.parentPhone = @"";
        self.parentEmail = @"";
        self.parentName = @"";
        self.address = @"";
    }
    return self;
}


//- (void)encodeWithCoder:(NSCoder *)encoder {
//    
////    [encoder encodeObject:self.wordid forKey:@"wordid"];
//
//}
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    if ((self = [super init])) // Superclass init
//    {
////        self.wordid = [decoder decodeObjectForKey:@"wordid"];
//
//    }
//    
//    return self;
//}

- (NSString *)avatarPath {
    NSString *res = _avatarPath;
    
    if (res.length > 0) {
        NSString *tmp = [res stringByDeletingPathExtension];
        NSString *extension = [res pathExtension];
        res = [tmp stringByAppendingFormat:@"_90.%@", extension];
    }
    
    return res;
}

- (NSString *)fullAvatarPath {
    NSString *res = _avatarPath;
    
    return res;
}
@end