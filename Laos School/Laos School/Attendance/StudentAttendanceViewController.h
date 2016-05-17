//
//  StudentAttendanceViewController.h
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentAttendanceViewController : UIViewController
{
    IBOutlet UILabel *lbTotal;
    IBOutlet UILabel *lbRequested;
    IBOutlet UILabel *lbNoRequested;
    IBOutlet UILabel *lbFullday;
    IBOutlet UILabel *lbSession;
    IBOutlet UILabel *lbFulldayGotReasonValue;
    IBOutlet UILabel *lbFulldayNoReasonValue;
    IBOutlet UILabel *lbSessionGotReasonValue;
    IBOutlet UILabel *lbSessionNoReasonValue;
    IBOutlet UITableView *attendanceTable;
    IBOutlet UIView *viewHeader;
    
}
@end
