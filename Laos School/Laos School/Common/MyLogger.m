//
//  MyLogger.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "MyLogger.h"
#import "UIKit/UIKit.h"

// Singleton
static MyLogger* sharedMyLogger = nil;

@implementation MyLogger


//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (MyLogger*) sharedMyLogger {
    // lazy instantiation
    if (sharedMyLogger == nil) {
        sharedMyLogger = [[MyLogger alloc] init];
    }
    return sharedMyLogger;
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

+ (void)error:(NSString *)message {
    NSLog(@"Error: %@", message);
}

+ (void)warning:(NSString *)message {
    NSLog(@"Warning: %@", message);
}

+ (void)info:(NSString *)message {
    NSLog(@"Info: %@", message);
}

+ (void)debug:(NSString *)message {
    NSLog(@"Debug: %@", message);
}

+ (void)verbose:(NSString *)message {
    NSLog(@"Verbose: %@", message);
}

@end
