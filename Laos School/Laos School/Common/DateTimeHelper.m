//
//  DateTimeHelper.m
//  LaosSchool
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

- (NSString *)getCurrentDatetimeWithFormat:(NSString *)formatString {
    NSString *dateString = nil;
    NSLocale* currentLocale = [NSLocale currentLocale];
    [[NSDate date] descriptionWithLocale:currentLocale];
    
    NSDate *curDate = [NSDate date];
    
    dateString = [self dateStringFromDate:curDate withFormat:formatString];
    
    return dateString;
}

- (NSString *)getNextDatetimeWithFormat:(NSString *)formatString {
    NSString *dateString = nil;
    NSLocale* currentLocale = [NSLocale currentLocale];
    [[NSDate date] descriptionWithLocale:currentLocale];
    
    NSTimeInterval nextTimeInterval = [self getCurrentDatetimeInSec] + 24*3600;
    NSDate *nextDate = [NSDate dateWithTimeIntervalSince1970:nextTimeInterval];
    
    dateString = [self dateStringFromDate:nextDate withFormat:formatString];
    
    return dateString;
}

- (NSString *)dateStringFromDate:(NSDate *)date withFormat:(NSString *)formatString {
    NSString *dateString = nil;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    [format setLocale:currentLocale];
    [format setTimeZone:[NSTimeZone localTimeZone]];
    
    [format setDateFormat:formatString];
    
    dateString = [format stringFromDate:date];
    
    return dateString;
}

- (NSString *)timeStringFromDate:(NSDate *)date {
    NSString *dateString = nil;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    [format setLocale:currentLocale];
    [format setTimeZone:[NSTimeZone localTimeZone]];
    [format setDateFormat:@"HH:mm"];
    
    // set default NSGregorianCalendar
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitYear |NSCalendarUnitMonth|NSCalendarUnitDay) fromDate:date];
    
    NSDate *dateNew = [gregorianCalendar dateFromComponents:components];
    
    dateString = [format stringFromDate:dateNew];
    format = nil;
    return dateString;
}

- (NSDate *)dateFromString:(NSString *)dateStr {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    [dateFormatter setLocale:currentLocale];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    
    NSDate *date = [dateFormatter dateFromString:dateStr];
    //Apr 25, 2015 5:15:22 AM
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mmZZZ";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZ";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyyMMdd";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"MMM dd/yyyy";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyyMMddHHmmss";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyyMMddHHmm";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"MMM dd, yyyy HH:mm:ss a";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm:ss";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"dd/MM/yyyy";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy/MM/dd";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"HH:mm";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    dateFormatter = nil;
    
    return date;
}

- (NSString *)stringDateFromString:(NSString *)dateStr withFormat:(NSString *)formatString {
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = formatString;
    NSString *rv = [dateFormatter stringFromDate:[self dateFromString:dateStr]];
    dateFormatter = nil;
    return rv;
}

- (NSString *)getDayOfWeek:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:frLocale];
    //    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    //    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    //    [dateFormatter setLocale:currentLocale];
    //    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *res = @"";
    
    NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
    if (curLang == nil) {
        res = [self convertDateOfWeekToVN:[dateFormatter stringFromDate:date]];
    } else {
        if ([curLang isEqualToString:@"vi"]) {
            res = [self convertDateOfWeekToVN:[dateFormatter stringFromDate:date]];
        } else if ([curLang isEqualToString:@"en"]) {
            res = [dateFormatter stringFromDate:date];
        }
    }
    return res;
}

- (NSString *)convertDateOfWeekToVN:(NSString *)dateOfWeek {
    NSString *res = dateOfWeek;
    
    if ([[res lowercaseString] isEqualToString:@"monday"]) {
        res = @"T2";
    } else if ([[res lowercaseString] isEqualToString:@"tuesday"]) {
        res = @"T3";
    } else if ([[res lowercaseString] isEqualToString:@"wednesday"]) {
        res = @"T4";
    } else if ([[res lowercaseString] isEqualToString:@"thursday"]) {
        res = @"T5";
    } else if ([[res lowercaseString] isEqualToString:@"friday"]) {
        res = @"T6";
    } else if ([[res lowercaseString] isEqualToString:@"saturday"]) {
        res = @"T7";
    } else if ([[res lowercaseString] isEqualToString:@"sunday"]) {
        res = @"CN";
    }
    
    return res;
}

//not use
- (NSTimeInterval)getCurrentDatetimeInMinisec {
    
    NSString *curDateString = [self getCurrentDatetimeWithFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *curDate = [self dateFromString:curDateString];
    NSTimeInterval datetime = [curDate timeIntervalSince1970] * 1000;
    
    return datetime;
}

//doesn't count seconds
- (NSTimeInterval)getBeginOfDayInMinisec {
    NSString *curDateString = [self getCurrentDatetimeWithFormat:@"dd/MM/yyyy 00:00:00"];
    NSDate *curDate = [self dateFromString:curDateString];
    NSTimeInterval datetime = [curDate timeIntervalSince1970] * 1000;
    
    return datetime;
}

- (NSTimeInterval)getCurrentDatetimeInSec {
    
    NSString *curDateString = [self getCurrentDatetimeWithFormat:@"dd/MM/yyyy HH:mm:ss"];
    NSDate *curDate = [self dateFromString:curDateString];
    NSTimeInterval datetime = [curDate timeIntervalSince1970];
    
    return datetime;
}

//doesn't count seconds
- (NSTimeInterval)getBeginOfDayInSec {
    NSString *curDateString = [self getCurrentDatetimeWithFormat:@"dd/MM/yyyy 00:00:00"];
    NSDate *curDate = [self dateFromString:curDateString];
    NSTimeInterval datetime = [curDate timeIntervalSince1970];
    
    return datetime;
}
@end
