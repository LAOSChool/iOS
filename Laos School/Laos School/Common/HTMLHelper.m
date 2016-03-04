//
//  HTMLHelper.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "HTMLHelper.h"
#import "UIKit/UIKit.h"
#import "Common.h"

// Singleton
static HTMLHelper* sharedHTMLHelper = nil;

@implementation HTMLHelper


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (HTMLHelper*) sharedHTMLHelper {
    // lazy instantiation
    if (sharedHTMLHelper == nil) {
        sharedHTMLHelper = [[HTMLHelper alloc] init];
    }
    return sharedHTMLHelper;
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
