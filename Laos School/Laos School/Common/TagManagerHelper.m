//
//  TagManagerHelper.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "TagManagerHelper.h"
#import "UIKit/UIKit.h"

// Singleton
static TagManagerHelper* sharedTagManagerHelper = nil;

@implementation TagManagerHelper


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (TagManagerHelper*) sharedTagManagerHelper {
    // lazy instantiation
    if (sharedTagManagerHelper == nil) {
        sharedTagManagerHelper = [[TagManagerHelper alloc] init];
    }
    return sharedTagManagerHelper;
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

+ (void)pushOpenScreenEvent:(NSString *)screenName {
    TAGDataLayer *dataLayer = [TAGManager instance].dataLayer;
    
    [dataLayer push:@{@"event": @"openScreen", @"screenName": screenName}];
}
@end
