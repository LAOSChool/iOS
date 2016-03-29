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

@interface TimerViewController : UIViewController
{
    IBOutlet UIView *viewContainer;
    IBOutlet UIDatePicker *datetimePicker;
    
}

@property(nonatomic, readwrite) id <TimerPickerViewDelegate> delegate;
@end
