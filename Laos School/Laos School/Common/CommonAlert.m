//
//  CommonAlert.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "CommonAlert.h"
#import "LocalizeHelper.h"
#import "UIKit/UIKit.h"

// Singleton
static CommonAlert* sharedCommonAlert = nil;

@implementation CommonAlert


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (CommonAlert*) sharedCommonAlert {
    // lazy instantiation
    if (sharedCommonAlert == nil) {
        sharedCommonAlert = [[CommonAlert alloc] init];
    }
    return sharedCommonAlert;
}


//-------------------------------------------------------------
// initiating
//-------------------------------------------------------------
- (id) init {
    self = [super init];
    if (self) {
        // use systems main bundle as default bundle
    }
    return self;
}

- (void)showServerCommonErrorAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message: @"" delegate:nil cancelButtonTitle:@"" otherButtonTitles: nil];
    alert.tag = 103;
    
    [alert show];
}

- (void)showNoConnnectionAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"No connection") message:LocalizedString(@"Please double check wifi/3G connection") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 101;
    
    [alert show];
}
@end
