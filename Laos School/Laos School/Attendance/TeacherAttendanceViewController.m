//
//  TeacherAttendanceViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherAttendanceViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "StudentsListTableViewCell.h"
#import "LevelPickerViewController.h"
#import "TimerViewController.h"
#import "ReasonViewController.h"
#import "CheckAttendanceObject.h"
#import "AppDelegate.h"

#import "DateTimeHelper.h"
#import "CommonDefine.h"
#import "UserObject.h"
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
    
    lbDate.text = [[DateTimeHelper sharedDateTimeHelper] dateStringFromDate:[NSDate date] withFormat:ATTENDANCE_DATE_FORMATE];
    
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
    
    UserObject *userObject = nil;

    userObject = [searchResults objectAtIndex:indexPath.row];
    
    cell.lbFullname.text = userObject.username;
    cell.lbAdditionalInfo.text = userObject.nickName;
    
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgAvatar];
    
    //load the image
    cell.imgAvatar.imageURL = [NSURL URLWithString:userObject.avatarPath];
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchText.length == 0) {
        self->searchResults = [studentsArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[cd] %@", searchText];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [studentsArray filteredArrayUsingPredicate:filterPredicate];
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

-(NSArray*) swipeTableCell:(StudentsListTableViewCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
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
            
            MGSwipeButton *btnOff = nil;
            
            btnOff = [MGSwipeButton buttonWithTitle:LocalizedString(@"Off") icon:[UIImage imageNamed:@"ic_off"] backgroundColor:OFF_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];
            
      /*      MGSwipeButton *btnLate = nil;
            
            btnLate = [MGSwipeButton buttonWithTitle:LocalizedString(@"Late") icon:[UIImage imageNamed:@"ic_late"] backgroundColor:LATE_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];*/
            
            return @[btnOff];
        }
    
    return nil;
}

-(BOOL) swipeTableCell:(StudentsListTableViewCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
{
    NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
    UserObject *userObj = [searchResults objectAtIndex:indexPath.row];

    if (direction == MGSwipeDirectionRightToLeft && index == 0) {
        NSLog(@"btnInform");
        
        
    } else if (direction == MGSwipeDirectionRightToLeft && index == 1) {
        NSLog(@"btnOff");

    } else if (direction == MGSwipeDirectionRightToLeft && index == 2) {
        NSLog(@"btnLate");

    }
    
    [self displayReasonView];

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
    [self showDataPicker:Picker_Section];
}


- (IBAction)btnShowListClick:(id)sender {
    isShowingViewInfo = NO;
    [self showHideInfoView:isShowingViewInfo];
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
        NSArray *students = [jsonObj objectForKey:@"students"];
        NSArray *timetables = [jsonObj objectForKey:@"timetables"];
        NSArray *attendances = [jsonObj objectForKey:@"attendances"];
        
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
