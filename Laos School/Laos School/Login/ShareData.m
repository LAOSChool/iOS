//
//  ShareData.m
//  LazzyBee
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "ShareData.h"
#import "UIKit/UIKit.h"

// Singleton
static ShareData* sharedShareData = nil;

@implementation ShareData


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (ShareData*) sharedShareData {
    // lazy instantiation
    if (sharedShareData == nil) {
        sharedShareData = [[ShareData alloc] init];
        
        
    }
    return sharedShareData;
}


//-------------------------------------------------------------
// initiating
//-------------------------------------------------------------
- (id) init {
    self = [super init];
    if (self) {
        // use systems main bundle as default bundle
        self.userObj = [[UserObject alloc] init];
    }
    return self;
}

@end
