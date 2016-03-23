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
#define GREEN_COLOR [UIColor colorWithRed:60/255.f green:159/255.f blue:30/255.f alpha:1]
#define BLUE_COLOR [UIColor colorWithRed:0/255.f green:103/255.f blue:194/255.f alpha:1]
#define TEXTBOX_COLOR [UIColor colorWithRed:0/255.f green:103/255.f blue:194/255.f alpha:1]

#define SERVER_LINK  @"http://192.168.0.202"
#define REQUEST_HOME @""

//user default keys
#define KEY_UNDEFINED @""

@interface CommonDefine : NSObject


@end

#endif
