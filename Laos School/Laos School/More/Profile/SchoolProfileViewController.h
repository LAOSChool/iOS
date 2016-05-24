//
//  SchoolProfileViewController.h
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolProfileViewController : UIViewController
{
    
    IBOutlet UIView *viewHeaderContainer;
    IBOutlet UILabel *lbClass;
    IBOutlet UILabel *lbTermOne;
    IBOutlet UILabel *lbTermTwo;
    IBOutlet UILabel *lbAllYear;
    IBOutlet UIButton *btnMoreInfo;
    IBOutlet UITableView *scoreTableView;
    
    IBOutlet UILabel *lbSchoolYear;
    IBOutlet UIButton *btnShow;
    
}
@end
