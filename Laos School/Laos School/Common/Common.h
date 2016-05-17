//
//  common.h
//  unknown
//
//  Created by HuKhong on 3/3/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef ImportContact_common_h
#define ImportContact_common_h
#import "CommonDefine.h"
#import "DateTimeHelper.h"
#import <UIKit/UIKit.h>


#define DEF_UNDEFINED undefined

typedef enum {
    something = 0
} ENUM_UNDEFINED;


@interface Common : NSObject
{
    
}

+ (Common *)sharedCommon;

- (NSString *)parsePhoneType:(NSString *)phoneType;
- (NSString *)addPrefixToPhoneNumber:(NSString *)phoneNumber;


- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients viewController:(id)viewController;

- (BOOL)networkIsActive;
- (BOOL) isUsingWifi;

- (NSString *)encodeURL:(NSString *)unencodedURL;

- (UIImage *)scaleAndRotateImage:(UIImage *)image withMaxSize:(int)kMaxResolution;
- (UIImage *)imageFromText:(NSString *)text withColor:(UIColor*)color;
- (UIImage *)createImageFromView:(UIView *)view;

- (BOOL)validateEmailWithString:(NSString*)email;
- (NSString *)hidePhoneNumber:(NSString *)phonenumber;

- (NSString *) stringByRemovingHTMLTag:(NSString *)text;
- (NSString *)stringByRemovingSpaceAndNewLineSymbol:(NSString *)text;

- (void)textToSpeech:(NSString *)text withRate:(float)rate;

- (NSString *)getDeviceUUID;


@end
#endif
