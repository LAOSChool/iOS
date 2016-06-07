//
//  TeacherScoresViewController.h
//  Laos School
//
//  Created by HuKhong on 3/30/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeacherScoresViewController : UIViewController
{
    IBOutlet UIView *viewTerm;
    IBOutlet UIView *viewInfo;
    IBOutlet UIView *viewSubject;
    IBOutlet UIView *viewTableView;
    IBOutlet UIButton *btnExpand;
    
    IBOutlet UITableView *studentTableView;
    IBOutlet UISearchBar *searchBar;
    
    IBOutlet UILabel *lbClass;
    IBOutlet UILabel *lbSubject;
    
}


@end
