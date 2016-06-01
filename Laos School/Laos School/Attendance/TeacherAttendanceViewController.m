//
//  TeacherAttendanceViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherAttendanceViewController.h"
#import "StdTimeTableDayViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "StudentsListTableViewCell.h"
#import "LevelPickerViewController.h"
#import "TimerViewController.h"
#import "ReasonViewController.h"
#import "CheckAttendanceObject.h"
#import "AttendanceObject.h"
#import "AppDelegate.h"

#import "DateTimeHelper.h"
#import "CommonDefine.h"
#import "UserObject.h"
#import "TTSessionObject.h"
#import "ShareData.h"
#import "RequestToServer.h"

#import "MGSwipeButton.h"
#import "SVProgressHUD.h"

#define API_ATTENDANCE_DATE_FORMATE @"yyyy-MM-dd"

@interface TeacherAttendanceViewController ()
{
    BOOL isShowingViewInfo;
    NSMutableArray *checkAttendanceArray;
    NSMutableArray *searchResults;
    
    NSMutableArray *studentsArray;
    NSMutableArray *sessionsArray;
    NSMutableArray *rollupArray;
    
    TTSessionObject *currentSession;
    
    LevelPickerViewController *dataPicker;
    TimerViewController *dateTimePicker;
    ReasonViewController *reasonView;
    
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
}
@end

@implementation TeacherAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Attendance")];
    
    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClick:)];
    
    self.navigationItem.rightBarButtonItems = @[btnAction];
    
    isShowingViewInfo = YES;
    currentSession = nil;
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    lbClass.text = classObj.className;
    lbDate.text = [[DateTimeHelper sharedDateTimeHelper] dateStringFromDate:[NSDate date] withFormat:ATTENDANCE_DATE_FORMATE];
    
    if (checkAttendanceArray == nil) {
        checkAttendanceArray = [[NSMutableArray alloc] init];
    }
    
    if (studentsArray == nil) {
        studentsArray = [[NSMutableArray alloc] init];
    }
    
    if (sessionsArray == nil) {
        sessionsArray = [[NSMutableArray alloc] init];
    }
    
    if (rollupArray == nil) {
        rollupArray = [[NSMutableArray alloc] init];
    }
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadStudentsData) forControlEvents:UIControlEventValueChanged];
    [studentTableView addSubview:refreshControl];
    
    [viewTerm setBackgroundColor:GREEN_COLOR];
    [viewInfo setBackgroundColor:[UIColor whiteColor]];
    [viewDate setBackgroundColor:GREEN_COLOR];
    [viewSession setBackgroundColor:GREEN_COLOR];
    
    lbSession.text = LocalizedString(@"Select a session");
    [lbSession setTextColor:[UIColor lightGrayColor]];
    
    [self loadData];

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

- (void)reloadStudentsData {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD show];

    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    NSString *dateStr = [[DateTimeHelper sharedDateTimeHelper] dateStringFromString:lbDate.text withFormat:API_ATTENDANCE_DATE_FORMATE];
    
    [requestToServer getStudentListWithAndAttendanceInfo:classObj.classID inDate:dateStr];
}

- (IBAction)actionButtonClick:(id)sender {
    [self dismissPicker];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"xxx"), LocalizedString(@"yyy"), nil];
    
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if (IS_IPAD) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [searchResults count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//    NSString *headerTitle = @"";
//    headerTitle = [NSString stringWithFormat:@"%@: %lu", LocalizedString(@"Count"), (unsigned long)[_selectedArray count]];
//
//    return headerTitle;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//
//    header.textLabel.textColor = [UIColor grayColor];
//    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
//    CGRect headerFrame = header.frame;
//    header.textLabel.frame = headerFrame;
//    header.textLabel.textAlignment = NSTextAlignmentLeft;
//
//    header.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *studentsListAttandanceCellIdentifier = @"StudentsListCellIdentifier";
    
    StudentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsListAttandanceCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentsListTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.delegate = (id)self;
    
    CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];
    
    UserObject *userObject = checkAttObj.userObject;
   
    cell.lbFullname.text = userObject.displayName;
    cell.lbAdditionalInfo.text = userObject.nickName;
    
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgAvatar];
    
    //load the image
    cell.imgAvatar.imageURL = [NSURL URLWithString:userObject.avatarPath];
    
    if (checkAttObj.checkedFlag) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (checkAttObj.state == 1) {
        [cell.contentView setBackgroundColor:[UIColor darkGrayColor]];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
        
        cell.lbFullname.textColor = [UIColor whiteColor];
        cell.lbAdditionalInfo.textColor = [UIColor whiteColor];
        
        if (checkAttObj.hasRequest == 1) {
            cell.lbNoreason.hidden = YES;
        } else {
            cell.lbNoreason.hidden = NO;
            cell.lbNoreason.text = LocalizedString(@"No reason");
        }
        
    } else {
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor whiteColor]];
        
        cell.lbFullname.textColor = [UIColor darkGrayColor];
        cell.lbAdditionalInfo.textColor = [UIColor darkGrayColor];
    }
    
    return cell;
}


#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];
    
    checkAttObj.checkedFlag = YES;
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchText.length == 0) {
        self->searchResults = [checkAttendanceArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"userNameForSearch CONTAINS[cd] %@", searchText];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [checkAttendanceArray filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    
    [studentTableView reloadData];
}

#pragma mark button click
- (IBAction)btnExpandClick:(id)sender {
    isShowingViewInfo = !isShowingViewInfo;
    [self showHideInfoView:isShowingViewInfo];
    
    
}

- (void)showHideInfoView:(BOOL)showHideFlag {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        CGRect rectViewTerm = viewTerm.frame;
        CGRect rectViewInfo = viewInfo.frame;
        CGRect rectViewTableView = viewTableView.frame;
        
        if (showHideFlag) {
            rectViewInfo.origin.y = rectViewTerm.size.height + 2;
            
            [viewInfo setFrame:rectViewInfo];
            
            rectViewTableView.origin.y = rectViewInfo.origin.y + rectViewInfo.size.height;
            rectViewTableView.size.height = self.view.frame.size.height - rectViewTableView.origin.y;
            
            [viewTableView setFrame:rectViewTableView];
            
        } else {
            rectViewInfo.origin.y = rectViewTerm.size.height - rectViewInfo.size.height;
            
            [viewInfo setFrame:rectViewInfo];
            
            rectViewTableView.origin.y = rectViewTerm.origin.y + rectViewTerm.size.height;
            rectViewTableView.size.height = self.view.frame.size.height - rectViewTableView.origin.y;
            
            [viewTableView setFrame:rectViewTableView];
            
        }
    }];
}

#pragma mark actions sheet handle
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            
        }
    }
    
}

#pragma mark swipe delegate
//-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
//{
//    return YES;
//}

- (NSArray*)swipeTableCell:(StudentsListTableViewCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
{

        swipeSettings.transition = MGSwipeTransitionStatic;
        
        if (direction == MGSwipeDirectionRightToLeft) {
            expansionSettings.fillOnTrigger = NO;
            expansionSettings.threshold = 1.1;
            
       /*     MGSwipeButton *btnInform = nil;
            
            btnInform = [MGSwipeButton buttonWithTitle:LocalizedString(@"Inform") icon:[UIImage imageNamed:@"ic_alert_white"] backgroundColor:ALERT_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];*/
            
            NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
            CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];
            
            if (checkAttObj.state == 1) {
                MGSwipeButton *btnCancel = nil;
                
                btnCancel = [MGSwipeButton buttonWithTitle:LocalizedString(@"Cancel") icon:[UIImage imageNamed:@"ic_cancel_white.png"] backgroundColor:ALERT_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                    return NO;
                }];
                
                return @[btnCancel];
                
            } else {
                MGSwipeButton *btnOff = nil;
                
                btnOff = [MGSwipeButton buttonWithTitle:LocalizedString(@"Off") icon:[UIImage imageNamed:@"ic_off"] backgroundColor:OFF_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                    return NO;
                }];
                
                return @[btnOff];
            }
            
      /*      MGSwipeButton *btnLate = nil;
            
            btnLate = [MGSwipeButton buttonWithTitle:LocalizedString(@"Late") icon:[UIImage imageNamed:@"ic_late"] backgroundColor:LATE_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];*/
        }
    
    return nil;
}

- (BOOL)swipeTableCell:(StudentsListTableViewCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
    CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];

    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        if (checkAttObj.state == 1) {   //cancel
            
            
        } else {
            
            [self displayReasonView];
        }
        
    }

    return NO;  //Don't autohide
}


#pragma mark show pick
//- (IBAction)btnChooseClassClick:(id)sender {
//    [self showDataPicker:Picker_Classes];
//}
//
//- (IBAction)btnChooseSubjectClick:(id)sender {
//    [self showDataPicker:Picker_Subject];
//}


- (IBAction)btnChooseDateClick:(id)sender {
    [self showDateTimePicker];
}


- (IBAction)btnChooseSectionClick:(id)sender {
    
    StdTimeTableDayViewController *timeDayViewController = [[StdTimeTableDayViewController alloc] initWithNibName:@"StdTimeTableDayViewController" bundle:nil];
    timeDayViewController.title = LocalizedString(@"Select session");
    timeDayViewController.sessionsArray = sessionsArray;
    timeDayViewController.timeTableType = TimeTableOneDay;
    timeDayViewController.selectedSession = currentSession;
    
    timeDayViewController.delegate = (id)self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:timeDayViewController];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}


- (IBAction)btnShowListClick:(id)sender {
    isShowingViewInfo = NO;
    [self showHideInfoView:isShowingViewInfo];
}

- (void)btnDoneClick:(id)sender withObjectReturned:(TTSessionObject *)returnedObj {
    currentSession = returnedObj;
    
    [lbSession setTextColor:[UIColor whiteColor]];
    
    lbSession.text = [NSString stringWithFormat:@"%@ - %@", currentSession.session, currentSession.subject];
    
    [self prepareDataForChecking];
    [studentTableView reloadData];
}

#pragma mark data picker
- (void)showDataPicker:(PICKER_TYPE)pickerType {
    dataPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    dataPicker.pickerType = pickerType;
    dataPicker.view.alpha = 0;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [dataPicker.view setFrame:rect];
    
    [self.view addSubview:dataPicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        dataPicker.view.alpha = 1;
    }];
}

- (void)showDateTimePicker {
    dateTimePicker = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
    
    if (lbDate.text.length > 0) {
        dateTimePicker.date = [[DateTimeHelper sharedDateTimeHelper] dateFromString:lbDate.text];
        
    } else {
        dateTimePicker.date = [[DateTimeHelper sharedDateTimeHelper] currentDateWithFormat:ATTENDANCE_DATE_FORMATE];
    }
    
    dateTimePicker.minimumDate = [[DateTimeHelper sharedDateTimeHelper] previousWeekWithFormat:ATTENDANCE_DATE_FORMATE];
    dateTimePicker.maximumDate = dateTimePicker.date;
    
    dateTimePicker.view.alpha = 0;
    dateTimePicker.delegate = (id)self;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [dateTimePicker.view setFrame:rect];
    
    [self.view addSubview:dateTimePicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        dateTimePicker.view.alpha = 1;
    }];
}

- (void)dismissPicker {
    if (dataPicker && dataPicker.view.alpha == 1) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            dataPicker.view.alpha = 0;
        } completion:^(BOOL finished) {
            [dataPicker.view removeFromSuperview];
        }];
    }
    
    if (dateTimePicker && dateTimePicker.view.alpha == 1) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            dateTimePicker.view.alpha = 0;
        } completion:^(BOOL finished) {
            [dateTimePicker.view removeFromSuperview];
        }];
    }
}

- (void)btnDoneClick:(id)sender withValueReturned:(NSString *)value {
    
}

- (void)displayReasonView {
    if (reasonView == nil) {
        reasonView = [[ReasonViewController alloc] initWithNibName:@"ReasonViewController" bundle:nil];
    }
    
    reasonView.view.alpha = 0;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect rect = appDelegate.window.frame;
    [reasonView.view setFrame:rect];
    
    [appDelegate.window addSubview:reasonView.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        reasonView.view.alpha = 1;
    }];

}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [studentsArray removeAllObjects];
    [checkAttendanceArray removeAllObjects];
    [sessionsArray removeAllObjects];
    [rollupArray removeAllObjects];
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    
    NSDictionary *messageObject = [jsonObj objectForKey:@"messageObject"];
    
    if (messageObject != (id)[NSNull null]) {
        NSArray *students = [messageObject objectForKey:@"students"];
        NSArray *timetables = [messageObject objectForKey:@"timetables"];
        NSArray *attendances = [messageObject objectForKey:@"attendances"];
        
        [self addStudentsListFromDictionaryArray:students];
        [self addTimeTableFromDictionaryArray:timetables];
        [self addAttendancesFromDictionaryArray:attendances];
        
        [self prepareDataForChecking];
    }
    
    [studentTableView reloadData];
    
}

- (void)addStudentsListFromDictionaryArray:(NSArray *)students {
    if (students != (id)[NSNull null]) {
        
        for (NSDictionary *studentDict in students) {
            UserObject *userObject = [[UserObject alloc] init];
            
            if ([studentDict valueForKey:@"id"] != (id)[NSNull null]) {
                userObject.userID = [NSString stringWithFormat:@"%@", [studentDict valueForKey:@"id"]];
            }
            
            if ([studentDict valueForKey:@"sso_id"] != (id)[NSNull null]) {
                userObject.username = [studentDict valueForKey:@"sso_id"];
            }
            
            if ([studentDict valueForKey:@"fullname"] != (id)[NSNull null]) {
                userObject.displayName = [studentDict valueForKey:@"fullname"];
            }
            
            if ([studentDict valueForKey:@"nickname"] != (id)[NSNull null]) {
                userObject.nickName = [studentDict valueForKey:@"nickname"];
            }
            
            if ([studentDict valueForKey:@"photo"] != (id)[NSNull null]) {
                userObject.avatarPath = [studentDict valueForKey:@"photo"];
            }
            
            if ([studentDict valueForKey:@"phone"] != (id)[NSNull null]) {
                userObject.phoneNumber = [studentDict valueForKey:@"phone"];
            }
            
            if ([studentDict valueForKey:@"roles"] != (id)[NSNull null]) {
                NSString *role = [studentDict objectForKey:@"roles"];
                if (role != (id)[NSNull null] && role && role.length > 0) {
                    
                    if ([role isEqualToString:USER_ROLE_STUDENT]) {
                        userObject.userRole = UserRole_Student;
                        userObject.permission = Permission_Normal | Permission_SendMessage;
                        
                    } else if ([role isEqualToString:USER_ROLE_PRESIDENT]) {
                        userObject.userRole = UserRole_Student;
                        userObject.permission = Permission_Normal | Permission_SendMessage | Permission_CheckAttendance;
                        
                    } else if ([role isEqualToString:USER_ROLE_HEAD_TEACHER]) {
                        userObject.userRole = UserRole_Teacher;
                        userObject.permission = Permission_Normal | Permission_SendMessage | Permission_CheckAttendance | Permission_SendAnnouncement | Permission_AddScore;
                        
                    }
                    
                }
            }
            
            if ([studentDict valueForKey:@"school_id"] != (id)[NSNull null]) {
                userObject.shoolID = [studentDict objectForKey:@"school_id"];
            }
            
            if ([studentDict valueForKey:@"schoolName"] != (id)[NSNull null]) {
                userObject.schoolName = [studentDict objectForKey:@"schoolName"];
            }
            
            [studentsArray addObject:userObject];
        }
    }
}

- (void)addTimeTableFromDictionaryArray:(NSArray *)timetables {
    if (timetables != (id)[NSNull null]) {
        
        for (NSDictionary *sessionDict in timetables) {
            /*
             {
             "class_id" = 1;
             description = "Test timetable";
             id = 4;
             "school_id" = 1;
             session = "Ra choi giua gio@20 phut";
             "session_id" = 4;
             subject = English;
             "subject_id" = 4;
             "teacher_id" = 9;
             "teacher_name" = "Teacher 4 - Class 4";
             term = "Term 1";
             "term_id" = 1;
             weekday = "Thu 2";
             "weekday_id" = 1;
             }
             
             @property (nonatomic, strong) NSString *weekDay;
             @property (nonatomic, strong) NSString *subject;
             @property (nonatomic, strong) NSString *session;
             @property (nonatomic, assign) SESSION_TYPE sessionType;
             @property (nonatomic, strong) NSString *duration;
             @property (nonatomic, strong) NSString *teacherName;
             */
            TTSessionObject *sessionObj = [[TTSessionObject alloc] init];
            
            if ([sessionDict valueForKey:@"subject"] != (id)[NSNull null]) {
                sessionObj.subject = [sessionDict valueForKey:@"subject"];
            }
            
            if ([sessionDict valueForKey:@"description"] != (id)[NSNull null]) {
                sessionObj.additionalInfo = [sessionDict valueForKey:@"description"];
            }
            
            if ([sessionDict valueForKey:@"teacher_name"] != (id)[NSNull null]) {
                sessionObj.teacherName = [sessionDict valueForKey:@"teacher_name"];
            }
            
            if ([sessionDict valueForKey:@"weekday_id"] != (id)[NSNull null]) {
                sessionObj.weekDayID = [[sessionDict valueForKey:@"weekday_id"] integerValue];
            }
            
            if ([sessionDict valueForKey:@"weekday"] != (id)[NSNull null]) {
                sessionObj.weekDay = [sessionDict valueForKey:@"weekday"];
            }
            
            if ([sessionDict valueForKey:@"session"] != (id)[NSNull null]) {
                if ([sessionDict valueForKey:@"session_id"] != (id)[NSNull null]) {
                    sessionObj.sessionID = [NSString stringWithFormat:@"%@", [sessionDict valueForKey:@"session_id"]];
                }
                
                NSString *val = [sessionDict valueForKey:@"session"];
                
                NSArray *splitedArr = [val componentsSeparatedByString:@"@"];
                
                if ([splitedArr count] == 1) {
                    sessionObj.session = [splitedArr objectAtIndex:0];
                }
                
                if ([splitedArr count] == 2) {
                    sessionObj.duration = [splitedArr objectAtIndex:1];
                }
                
                if ([splitedArr count] == 3) {
                    if ([[splitedArr objectAtIndex:2] isEqualToString:@"1"]) {
                        sessionObj.sessionType = SessionType_Morning;
                        
                    } else if ([[splitedArr objectAtIndex:2] isEqualToString:@"2"]) {
                        sessionObj.sessionType = SessionType_Afternoon;
                        
                    } else if ([[splitedArr objectAtIndex:2] isEqualToString:@"3"]) {
                        sessionObj.sessionType = SessionType_Evening;
                    }
                }
                
                if ([splitedArr count] == 4) {
                    sessionObj.order = [[splitedArr objectAtIndex:3] integerValue];
                }
            }
            
            [sessionsArray addObject:sessionObj];
        }
    }
}

- (void)addAttendancesFromDictionaryArray:(NSArray *)attendances {
    if (attendances != (id)[NSNull null]) {
        
        for (NSDictionary *attendanceDict in attendances) {
            
            AttendanceObject *attendanceObj = [[AttendanceObject alloc] init];
            
            if ([attendanceDict valueForKey:@"student_id"] != (id)[NSNull null]) {
                attendanceObj.userID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"student_id"]];
            }
            
            if ([attendanceDict valueForKey:@"att_dt"] != (id)[NSNull null]) {
                attendanceObj.dateTime = [attendanceDict valueForKey:@"att_dt"];
            }
            
            if ([attendanceDict valueForKey:@"is_requested"] != (id)[NSNull null]) {
                attendanceObj.hasRequest = [[attendanceDict valueForKey:@"is_requested"] boolValue];
            }
            
            if ([attendanceDict valueForKey:@"notice"] != (id)[NSNull null]) {
                attendanceObj.reason = [attendanceDict valueForKey:@"notice"];
            }
            
            if ([attendanceDict valueForKey:@"session"] != (id)[NSNull null]) {
                attendanceObj.session = [attendanceDict valueForKey:@"session"];
            }
            
            if ([attendanceDict valueForKey:@"session_id"] != (id)[NSNull null]) {
                attendanceObj.sessionID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"session_id"]];
            }
            
            if ([attendanceDict valueForKey:@"subject"] != (id)[NSNull null]) {
                attendanceObj.subject = [attendanceDict valueForKey:@"subject"];
            }
            
            [rollupArray addObject:attendanceObj];
        }
    }
}

- (void)prepareDataForChecking {
    [checkAttendanceArray removeAllObjects];
    [searchResults removeAllObjects];
    
    NSInteger countOff = 0;
    
    if (currentSession) {
        for (UserObject *userObj in studentsArray) {
            CheckAttendanceObject *checkAtt = [[CheckAttendanceObject alloc] init];
            
            checkAtt.userObject = userObj;
            
            for (AttendanceObject *attObj in rollupArray) {

                if ([attObj.userID isEqualToString:userObj.userID]) {
                    //if session is # nil, have to check
                    if (attObj.session.length > 0) {
                        if ([currentSession.sessionID isEqualToString:attObj.sessionID]) {
                        
                            checkAtt.hasRequest = attObj.hasRequest;
                            checkAtt.state      = 1;
                            checkAtt.reason     = attObj.reason;
                            checkAtt.sessionID  = attObj.sessionID;
                            checkAtt.session    = attObj.session;
                            checkAtt.subject    = attObj.subject;
                            
                            checkAtt.checkedFlag = NO;
                            
                            countOff ++;
                        }
                    //if no session, it means fullday
                    } else {
                        checkAtt.hasRequest = attObj.hasRequest;
                        checkAtt.state      = 1;
                        checkAtt.reason     = attObj.reason;
                        checkAtt.sessionID  = attObj.sessionID;
                        checkAtt.session    = attObj.session;
                        checkAtt.subject    = attObj.subject;
                        
                        checkAtt.checkedFlag = NO;
                        
                        countOff ++;
                    }
                    
                    break;
                }
            }
            
            [checkAttendanceArray addObject:checkAtt];
        }
        
        [searchResults addObjectsFromArray:checkAttendanceArray];
        
        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;
        
        lbClass.text = [NSString stringWithFormat:@"%@ - Total: %lu | Off: %ld", classObj.className, (unsigned long)[checkAttendanceArray count], (long)countOff];
    }
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

@end
