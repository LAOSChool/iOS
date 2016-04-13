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

#define COMMON_COLOR [UIColor colorWithRed:197/255.f green:90/255.f blue:90/255.f alpha:1]
#define GREEN_COLOR [UIColor colorWithRed:0/255.f green:162/255.f blue:97/255.f alpha:1]
#define BLUE_COLOR [UIColor colorWithRed:0/255.f green:103/255.f blue:194/255.f alpha:1]
#define TEXTBOX_COLOR [UIColor colorWithRed:0/255.f green:103/255.f blue:194/255.f alpha:1]
#define TITLE_COLOR [UIColor colorWithRed:77/255.f green:131/255.f blue:242/255.f alpha:1]

#define LOW_IMPORTANCE_COLOR [UIColor lightGrayColor]
#define NORMAL_IMPORTANCE_COLOR [UIColor lightGrayColor]
#define HIGH_IMPORTANCE_COLOR [UIColor colorWithRed:197/255.f green:90/255.f blue:90/255.f alpha:1]

#define ALERT_COLOR [UIColor colorWithRed:169/255.f green:31/255.f blue:24/255.f alpha:1]
#define OFF_COLOR [UIColor lightGrayColor]
#define LATE_COLOR [UIColor colorWithRed:255/255.f green:172/255.f blue:41/255.f alpha:1]

#define UNREAD_COLOR [UIColor colorWithRed:212/255.f green:255/255.f blue:194/255.f alpha:1]
#define READ_COLOR [UIColor colorWithRed:255/255.f green:255/255.f blue:255/255.f alpha:1]


//user default keys
#define KEY_AUTH_KEY @"authenkey"
#define KEY_USERNAME @"usernamekey"

@interface CommonDefine : NSObject


@end

#endif
