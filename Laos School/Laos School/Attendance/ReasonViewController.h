//
//  ReasonViewController.h
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckAttendanceObject.h"
#import "TTSessionObject.h"

@interface ReasonViewController : UIViewController
{
    IBOutlet UIView *navigationView;

    IBOutlet UITableView *reasonTableView;
    IBOutlet UIView *containerView;
    IBOutlet UILabel *lbTitle;
    IBOutlet UIButton *btnSend;
    IBOutlet UILabel *lbFullday;
    IBOutlet UIButton *btnFullday;
}

- (void)loadInformation;

@property (nonatomic, strong) CheckAttendanceObject *checkAttendanceObj;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) TTSessionObject *currentSession;
@property (nonatomic, strong) NSMutableArray *reasonList;
@end
