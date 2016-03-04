//
//  CommonAlert.h
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LaosSchool_CommonAlert_h
#define LaosSchool_CommonAlert_h
#import <Foundation/Foundation.h>

@interface CommonAlert : NSObject

// a singleton:
+ (CommonAlert*) sharedCommonAlert;

- (void)showServerCommonErrorAlert;

@end

#endif
