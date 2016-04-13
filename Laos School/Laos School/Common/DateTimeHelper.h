//
//  DateTimeHelper.h
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LaosSchool_DateTimeHelper_h
#define LaosSchool_DateTimeHelper_h
#import <Foundation/Foundation.h>

@interface DateTimeHelper : NSObject

// a singleton:
+ (DateTimeHelper*) sharedDateTimeHelper;


- (NSString *)getCurrentDatetimeWithFormat:(NSString *)formatString;
- (NSString *)getNextDatetimeWithFormat:(NSString *)formatString;
- (NSString *)dateStringFromDate:(NSDate *)date withFormat:(NSString *)formatString;
- (NSString *)timeStringFromDate:(NSDate *)date;
- (NSString *)stringDateFromString:(NSString *)dateStr withFormat:(NSString *)formatString;
- (NSDate *)dateFromString:(NSString *)dateStr;
- (NSTimeInterval)getCurrentDatetimeInMinisec;
- (NSTimeInterval)getBeginOfDayInMinisec;
- (NSTimeInterval)getCurrentDatetimeInSec;
- (NSTimeInterval)getBeginOfDayInSec;
- (NSString *)getDayOfWeek:(NSDate *)date;
- (NSString *)convertDateOfWeekToVN:(NSString *)dateOfWeek;

@end

#endif
