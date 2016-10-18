//
//  TimerViewController.m
//  LazzyBee
//
//  Created by HuKhong on 9/11/15.
//  Copyright (c) 2015 Born2go. All rights reserved.
//

#import "TimerViewController.h"
#import "Common.h"
#import "CommonDefine.h"
#import "LocalizeHelper.h"

@interface TimerViewController ()

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [btnDone setTitle:LocalizedString(@"Done") forState:UIControlStateNormal];
    [btnClose setTitle:LocalizedString(@"Close") forState:UIControlStateNormal];

    NSString *locale = [self currentLocalIdentifier];
    NSLocale *currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
    [datetimePicker setLocale:currentLocale];
    [datetimePicker setTimeZone:[NSTimeZone localTimeZone]];
    
    datetimePicker.date        = _date;
    datetimePicker.minimumDate = _minimumDate;
    datetimePicker.maximumDate = _maximumDate;
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

- (NSString *)currentLocalIdentifier {
    NSString *res = @"";
    
    NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
    if (curLang == nil) {
        res = @"lo_LA";
        
    } else {
        if ([curLang isEqualToString:LANGUAGE_LAOS]) {
            res = @"lo_LA";
            
        } else if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
            res = @"en_US";
        }
    }
    return res;
}

- (void)setDate:(NSDate *)date {
    _date = date;
    datetimePicker.date = date;
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    datetimePicker.minimumDate = minimumDate;
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    _maximumDate = maximumDate;
    datetimePicker.maximumDate = maximumDate;
}

- (IBAction)tapGestureHandle:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)btnCloseClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)btnDoneClick:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    [self.delegate btnDoneClick:self withValueReturned:[[DateTimeHelper sharedDateTimeHelper] dateStringFromDate:datetimePicker.date withFormat:ATTENDANCE_DATE_FORMATE]];
}

@end
