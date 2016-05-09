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

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) NSString *session;    //blank if is off all day
@property (nonatomic, strong) NSString *subject;    //blank if is off all day
@property (nonatomic, assign) ABSENCE_TYPE absenceType;
@property (nonatomic, assign) BOOL hasRequest;
@property (nonatomic, strong) NSString *reason;

@end

#endif
