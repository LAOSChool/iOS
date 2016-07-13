//
//  DateTimeHelper.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "DateTimeHelper.h"
#import "LocalizeHelper.h"
#import "CommonDefine.h"
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

- (NSString *)dateStringFromString:(NSString *)dateStr withFormat:(NSString *)formatString {
    NSString *resturnDate = nil;
    NSDate *date = [self dateFromString:dateStr];
    
    resturnDate = [self dateStringFromDate:date withFormat:formatString];
    
    return resturnDate;
}

- (NSDate *)currentDateWithFormat:(NSString *)formatString {
    
    NSDate *resDate = [self dateFromString:[self dateStringFromDate:[NSDate date] withFormat:formatString]];
    
    return resDate;
}

- (NSDate *)nextMonthWithFormat:(NSString *)formatString {
    NSTimeInterval nextTimeInterval = [self getCurrentDatetimeInSec] + 24*3600*30;
    NSDate *nextDate = [NSDate dateWithTimeIntervalSince1970:nextTimeInterval];
    
    NSDate *resDate = [self dateFromString:[self dateStringFromDate:nextDate withFormat:formatString]];
    
    return resDate;
}

- (NSDate *)previousWeekWithFormat:(NSString *)formatString {
    NSTimeInterval nextTimeInterval = [self getCurrentDatetimeInSec] - 24*3600*7;
    NSDate *nextDate = [NSDate dateWithTimeIntervalSince1970:nextTimeInterval];
    
    NSDate *resDate = [self dateFromString:[self dateStringFromDate:nextDate withFormat:formatString]];
    
    return resDate;
}

- (NSDate *)nextWeekWithFormat:(NSString *)formatString {
    NSTimeInterval nextTimeInterval = [self getCurrentDatetimeInSec] + 24*3600*7;
    NSDate *nextDate = [NSDate dateWithTimeIntervalSince1970:nextTimeInterval];
    
    NSDate *resDate = [self dateFromString:[self dateStringFromDate:nextDate withFormat:formatString]];
    
    return resDate;
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
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
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
        dateFormatter.dateFormat = @"yyyy-MM-dd EEEE";
        date = [dateFormatter dateFromString:dateStr];
    }
    
    if (date == nil) {
        dateFormatter.dateFormat = @"EEEE, yyyy-MM-dd";
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
    
    if (date == nil) {
        dateFormatter.dateFormat = @"MM-dd HH:mm";
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
        if ([curLang isEqualToString:LANGUAGE_LAOS]) {
            res = [self convertDateOfWeekToVN:[dateFormatter stringFromDate:date]];
        } else if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
            res = [dateFormatter stringFromDate:date];
        }
    }
    return res;
}

- (NSInteger)convertWeekdayToIndexFromDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];
    NSLocale *frLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:frLocale];

    NSString *day = [dateFormatter stringFromDate:date];
    NSInteger res = 1;
    
    if ([[day lowercaseString] isEqualToString:@"monday"]) {
        res = 1;
    } else if ([[day lowercaseString] isEqualToString:@"tuesday"]) {
        res = 2;
    } else if ([[day lowercaseString] isEqualToString:@"wednesday"]) {
        res = 3;
    } else if ([[day lowercaseString] isEqualToString:@"thursday"]) {
        res = 4;
    } else if ([[day lowercaseString] isEqualToString:@"friday"]) {
        res = 5;
    } else if ([[day lowercaseString] isEqualToString:@"saturday"]) {
        res = 6;
    } else if ([[day lowercaseString] isEqualToString:@"sunday"]) {
        res = 7;
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

- (NSTimeInterval)timeIntervalOfDateString:(NSString *)dateStr {
    NSDate *curDate = [self dateFromString:dateStr];
    NSTimeInterval datetime = [curDate timeIntervalSince1970];
    
    return datetime;
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

- (NSString *)convertMonthFromInt:(NSInteger)month {
    NSString *res = @"";
    
    switch (month) {
        case 1:
            res = LocalizedString(@"Jan");
            break;
            
        case 2:
            res = LocalizedString(@"Feb");
            break;
        case 3:
            res = LocalizedString(@"Mar");
            break;
        case 4:
            res = LocalizedString(@"Apr");
            break;
        case 5:
            res = LocalizedString(@"May");
            break;
        case 6:
            res = LocalizedString(@"Jun");
            break;
        case 7:
            res = LocalizedString(@"Jul");
            break;
        case 8:
            res = LocalizedString(@"Aug");
            break;
        case 9:
            res = LocalizedString(@"Sep");
            break;
        case 10:
            res = LocalizedString(@"Oct");
            break;
        case 11:
            res = LocalizedString(@"Nov");
            break;
        case 12:
            res = LocalizedString(@"Dec");
            break;
            
        default:
            break;
    }
    
    return res;
}
@end
