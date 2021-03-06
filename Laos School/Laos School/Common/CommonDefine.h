//
//  CommonDefine.h
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LaosSchool_CommonDefine_h
#define LaosSchool_CommonDefine_h
#import <Foundation/Foundation.h>

#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_4 (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height < 568.0))
#define IS_IPHONE_5 (IS_IPHONE && ([[UIScreen mainScreen] bounds].size.height == 568.0) && ((IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale) || !IS_OS_8_OR_LATER))
#define IS_STANDARD_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0  && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale == [UIScreen mainScreen].scale)
#define IS_ZOOMED_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale > [UIScreen mainScreen].scale)
#define IS_STANDARD_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_ZOOMED_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0 && IS_OS_8_OR_LATER && [UIScreen mainScreen].nativeScale < [UIScreen mainScreen].scale)

//#define COMMON_COLOR [UIColor colorWithRed:197/255.f green:90/255.f blue:90/255.f alpha:1]
#define COMMON_COLOR [UIColor colorWithRed:63/255.f green:82/255.f blue:165/255.f alpha:1]

#define GREEN_COLOR [UIColor colorWithRed:143/255.f green:38/255.f blue:42/255.f alpha:1]
#define BLUE_COLOR [UIColor colorWithRed:63/255.f green:82/255.f blue:165/255.f alpha:1]
#define TEXTBOX_COLOR [UIColor colorWithRed:0/255.f green:103/255.f blue:194/255.f alpha:1]
#define TITLE_COLOR BLUE_COLOR

#define LOW_IMPORTANCE_COLOR [UIColor lightGrayColor]
#define NORMAL_IMPORTANCE_COLOR [UIColor lightGrayColor]
#define HIGH_IMPORTANCE_COLOR GREEN_COLOR

#define ALERT_COLOR BLUE_COLOR
#define OFF_COLOR [UIColor lightGrayColor]
#define LATE_COLOR [UIColor colorWithRed:255/255.f green:172/255.f blue:41/255.f alpha:1]

//#define UNREAD_COLOR [UIColor colorWithRed:255/255.f green:249/255.f blue:196/255.f alpha:1]
#define UNREAD_COLOR [UIColor colorWithRed:230/255.f green:230/255.f blue:242/255.f alpha:1]

#define READ_COLOR [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1]

#define NORMAL_SCORE [UIColor lightGrayColor]
#define AVERAGE_SCORE [UIColor colorWithRed:0/255.f green:77/255.f blue:46/255.f alpha:1]
#define EXAM_SCORE [UIColor colorWithRed:63/255.f green:82/255.f blue:165/255.f alpha:1]
#define FINAL_SCORE [UIColor colorWithRed:143/255.f green:38/255.f blue:42/255.f alpha:1]

#define VERLOCITY 600

//user default keys
#define KEY_AUTH_KEY @"authenkey"
#define KEY_USERNAME @"usernamekey"

#define ATTENDANCE_DATE_FORMATE @"EEEE, dd-MM-yyy"
#define COMMON_DATE_FORMATE @"dd-MM-yyy"

#define TERM_VALUE_1 @"1"
#define TERM_VALUE_2 @"2"
#define TERM_VALUE_OVERALL @"3"

#define LANGUAGE_LAOS @"lo"
#define LANGUAGE_ENGLISH @"en"


//user default keys
#define KEY_NOTIFICATION_ONOFF @"NotificationOnOff"
#define KEY_FIREBASE_TOKEN @"NotificationToken"

@interface CommonDefine : NSObject


@end

#endif
