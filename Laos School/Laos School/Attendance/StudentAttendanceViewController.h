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
    IBOutlet UILabel *lbTotalSection;
    IBOutlet UILabel *lbPermittedSection;
    IBOutlet UILabel *lbNoPermittedSection;
    IBOutlet UITableView *permissionTable;
    
}
@end
