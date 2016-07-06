//
//  TeacherAttendanceViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherAttendanceViewController.h"
#import "StdTimeTableDayViewController.h"
#import "ComposeViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "InformationViewController.h"
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
#import "Common.h"
#import "CommonAlert.h"

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
    
    NSIndexPath *willDeleteIndexPath;
    
    InformationViewController *infoView;
}
@end

@implementation TeacherAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Attendance")];
    
    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(actionButtonClick:)];
    
    self.navigationItem.rightBarButtonItems = @[btnAction];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    isShowingViewInfo = YES;
    currentSession = nil;
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    if (userObj.userRole == UserRole_Student) {
        UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
        
        self.navigationItem.leftBarButtonItems = @[btnCancel];
    }
    
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
    
    lbSession.text = LocalizedString(@"Select a period");
    [lbSession setTextColor:[UIColor lightGrayColor]];
    
    [self loadData];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkAttendanceSuccessful:)
                                                 name:@"CheckAttendanceSuccessful"
                                               object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (dataPicker != nil) {
        [dataPicker.view removeFromSuperview];;
    }
}

- (void)reloadStudentsData {
    [self loadData];
}

- (void)loadData {
    if ([[Common sharedCommon]networkIsActive]) {
        [SVProgressHUD show];
        
        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;
        
        NSString *dateStr = [[DateTimeHelper sharedDateTimeHelper] dateStringFromString:lbDate.text withFormat:API_ATTENDANCE_DATE_FORMATE];
        
        [requestToServer getStudentListWithAndAttendanceInfo:classObj.classID inDate:dateStr];
        
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
}

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionButtonClick:(id)sender {
    [searchBar resignFirstResponder];
    [self dismissPicker];
    /*
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"xxx"), LocalizedString(@"yyy"), nil];
    
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if (IS_IPAD) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
     */
    //set recipient
    NSMutableArray *recipents = [[NSMutableArray alloc] init];
    for (CheckAttendanceObject *student in checkAttendanceArray) {
        if (student.state == 0) {
            [recipents addObject:student.userObject];
        }
    }

    [self showMessageFormToRecipents:recipents withSampleFlag:YES];
}

- (void)showMessageFormToRecipents:(NSArray *)recipents withSampleFlag:(BOOL)showFlag {
    ComposeViewController *composeViewController = nil;
    
    composeViewController = [[ComposeViewController alloc] initWithNibName:@"TeacherComposeViewController" bundle:nil];
    composeViewController.isTeacherForm = YES;
    composeViewController.isShowBtnSampleMessage = showFlag;
    
    //set recipient
    composeViewController.receiverArray = [recipents mutableCopy];
    
    //set content
    NSString *content = @"";
    content = [NSString stringWithFormat:@"%@\n%@\n", lbDate.text, lbSession.text];
    composeViewController.content = content;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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
    return 44.0;
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
    
    if (userObject.avatarPath && userObject.avatarPath.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgAvatar];
        
        //load the image
        cell.imgAvatar.imageURL = [NSURL URLWithString:userObject.avatarPath];
        
    } else {
        if ([userObject.gender isEqualToString:@"male"]) {
            cell.imgAvatar.image = [UIImage imageNamed:@"ic_male.png"];
            
        } else if ([userObject.gender isEqualToString:@"female"]) {
            cell.imgAvatar.image = [UIImage imageNamed:@"ic_female.png"];
        }
    }
    
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
            cell.lbNoreason.text = LocalizedString(@"[No reason]");
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
    
    checkAttObj.checkedFlag = !checkAttObj.checkedFlag;
    
    StudentsListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (checkAttObj.checkedFlag) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)longpressGestureHandle:(id)sender {
    StudentsListTableViewCell *cell = (StudentsListTableViewCell *)sender;
    
    NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
    CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];
    
    if (checkAttObj.state == 1) {
        AttendanceObject *attendanceObj = [[AttendanceObject alloc] init];
        
        attendanceObj.userID     = checkAttObj.userObject.userID;
        attendanceObj.attendanceID = checkAttObj.attendanceID;
        attendanceObj.hasRequest = checkAttObj.hasRequest;
        attendanceObj.reason     = checkAttObj.reason;
        attendanceObj.sessionID  = checkAttObj.sessionID;
        attendanceObj.session    = checkAttObj.session;
        attendanceObj.subject    = checkAttObj.subject;
        attendanceObj.dateTime   = checkAttObj.dateTime;
        
        if (infoView == nil) {
            infoView = [[InformationViewController alloc] initWithNibName:@"InformationViewController" bundle:nil];
        }
        
        infoView.attObj = attendanceObj;
        infoView.view.alpha = 0;
        
        if (attendanceObj.sessionID.length > 0) {
            infoView.isDetail = YES;
        } else {
            infoView.isDetail = NO;
        }
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        CGRect rect = appDelegate.window.frame;
        [infoView.view setFrame:rect];
        
        [appDelegate.window addSubview:infoView.view];
        
        [UIView animateWithDuration:0.3 animations:^(void) {
            infoView.view.alpha = 1;
        }];
        
        [infoView loadInformation];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self showHideHeaderView:NO];
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
        [searchBar resignFirstResponder];

        swipeSettings.transition = MGSwipeTransitionStatic;
        
        if (direction == MGSwipeDirectionRightToLeft) {
            expansionSettings.fillOnTrigger = NO;
            expansionSettings.threshold = 1.1;
            
            NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
            CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];
            
            if (checkAttObj.state == 1) {
                MGSwipeButton *btnCancel = nil;
                
                btnCancel = [MGSwipeButton buttonWithTitle:LocalizedString(@"Cancel") icon:[UIImage imageNamed:@"ic_cancel_white.png"] backgroundColor:ALERT_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                    return NO;
                }];
                
                return @[btnCancel];
                
            } else {
                MGSwipeButton *btnInform = nil;
                
                btnInform = [MGSwipeButton buttonWithTitle:LocalizedString(@"Inform") icon:[UIImage imageNamed:@"ic_alert_white"] backgroundColor:ALERT_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                    return NO;
                }];
                
                MGSwipeButton *btnOff = nil;
                
                btnOff = [MGSwipeButton buttonWithTitle:LocalizedString(@"Absent") icon:[UIImage imageNamed:@"ic_off"] backgroundColor:OFF_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                    return NO;
                }];
                
                return @[btnOff, btnInform];
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
    [searchBar resignFirstResponder];
    
    NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
    CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:indexPath.row];

    if (direction == MGSwipeDirectionRightToLeft) {
        if (checkAttObj.state == 1) {   //cancel
            if (direction == MGSwipeDirectionRightToLeft && index == 0) {
                willDeleteIndexPath = indexPath;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Confirmation") message:LocalizedString(@"Cancel this attendance checking result. Are you sure?") delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
                alert.tag = 2;
                
                [alert show];
            }
            
        } else {
            if (index == 0) {   //absent
                [self displayReasonView:checkAttObj];
                
            } else {    //send message
                NSMutableArray *recipents = [[NSMutableArray alloc] init];
                [recipents addObject:checkAttObj.userObject];
                [self showMessageFormToRecipents:recipents withSampleFlag:NO];
            }
        }
    }

    return YES;  //autohide
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
    [searchBar resignFirstResponder];
    [self showDateTimePicker];
}


- (IBAction)btnChooseSectionClick:(id)sender {
    [searchBar resignFirstResponder];
    
    StdTimeTableDayViewController *timeDayViewController = [[StdTimeTableDayViewController alloc] initWithNibName:@"StdTimeTableDayViewController" bundle:nil];
    timeDayViewController.title = LocalizedString(@"Select a period");
    timeDayViewController.sessionsArray = sessionsArray;
    timeDayViewController.timeTableType = TimeTableOneDay;
    timeDayViewController.selectedSession = currentSession;
    
    timeDayViewController.delegate = (id)self;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:timeDayViewController];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}


- (void)btnDoneClick:(id)sender withObjectReturned:(TTSessionObject *)returnedObj {
    currentSession = returnedObj;
    
    if (currentSession) {
        [lbSession setTextColor:[UIColor whiteColor]];
        
        NSString *session = @"";
        NSString *subject  = @"";
        
        if (currentSession.session != (id)[NSNull null]) {
            session = currentSession.session;
        }
        
        if (currentSession.subject != (id)[NSNull null]) {
            subject = currentSession.subject;
        }
        
        lbSession.text = [NSString stringWithFormat:@"%@ - %@", session, subject];
        
        [self prepareDataForChecking];
        [studentTableView reloadData];
    }
}

#pragma mark data picker
- (void)showDataPicker:(PICKER_TYPE)pickerType {
//    if (dataPicker == nil) {
        dataPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
//    }
    
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
    
    if (dateTimePicker == nil) {
        dateTimePicker = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
    }
    
    if (lbDate.text.length > 0) {
        dateTimePicker.date = [[DateTimeHelper sharedDateTimeHelper] dateFromString:lbDate.text];
        
    } else {
        dateTimePicker.date = [[DateTimeHelper sharedDateTimeHelper] currentDateWithFormat:ATTENDANCE_DATE_FORMATE];
    }
    
//    dateTimePicker.minimumDate = [[DateTimeHelper sharedDateTimeHelper] previousWeekWithFormat:ATTENDANCE_DATE_FORMATE];
    dateTimePicker.minimumDate = [[DateTimeHelper sharedDateTimeHelper] currentDateWithFormat:ATTENDANCE_DATE_FORMATE];
    dateTimePicker.maximumDate = [[DateTimeHelper sharedDateTimeHelper] nextWeekWithFormat:ATTENDANCE_DATE_FORMATE];
    
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
    lbDate.text = value;
    
    [self loadData];
}

- (void)displayReasonView:(CheckAttendanceObject *)checkAttObj {
    if (reasonView == nil) {
        reasonView = [[ReasonViewController alloc] initWithNibName:@"ReasonViewController" bundle:nil];
    }
    
    reasonView.view.alpha = 0;
    reasonView.checkAttendanceObj = checkAttObj;
    reasonView.dateTime = lbDate.text;
    reasonView.currentSession = currentSession;
    
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
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if ([url rangeOfString:API_NAME_TEACHER_CHECK_ATTENDANCE_LIST].location != NSNotFound) {
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
        
    } else if ([url rangeOfString:API_NAME_TEACHER_CANCEL_ATTENDANCE].location != NSNotFound) {
        
    }
    
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
            
            if ([studentDict valueForKey:@"gender"] != (id)[NSNull null]) {
                userObject.gender = [studentDict valueForKey:@"gender"];
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
            
            ClassObject *classObject = [[ClassObject alloc] init];
            NSArray *classesArr = [studentDict objectForKey:@"classes"];
            if ([classesArr count] > 0) {
                NSDictionary *classDictionary = [classesArr objectAtIndex:0];
                if (classDictionary) {
                    classObject.classID = [NSString stringWithFormat:@"%@", [classDictionary valueForKey:@"id"]];
                    classObject.className = [classDictionary valueForKey:@"title"];
                    classObject.teacherID = [NSString stringWithFormat:@"%@", [classDictionary valueForKey:@"head_teacher_id"]];
                    classObject.teacherName = [classDictionary valueForKey:@"headTeacherName"];
                    classObject.classLocation = [classDictionary valueForKey:@"location"];
                    classObject.currentTerm = [NSString stringWithFormat:@"%@", [classDictionary valueForKey:@"term"]];
                    classObject.currentYear = [classDictionary valueForKey:@"years"];
                    classObject.pupilArray = nil;
                }
            }
            
            userObject.classObj = classObject;
            
            [studentsArray addObject:userObject];
        }
    }
}

- (void)addTimeTableFromDictionaryArray:(NSArray *)timetables {
    if (timetables != (id)[NSNull null]) {
        
        for (NSDictionary *sessionDict in timetables) {

            TTSessionObject *sessionObj = [[TTSessionObject alloc] init];
            
            if ([sessionDict valueForKey:@"subject"] != (id)[NSNull null]) {
                sessionObj.subject = [sessionDict valueForKey:@"subject"];
            }
            
            if ([sessionDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                sessionObj.subjectID = [NSString stringWithFormat:@"%@", [sessionDict valueForKey:@"subject_id"]];
            }
            
            if ([sessionDict valueForKey:@"description"] != (id)[NSNull null]) {
                sessionObj.additionalInfo = [sessionDict valueForKey:@"description"];
            }
            
            if ([sessionDict valueForKey:@"teacher_name"] != (id)[NSNull null]) {
                sessionObj.teacherName = [sessionDict valueForKey:@"teacher_name"];
            }
            
            if ([sessionDict valueForKey:@"weekday_id"] != (id)[NSNull null]) {
                sessionObj.weekDayID = [NSString stringWithFormat:@"%@", [sessionDict valueForKey:@"weekday_id"]];
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
                
                if ([splitedArr count] > 0) {
                    sessionObj.session = [splitedArr objectAtIndex:0];
                }
                
                if ([splitedArr count] > 1) {
                    sessionObj.duration = [splitedArr objectAtIndex:1];
                }
                
                if ([splitedArr count] > 2) {
                    if ([[splitedArr objectAtIndex:2] isEqualToString:@"1"]) {
                        sessionObj.sessionType = SessionType_Morning;
                        
                    } else if ([[splitedArr objectAtIndex:2] isEqualToString:@"2"]) {
                        sessionObj.sessionType = SessionType_Afternoon;
                        
                    } else if ([[splitedArr objectAtIndex:2] isEqualToString:@"3"]) {
                        sessionObj.sessionType = SessionType_Evening;
                    }
                }
                
                if ([splitedArr count] > 3) {
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
            
            if ([attendanceDict valueForKey:@"id"] != (id)[NSNull null]) {
                attendanceObj.attendanceID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"id"]];
            }
            
            if ([attendanceDict valueForKey:@"student_id"] != (id)[NSNull null]) {
                attendanceObj.userID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"student_id"]];
            }
            
            if ([attendanceDict valueForKey:@"att_dt"] != (id)[NSNull null]) {
                attendanceObj.dateTime = [attendanceDict valueForKey:@"att_dt"];
            }
            
            if ([attendanceDict valueForKey:@"excused"] != (id)[NSNull null]) {
                attendanceObj.hasRequest = [[attendanceDict valueForKey:@"excused"] boolValue];
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
            
            if ([attendanceDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                attendanceObj.subjectID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"subject_id"]];
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
                    if (attObj.sessionID.length > 0) {
                        if ([currentSession.sessionID isEqualToString:attObj.sessionID]) {
                            
                            checkAtt.attendanceID = attObj.attendanceID;
                            checkAtt.hasRequest = attObj.hasRequest;
                            checkAtt.state      = 1;
                            checkAtt.reason     = attObj.reason;
                            checkAtt.sessionID  = attObj.sessionID;
                            checkAtt.session    = attObj.session;
                            checkAtt.subject    = attObj.subject;
                            checkAtt.dateTime   = attObj.dateTime;
                            
                            checkAtt.checkedFlag = NO;
                            
                            countOff ++;
                            
                            break;
                        }
                    //if no session, it means fullday
                    } else {
                        checkAtt.attendanceID = attObj.attendanceID;
                        checkAtt.hasRequest = attObj.hasRequest;
                        checkAtt.state      = 1;
                        checkAtt.reason     = attObj.reason;
                        checkAtt.sessionID  = attObj.sessionID;
                        checkAtt.session    = attObj.session;
                        checkAtt.subject    = attObj.subject;
                        checkAtt.dateTime   = attObj.dateTime;
                        
                        checkAtt.checkedFlag = NO;
                        
                        countOff ++;
                        
                        break;
                    }
                }
            }
            
            [checkAttendanceArray addObject:checkAtt];
        }
        
        [searchResults addObjectsFromArray:checkAttendanceArray];
        
        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;
        
        lbClass.text = [NSString stringWithFormat:@"%@ - Total: %lu | Off: %ld", classObj.className, (unsigned long)[checkAttendanceArray count], (long)countOff];
        
        if ([checkAttendanceArray count] > 0) {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        } else {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
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

- (void)checkAttendanceSuccessful:(NSNotification *)notification {
    CheckAttendanceObject *updatedObj = (CheckAttendanceObject *)notification.object;
/*
    //update checkAttendance block
    for (int i = 0; i < [checkAttendanceArray count]; i++) {
        CheckAttendanceObject *checkAttObj = [checkAttendanceArray objectAtIndex:i];
        if ([checkAttObj.attendanceID isEqualToString:updatedObj.attendanceID]) {
            
            checkAttObj.attendanceID = updatedObj.attendanceID;
            checkAttObj.hasRequest = updatedObj.hasRequest;
            checkAttObj.state      = 1;
            checkAttObj.reason     = updatedObj.reason;
            checkAttObj.sessionID  = updatedObj.sessionID;
            checkAttObj.session    = updatedObj.session;
            checkAttObj.subject    = updatedObj.subject;
            checkAttObj.dateTime   = updatedObj.dateTime;
            
            NSIndexPath *ind = [NSIndexPath indexPathForItem:i inSection:0];
            
            [studentTableView beginUpdates];
            [studentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ind] withRowAnimation:UITableViewRowAnimationNone];
            [studentTableView endUpdates];
            
            break;
        }
    }
*/
    //add to attendance block
    //in case, only switch session without reload data
    AttendanceObject *attendanceObj = [[AttendanceObject alloc] init];

    attendanceObj.userID     = updatedObj.userObject.userID;
    attendanceObj.attendanceID = updatedObj.attendanceID;
    attendanceObj.hasRequest = updatedObj.hasRequest;
    attendanceObj.reason     = updatedObj.reason;
    attendanceObj.sessionID  = updatedObj.sessionID;
    attendanceObj.session    = updatedObj.session;
    attendanceObj.subject    = updatedObj.subject;
    attendanceObj.dateTime   = updatedObj.dateTime;
    
    [rollupArray addObject:attendanceObj];
    
    [self prepareDataForChecking];
    
    for (int i = 0; i < [checkAttendanceArray count]; i++) {
        CheckAttendanceObject *checkAttObj = [checkAttendanceArray objectAtIndex:i];
        if ([checkAttObj.attendanceID isEqualToString:updatedObj.attendanceID]) {           
            NSIndexPath *ind = [NSIndexPath indexPathForItem:i inSection:0];
            
            [studentTableView beginUpdates];
            [studentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ind] withRowAnimation:UITableViewRowAnimationNone];
            [studentTableView endUpdates];
            
            break;
        }
    }
    
}

#pragma mark alert delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2) {    //cancel checking result
        if (buttonIndex != 0) {
            if ([[Common sharedCommon]networkIsActive]) {
                CheckAttendanceObject *checkAttObj = [searchResults objectAtIndex:willDeleteIndexPath.row];
                
                [requestToServer deleteAttendanceItem:checkAttObj.attendanceID];
                
                //update attendance block
                for (int i = 0; i < [rollupArray count]; i++) {
                    AttendanceObject *attendanceObj = [rollupArray objectAtIndex:i];
                    
                    if ([attendanceObj.attendanceID isEqualToString:checkAttObj.attendanceID]) {
                        
                        [rollupArray removeObject:attendanceObj];
                        
                        break;
                    }
                }
                
                [self prepareDataForChecking];
                
                [studentTableView beginUpdates];
                [studentTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:willDeleteIndexPath] withRowAnimation:UITableViewRowAnimationNone];
                [studentTableView endUpdates];
                
            } else {
                [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
            }
        }
    }
}

#pragma mark show hide header
- (void)showHideHeaderView:(BOOL)flag {
    if (flag == YES) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            CGRect headerRect = viewHeader.frame;
            CGRect tableRect = viewTableView.frame;
            
            headerRect.origin.y = 0;
            [viewHeader setFrame:headerRect];
            
            tableRect.origin.y = headerRect.size.height;
            tableRect.size.height = self.view.frame.size.height - headerRect.size.height;
            [viewTableView setFrame:tableRect];
            
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^(void) {
            CGRect headerRect = viewHeader.frame;
            CGRect tableRect = viewTableView.frame;
            
            headerRect.origin.y = 0 - headerRect.size.height;
            [viewHeader setFrame:headerRect];
            
            tableRect.origin.y = 0;
            tableRect.size.height = self.view.frame.size.height;
            [viewTableView setFrame:tableRect];
            
        }];
    }
}

- (IBAction)panGestureHandle:(id)sender {
    if (dataPicker.view.alpha == 0) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        if (velocity.y > VERLOCITY) {
            [self showHideHeaderView:YES];
        } else if (velocity.y < - VERLOCITY) {
            [self showHideHeaderView:NO];
        }
    }
}
@end
