//
//  AttendanceObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_AttendanceObject_h
#define LazzyBee_AttendanceObject_h

#import <UIKit/UIKit.h>

typedef enum {
    Absence_None = 0,
    Absence_Off,
    Absence_Late,
    Absence_Other,
    Absence_Max
} ABSENCE_TYPE;

@interface AttendanceObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *attendanceID;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, assign) ABSENCE_TYPE absenceType;
@property (nonatomic, assign) BOOL hasRequest;
@property (nonatomic, strong) NSString *reason;
@property (nonatomic, strong) NSString *session;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *subjectID;
@property (nonatomic, strong) NSMutableArray *detailSession;

@end

#endif
