//
//  TeacherAttendanceViewController.h
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeacherAttendanceViewController : UIViewController
{
    IBOutlet UIView *viewTerm;
    IBOutlet UIView *viewInfo;
    IBOutlet UIView *viewTableView;
    IBOutlet UIView *viewDate;
    IBOutlet UIView *viewSession;
    IBOutlet UIButton *btnExpand;
    
    IBOutlet UITableView *studentTableView;
    IBOutlet UISearchBar *searchBar;
    
    IBOutlet UILabel *lbClass;
    
    IBOutlet UILabel *lbDate;
    IBOutlet UILabel *lbSession;
}
@end
