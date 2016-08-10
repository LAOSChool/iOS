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

#define USER_ROLE_STUDENT @"STUDENT"
#define USER_ROLE_PRESIDENT @"CLS_PRESIDENT"
#define USER_ROLE_HEAD_TEACHER @"TEACHER"
#define USER_ROLE_SUB_TEACHER @"TEACHER"

typedef enum {
    UserRole_Student = 0,
    UserRole_President,
    UserRole_Teacher,
    UserRole_Max,
} USER_ROLE;

typedef enum {
    Permission_Normal = 0x00000000,
    Permission_CheckAttendance = 0x00000001,
    Permission_SendMessage = 0x00000010,
    Permission_AddScore = 0x00000100,
    Permission_SendAnnouncement = 0x00001000,
    Permission_Max = 0x11111111
} PERMISSION_GRANTED;



@interface UserObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *avatarPath;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) USER_ROLE userRole;
@property (nonatomic, assign) PERMISSION_GRANTED permission;
@property (nonatomic, strong) NSString *shoolID;    //current shcool
@property (nonatomic, strong) NSString *schoolName;
@property (nonatomic, strong) ClassObject *classObj;
@property (nonatomic, strong) NSArray *classArray; //array of classID that user belong to

//Additional info
@property (nonatomic, strong) NSString *parentEmail;
@property (nonatomic, strong) NSString *parentPhone;
@property (nonatomic, strong) NSString *parentName;
@property (nonatomic, strong) NSString *address;

//use for students list
@property (nonatomic, assign) BOOL selected;
@end

#endif
