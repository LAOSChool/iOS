//
//  InformationViewController.h
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AttendanceObject.h"

@interface InformationViewController : UIViewController
{
    IBOutlet UILabel *lbDate;
    IBOutlet UITextView *txtContent;

}

@property(nonatomic, strong) AttendanceObject *attObj;

- (void)loadInformation;
@end
