//
//  DateTimeHelper.m
//  LazzyBee
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "DateTimeHelper.h"
#import "UIKit/UIKit.h"

// Singleton
static DateTimeHelper* sharedDateTimeHelper = nil;

@implementation DateTimeHelper


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (DateTimeHelper*) sharedDateTimeHelper {
    // lazy instantiation
    if (sharedDateTimeHelper == nil) {
        sharedDateTimeHelper = [[DateTimeHelper alloc] init];
    }
    return sharedDateTimeHelper;
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

@end
