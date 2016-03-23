//
//  MessageObject.h
//  LaosSchool
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LaosSchool_MessageObject_h
#define LaosSchool_MessageObject_h

#import <UIKit/UIKit.h>

#define MT_COMMENT @"NX"
#define MT_ANNOUNCEMENT @"AN"
#define MT_ATTENDANCE @"AT"
#define MT_SCORE @"SC"

#define LOW_IMPORTANCE_COLOR [UIColor lightGrayColor]
#define NORMAL_IMPORTANCE_COLOR [UIColor greenColor]
#define HIGH_IMPORTANCE_COLOR [UIColor redColor]

typedef enum {
    MessageIncome = 0,
    MessageOutgo,
    MessageIncomeOutgoMax,
} INCOME_OUTGO_TYPE;

typedef enum {
    MessageAnnouncement = 0,
    MessageAttendance,
    MessageComment,
    MessageScore,
    MessageTypeMax,
} MESSAGE_TYPE;

typedef enum {
//    ImportanceLow = 0,
    ImportanceNormal = 0,
    ImportanceHigh,
    ImportanceTypeMax,
} IMPORTANCE_TYPE;

@interface MessageObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *messsageID;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *fromID;
@property (nonatomic, strong) NSString *fromUsername;
@property (nonatomic, strong) NSString *toID;
@property (nonatomic, strong) NSString *toUsername;
@property (nonatomic, assign) BOOL unreadFlag;
@property (nonatomic, assign) INCOME_OUTGO_TYPE incomeOutgoType;
@property (nonatomic, assign) MESSAGE_TYPE messageType;
@property (nonatomic, assign) IMPORTANCE_TYPE importanceType;
@property (nonatomic, strong) NSString *messageTypeIcon;
@property (nonatomic, strong) NSString *importanceTypeIcon;
@property (nonatomic, strong) NSString *dateTime;

@end

#endif
