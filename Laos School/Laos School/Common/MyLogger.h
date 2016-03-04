//
//  MyLogger.h
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LaosSchool_MyLogger_h
#define LaosSchool_MyLogger_h
#import <Foundation/Foundation.h>

@interface MyLogger : NSObject

// a singleton:
+ (MyLogger*) sharedMyLogger;

/**
 * Logs an error message.
 *
 * @param message The error message to be logged.
 */
+ (void)error:(NSString *)message;

/**
 * Logs a warning message.
 *
 * @param message The warning message to be logged.
 */
+ (void)warning:(NSString *)message;

/**
 * Logs an info message.
 *
 * @param message The info message to be logged.
 */
+ (void)info:(NSString *)message;

/**
 * Logs a debug message.
 *
 * @param message The debug message to be logged.
 */
+ (void)debug:(NSString *)message;

/**
 * Logs a verbose message.
 *
 * @param message The verbose message to be logged.
 */
+ (void)verbose:(NSString *)message;
@end

#endif
