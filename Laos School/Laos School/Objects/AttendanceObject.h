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
    Absence_off = 0,
    Absence_late,
    Absence_other,
    Absence_Max
} ABSENCE_TYPE;

@interface AttendanceObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, assign) ABSENCE_TYPE absenceType;
@property (nonatomic, assign) BOOL hasPermission;
@property (nonatomic, strong) NSString *reason;

@end

#endif
