//
//  UserObject.h
//  LaosSchool
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LaosSchool_UserObject_h
#define LaosSchool_UserObject_h

#import <UIKit/UIKit.h>
#import "ClassObject.h"

typedef enum {
    Role_Student = 0,
    Role_Monitor,
    Role_SubjectTeacher,
    Role_HeadTeacher,
    Role_Max,
} USER_ROLE;



@interface UserObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *avatarPath;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *shoolID;    //current shcool
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) ClassObject *classObj;
@property (nonatomic, strong) NSString *currentTerm;
@property (nonatomic, strong) NSString *classArray; //array of classID that user belong to

@end

#endif
