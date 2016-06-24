//
//  MoreViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "MoreViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "PersonalInfoViewController.h"
#import "SchoolProfileViewController.h"
#import "SettingsViewController.h"
#import "ChangeLanguageViewController.h"
#import "SchoolInfoViewController.h"
#import "TeacherListViewController.h"
#import "ScoresViewController.h"
#import "LoginViewController.h"
#import "StudentTimeTableViewController.h"
#import "StudentsListViewController.h"
#import "AppDelegate.h"
#import "ShareData.h"
#import "ChangePasswordViewController.h"


#import "LocalizeHelper.h"
#import "Common.h"
#import "UIView+CustomUIView.h"
#import "ArchiveHelper.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setTitle:LocalizedString(@"More")];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];

    
    //make avatar round
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2;
    imgAvatar.clipsToBounds = YES;
    
    [viewHeaderContainer setBackgroundColor:GREEN_COLOR];
    
    [imgAvatar setBackgroundColor:BLUE_COLOR];
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    lbSchoolName.text = userObj.schoolName;
    lbStudentName.text = [NSString stringWithFormat:@"%@\n%@", userObj.displayName, classObj.className];
    lbYearAndTerm.text = [NSString stringWithFormat:@"%@ Term %@", classObj.currentYear, classObj.currentTerm];
    
    if (userObj.avatarPath && userObj.avatarPath.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgAvatar];
        
        //load the image
        imgAvatar.imageURL = [NSURL URLWithString:userObj.avatarPath];
        
    } else {
        if ([userObj.gender isEqualToString:@"male"]) {
            imgAvatar.image = [UIImage imageNamed:@"ic_male.png"];
            
        } else if ([userObj.gender isEqualToString:@"female"]) {
            imgAvatar.image = [UIImage imageNamed:@"ic_female.png"];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return TRUE;
//}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return MoreGroupMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    
    if (userObj.userRole == UserRole_Student) {
        if (section == MoreGroupProfile) {
            return StudentProfileSectionMax;
            
        } else if (section == MoreGroupSchool) {
            return StudentSchoolSectionMax;
            
        }else if (section == MoreGroupSettings) {
            return SettingsSectionMax;
            
        }
    } else if (userObj.userRole == UserRole_Teacher) {
        if (section == MoreGroupProfile) {
            return TeacherProfileSectionMax;
            
        } else if (section == MoreGroupSchool) {
            return TeacherSchoolSectionMax;
            
        }else if (section == MoreGroupSettings) {
            return SettingsSectionMax;
            
        }
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {    
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *moreCellIdentifier = @"MoreCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreCellIdentifier];
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
        
    switch (indexPath.section) {
        case MoreGroupProfile:
        {
            if (userObj.userRole == UserRole_Student) {
                switch (indexPath.row) {
                        
                    case StudentProfileSectionProfile:
                    {
                        cell.textLabel.text = LocalizedString(@"School records");
                        cell.imageView.image = [UIImage imageNamed:@"ic_storage_gray.png"];
                    }
                        break;
                       
                    case StudentProfileSectionTimeTable:
                    {
                        cell.textLabel.text = LocalizedString(@"Time table");
                        cell.imageView.image = [UIImage imageNamed:@"ic_calendar_gray.png"];
                    }
                        break;
                        
                    default:
                        break;
                }
            } else if (userObj.userRole == UserRole_Teacher) {
                switch (indexPath.row) {
                    case TeacherProfileSectionTimeTable:
                    {
                        cell.textLabel.text = LocalizedString(@"Time table");
                        cell.imageView.image = [UIImage imageNamed:@"ic_calendar_gray.png"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
            
        case MoreGroupSchool:
        {
            if (userObj.userRole == UserRole_Student) {
                switch (indexPath.row) {
                    case StudentSchoolSectionInfo:
                    {
                        cell.textLabel.text = LocalizedString(@"School information");
                        cell.imageView.image = [UIImage imageNamed:@"ic_school.png"];
                    }
                        break;
                    /*
                    case StudentSchoolSectionTeacherList:
                    {
                        cell.textLabel.text = LocalizedString(@"Teachers list");
                        cell.imageView.image = [UIImage imageNamed:@"ic_group_gray.png"];
                    }
                        break;
                        */
                    default:
                        break;
                }
                
            } else if (userObj.userRole == UserRole_Teacher) {
                switch (indexPath.row) {
                    case TeacherSchoolSectionInfo:
                    {
                        cell.textLabel.text = LocalizedString(@"School information");
                        cell.imageView.image = [UIImage imageNamed:@"ic_school.png"];
                    }
                        break;
                        
                    case TeacherSchoolSectionStudentList:
                    {
                        cell.textLabel.text = LocalizedString(@"Students list");
                        cell.imageView.image = [UIImage imageNamed:@"ic_group_gray.png"];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
            
        case MoreGroupSettings:
        {
            switch (indexPath.row) {
                case SettingsSectionChangePassword:
                {
                    cell.textLabel.text = LocalizedString(@"Change password");
                    cell.imageView.image = [UIImage imageNamed:@"ic_key.png"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                    
                case SettingsSectionChangeLanguage:
                {
                    cell.textLabel.text = LocalizedString(@"Change language");
                    cell.imageView.image = [UIImage imageNamed:@"ic_language_gray.png"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                    
                case SettingsSectionLogout:
                {
                    cell.textLabel.text = LocalizedString(@"Logout");
                    cell.imageView.image = [UIImage imageNamed:@"ic_exit_gray.png"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    
    switch (indexPath.section) {
        case MoreGroupProfile:
        {
            if (userObj.userRole == UserRole_Student) {
                switch (indexPath.row) {
                    case StudentProfileSectionProfile:
                    {
                        SchoolProfileViewController *schoolProfileView = [[SchoolProfileViewController alloc] initWithNibName:@"SchoolProfileViewController" bundle:nil];
                        
//                        if (IS_IPAD) {
//                            UINavigationController *navSchoolProfile = [[UINavigationController alloc] initWithRootViewController:schoolProfileView];
//                            
//                            [self.splitViewController showDetailViewController:navSchoolProfile sender:self];
//                        } else {
                            [self.navigationController pushViewController:schoolProfileView animated:YES];
//                        }
                    }
                        break;
                        //Time table
                    case StudentProfileSectionTimeTable:
                    {
                        StudentTimeTableViewController *timeTableView = [[StudentTimeTableViewController alloc] initWithNibName:@"StudentTimeTableViewController" bundle:nil];
                        
//                        if (IS_IPAD) {
//                            UINavigationController *navTimeTableView = [[UINavigationController alloc] initWithRootViewController:timeTableView];
//                            
//                            [self.splitViewController showDetailViewController:navTimeTableView sender:self];
//                        } else {
                            [self.navigationController pushViewController:timeTableView animated:YES];
//                        }
                    }
                        break;
                        
                    default:
                        break;
                }
                
            } else if (userObj.userRole == UserRole_Teacher) {
                switch (indexPath.row) {
                        //Time table
                    case TeacherProfileSectionTimeTable:
                    {
                        
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
            
        case MoreGroupSchool:
        {
            if (userObj.userRole == UserRole_Student) {
                switch (indexPath.row) {
                    case StudentSchoolSectionInfo:
                    {
                        SchoolInfoViewController *schoolInfoView = [[SchoolInfoViewController alloc] initWithNibName:@"SchoolInfoViewController" bundle:nil];
                        
                        [self.navigationController pushViewController:schoolInfoView animated:YES];
                    }
                        break;
                     /*
                    case StudentSchoolSectionTeacherList:
                    {
                        TeacherListViewController *teacherListView = [[TeacherListViewController alloc] initWithNibName:@"TeacherListViewController" bundle:nil];
                        
                        [self.navigationController pushViewController:teacherListView animated:YES];
                    }
                        break;
                       */ 
                    default:
                        break;
                }
                
            } else if (userObj.userRole == UserRole_Teacher) {
                switch (indexPath.row) {
                    case TeacherSchoolSectionInfo:
                    {
                        SchoolInfoViewController *schoolInfoView = [[SchoolInfoViewController alloc] initWithNibName:@"SchoolInfoViewController" bundle:nil];
                        
                        [self.navigationController pushViewController:schoolInfoView animated:YES];
                    }
                        break;
                        
                    case TeacherSchoolSectionStudentList:
                    {
                        StudentsListViewController *studentListView = [[StudentsListViewController alloc] initWithNibName:@"StudentsListViewController" bundle:nil];
                        studentListView.studentListType = StudentList_Normal;
                        
                        [self.navigationController pushViewController:studentListView animated:YES];
                    }
                        break;
                        
                    default:
                        break;
                }
            }
        }
            break;
            
        case MoreGroupSettings:
        {
            switch (indexPath.row) {
                case SettingsSectionChangePassword:
                {
                    ChangePasswordViewController *changePassView = [[ChangePasswordViewController alloc] initWithNibName:@"ChangePasswordViewController" bundle:nil];

                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:changePassView];
                    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
                    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
                    
                    [self presentViewController:nav animated:YES completion:nil];

                }
                    break;
                    
                case SettingsSectionChangeLanguage:
                {
                    
                    ChangeLanguageViewController *changeLanguageView = [[ChangeLanguageViewController alloc] initWithNibName:@"ChangeLanguageViewController" bundle:nil];

                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:changeLanguageView];
                    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
                    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
                    
                    [self presentViewController:nav animated:YES completion:nil];

                }
                    break;
                    
                case SettingsSectionLogout:
                {
                    [self backTologinScreen];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)backTologinScreen {
    //clear authen key
    [[ArchiveHelper sharedArchiveHelper] clearAuthKey];
    
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    LoginViewController *loginView = nil;
    
    if (IS_IPAD) {
        loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPad" bundle:nil];
    } else {
        loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    }

    appDelegate.window.rootViewController = loginView;
}

#pragma mark button and gesture handle
- (IBAction)btnEditClick:(id)sender {
    PersonalInfoViewController *personalInfoView = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:personalInfoView];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

@end
