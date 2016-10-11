//
//  CheckAttendanceObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckAttendanceObject.h"

/*
 @property (nonatomic, strong) UserObject *userObject;
 @property (nonatomic, assign) BOOL hasRequest;  //fullday
 @property (nonatomic, assign) BOOL state;
 
 @property (nonatomic, strong) NSString *reason;
 @property (nonatomic, strong) NSString *sessionID;
 @property (nonatomic, strong) NSString *session;
 @property (nonatomic, strong) NSString *subject;
 
 @property (nonatomic, assign) BOOL checkedFlag;
 */
@implementation CheckAttendanceObject

- (id)init {
    self = [super init];
    if (self) {
        self.userObject = nil;
        self.attendanceID = @"";
        self.hasRequest = NO;
        self.state      = 0;
        self.dateTime   = @"";
        self.reason = @"";
        self.session = @"";
        self.sessionID = @"";
        self.subject = @"";
        self.subjectID = @"";
        self.checkedFlag = NO;
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
//    [encoder encodeObject:self.wordid forKey:@"wordid"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
//        self.wordid = [decoder decodeObjectForKey:@"wordid"];

    }
    
    return self;
}

- (NSString *)userNameForSearch {
    return [NSString stringWithFormat:@"%@ %@ %@", self.userObject.username, self.userObject.displayName, self.userObject.nickName];
}
@end
