//
//  AnnouncementObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_AnnouncementObject_h
#define LazzyBee_AnnouncementObject_h

#import <UIKit/UIKit.h>

//#define QUEUE_UNKNOWN 0

typedef enum {
    AnnouncementImportanceNormal = 0,
    AnnouncementImportanceHigh,
    AnnouncementImportanceTypeMax,
} ANNOUNCEMENT_IMPORTANCE_TYPE;

@interface AnnouncementObject : NSObject
{
    
}

@property (nonatomic, assign) NSInteger announcementID;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) NSString *fromID;
@property (nonatomic, strong) NSString *fromUsername;
@property (nonatomic, strong) NSString *toID;
@property (nonatomic, strong) NSString *toUsername;
@property (nonatomic, assign) ANNOUNCEMENT_IMPORTANCE_TYPE importanceType;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, assign) BOOL unreadFlag;

@end

#endif
