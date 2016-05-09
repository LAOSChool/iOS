//
//  TimerViewController.m
//  LazzyBee
//
//  Created by HuKhong on 9/11/15.
//  Copyright (c) 2015 Born2go. All rights reserved.
//

#import "TimerViewController.h"
#import "Common.h"

#define DATE_FORMATE @"yyyy-MM-dd EEEE"

@interface TimerViewController ()

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    [datetimePicker setLocale:currentLocale];
    [datetimePicker setTimeZone:[NSTimeZone localTimeZone]];
    
    if (_dateTime && _dateTime.length > 0) {
        datetimePicker.date = [[DateTimeHelper sharedDateTimeHelper] dateFromString:_dateTime];
        
    } else {
        datetimePicker.date = [[DateTimeHelper sharedDateTimeHelper] currentDateWithFormat:DATE_FORMATE];
    }
    
    datetimePicker.minimumDate = [NSDate date];
    datetimePicker.maximumDate = [[DateTimeHelper sharedDateTimeHelper] nextMonthWithFormat:DATE_FORMATE];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setDateTime:(NSString *)dateTime {
    _dateTime = dateTime;
    
    if (_dateTime && _dateTime.length > 0) {
        datetimePicker.date = [[DateTimeHelper sharedDateTimeHelper] dateFromString:_dateTime];
        
    } else {
        datetimePicker.date = [[DateTimeHelper sharedDateTimeHelper] currentDateWithFormat:DATE_FORMATE];
    }
}

- (IBAction)tapGestureHandle:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)btnDoneClick:(id)sender {
//    NSString *remindTime = [[Common sharedCommon] dateStringFromDate:datetimePicker.date withFormat:@"HH:mm"];
//    [[Common sharedCommon] saveDataToUserDefaultStandard:remindTime withKey:KEY_REMIND_TIME];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSettingsScreen" object:nil];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    [self.delegate btnDoneClick:self withValueReturned:[[DateTimeHelper sharedDateTimeHelper] dateStringFromDate:datetimePicker.date withFormat:DATE_FORMATE]];
}

@end
