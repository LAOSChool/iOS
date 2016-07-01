//
//  MoreViewController.h
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

typedef enum {
    MoreGroupProfile = 0,
    MoreGroupSchool,
    MoreGroupSettings,
    MoreGroupMax
} MORE_TABLEVIEW_GROUP;

//student enum
typedef enum {
    StudentProfileSectionProfile = 0,
    StudentProfileSectionTimeTable,
    StudentProfileSectionMax
} STUDENT_PROFILE_SECTION;

typedef enum {
    StudentSchoolSectionInfo = 0,
//    StudentSchoolSectionTeacherList,
    StudentSchoolSectionMax
} STUDENT_SCHOOL_SECTION;

//teacher enum
typedef enum {
//    TeacherProfileSectionTimeTable = 0,
    TeacherProfileSectionMax
} TEACHER_PROFILE_SECTION;

typedef enum {
    TeacherSchoolSectionInfo = 0,
    TeacherSchoolSectionStudentList,
    TeacherSchoolSectionMax
} TEACHER_SCHOOL_SECTION;

typedef enum {
    SettingsSectionChangePassword = 0,
    SettingsSectionChangeLanguage,
    SettingsSectionLogout,
    SettingsSectionMax
} SETTINGS_SECTION;


@interface MoreViewController : UIViewController
{
    IBOutlet UIView *viewHeaderContainer;
    
    IBOutlet AsyncImageView *imgAvatar;

    IBOutlet UILabel *lbStudentName;
    IBOutlet UILabel *lbSchoolName;
    IBOutlet UILabel *lbYearAndTerm;
    
    IBOutlet UITableView *moreTableView;
}

@property (nonatomic, strong) UISplitViewController *splitViewController;
@end
