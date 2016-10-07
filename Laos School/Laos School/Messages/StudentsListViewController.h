//
//  StudentsListViewController.h
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    StudentList_Normal = 0,
    StudentList_Message,
    StudentList_Max
} STUDENT_LIST_TYPE;

@interface StudentsListViewController : UIViewController
{
    IBOutlet UITableView *studentsTableView;
    NSMutableArray *studentsArray;
    IBOutlet UILabel *lbCount;
    
    IBOutlet UIButton *btnCheck;
    
    IBOutlet UISearchBar *searchBar;
}

@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, assign) STUDENT_LIST_TYPE studentListType;
@end
