//
//  MoreViewController.h
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MoreGroupProfile = 0,
    MoreGroupSchool,
    MoreGroupSettings,
    MoreGroupMax
} MORE_TABLEVIEW_GROUP;

typedef enum {
    ProfileSectionProfile = 0,
    ProfileSectionTimeTable,
    ProfileSectionMax
} PROFILE_SECTION;

typedef enum {
    SchoolSectionInfo = 0,
    SchoolSectionTeacherList,
    SchoolSectionMax
} SCHOOL_SECTION;

typedef enum {
    SettingsSectionChangePassword = 0,
    SettingsSectionLogout,
    SettingsSectionMax
} SETTINGS_SECTION;


@interface MoreViewController : UIViewController
{
    IBOutlet UIView *viewHeaderContainer;
    
    IBOutlet UIImageView *imgAvatar;
    IBOutlet UILabel *lbStudentName;
    IBOutlet UILabel *lbSchoolName;
    IBOutlet UILabel *lbYearAndTerm;
    
    IBOutlet UITableView *moreTableView;
}

@property (nonatomic, strong) UISplitViewController *splitViewController;
@end
