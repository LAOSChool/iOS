//
//  TimerViewController.h
//  LazzyBee
//
//  Created by HuKhong on 9/11/15.
//  Copyright (c) 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TimerPickerViewDelegate <NSObject>

@optional // Delegate protocols

- (void)btnDoneClick:(id)sender withValueReturned:(NSString *)value;

@end

typedef enum {
    TimerType_CreateAttendance = 0,
    TimerType_CheckAttendance,
    TimerType_Max,
} TIMER_TYPE;

@interface TimerViewController : UIViewController
{
    IBOutlet UIView *viewContainer;
    IBOutlet UIDatePicker *datetimePicker;
    IBOutlet UIButton *btnDone;
    
    IBOutlet UIButton *btnClose;
}

@property(nonatomic, readwrite) id <TimerPickerViewDelegate> delegate;
@property(nonatomic, strong) NSString *dateTime;

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;

@end
