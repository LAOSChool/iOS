//
//  AddScoresViewController.h
//  Laos School
//
//  Created by HuKhong on 6/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubjectObject.h"

@interface AddScoresViewController : UIViewController
{
    IBOutlet UIView *viewClass;
    IBOutlet UIView *viewInfo;
    IBOutlet UIView *viewTableView;
    IBOutlet UIView *viewSubject;
    IBOutlet UIView *viewScoreType;
    
    IBOutlet UITableView *studentTableView;
    IBOutlet UISearchBar *searchBar;
    
    IBOutlet UILabel *lbClass;
    
    IBOutlet UILabel *lbSubject;
    IBOutlet UILabel *lbScoreType;
}

@property (nonatomic, strong) NSArray *subjectsArray;

@property (nonatomic, strong) SubjectObject *selectedSubject;

@end
