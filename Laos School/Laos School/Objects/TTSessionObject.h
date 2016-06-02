//
//  TTSessionObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_TTSessionObject_h
#define LazzyBee_TTSessionObject_h

#import <UIKit/UIKit.h>

typedef enum {
    SessionType_Morning = 0,
    SessionType_Afternoon,
    SessionType_Evening,
    SessionType_Max,
} SESSION_TYPE;

@interface TTSessionObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *weekDay;
@property (nonatomic, assign) NSInteger weekDayID;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *subjectID;
@property (nonatomic, strong) NSString *session;
@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, assign) SESSION_TYPE sessionType;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSString *teacherName;

@end

#endif
