//
//  CommonAlert.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "CommonAlert.h"
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
@end
