//
//  CheckAttendanceObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_CheckAttendanceObject_h
#define LazzyBee_CheckAttendanceObject_h

#import <UIKit/UIKit.h>
#import "UserObject.h"

//#define QUEUE_UNKNOWN 0

@interface CheckAttendanceObject : NSObject
{
    
}

@property (nonatomic, strong) UserObject *userObject;
@property (nonatomic, assign) BOOL hasRequest;  //fullday
@property (nonatomic, assign) NSInteger state;

@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) NSString *session;
@property (nonatomic, strong) NSString *subject;

@property (nonatomic, assign) BOOL checkedFlag;

- (NSString *)userNameForSearch;

@end

#endif
