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
#import "AppDelegate.h"

#import "CommonDefine.h"
#import "UserObject.h"

#import "MGSwipeButton.h"

@interface TeacherAttendanceViewController ()
{
    BOOL isShowingViewInfo;
    NSMutableArray *studentsArray;
    NSMutableArray *searchResults;
    NSMutableArray *checkedArray;
    
    LevelPickerViewController *dataPicker;
    TimerViewController *dateTimePicker;
    ReasonViewController *reasonView;
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
    
    if (studentsArray == nil) {
        studentsArray = [[NSMutableArray alloc] init];
    }
    
    if (checkedArray == nil) {
        checkedArray = [[NSMutableArray alloc] init];
    }
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    //for test
#if 1
    UserObject *userObject = [[UserObject alloc] init];
    
    userObject.userID = @"1";
    userObject.username = @"Nguyen Tien Nam";
    userObject.displayName = @"Nguyen Nam";
    userObject.nickName = @"Yukan";
    userObject.avatarPath = @"";
    userObject.phoneNumber = @"0938912885";
    userObject.userRole = UserRole_Student;
    userObject.permission = Permission_Normal | Permission_SendMessage;
    
    userObject.shoolID = @"2";
    userObject.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject = [[ClassObject alloc] init];
    classObject.classID = @"1";
    classObject.className = @"Dien tu vien thong";
    classObject.pupilArray = nil;
    
    userObject.classObj = classObject;
    userObject.currentTerm = @"2015 - 2016 Hoc ky 1";
    userObject.classArray = nil;
    
    userObject.selected = NO;
    [studentsArray addObject:userObject];
    
    //student 2
    UserObject *userObject2 = [[UserObject alloc] init];
    
    userObject2.userID = @"2";
    userObject2.username = @"Nguyen Tien Nam";
    userObject2.displayName = @"Nguyen Nam";
    userObject2.nickName = @"Yukan";
    userObject2.avatarPath = @"";
    userObject2.phoneNumber = @"0938912885";
    userObject2.userRole = UserRole_Student;
    userObject2.permission = Permission_Normal | Permission_SendMessage;
    
    userObject2.shoolID = @"2";
    userObject2.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject2 = [[ClassObject alloc] init];
    classObject2.classID = @"1";
    classObject2.className = @"Dien tu vien thong";
    classObject2.pupilArray = nil;
    
    userObject2.classObj = classObject2;
    userObject2.currentTerm = @"2015 - 2016 Hoc ky 1";
    userObject2.classArray = nil;
    
    userObject2.selected = NO;
    [studentsArray addObject:userObject2];
    
    //student 3
    UserObject *userObject3 = [[UserObject alloc] init];
    
    userObject3.userID = @"3";
    userObject3.username = @"Nguyen Tien Nam";
    userObject3.displayName = @"Nguyen Nam";
    userObject3.nickName = @"Yukan";
    userObject3.avatarPath = @"";
    userObject3.phoneNumber = @"0938912885";
    userObject3.userRole = UserRole_Student;
    userObject3.permission = Permission_Normal | Permission_SendMessage;
    
    userObject3.shoolID = @"2";
    userObject3.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject3 = [[ClassObject alloc] init];
    classObject3.classID = @"1";
    classObject3.className = @"Dien tu vien thong";
    classObject3.pupilArray = nil;
    
    userObject3.classObj = classObject3;
    userObject3.currentTerm = @"2015 - 2016 Hoc ky 1";
    userObject3.classArray = nil;
    
    userObject3.selected = NO;
    [studentsArray addObject:userObject3];
    
    
    [checkedArray addObjectsFromArray:studentsArray];
    
    [searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchBar.text.length == 0) {
        self->searchResults = [studentsArray mutableCopy];
        
    }

#endif
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
    
    //find this user in selected array
    BOOL found = NO;
    
    for (UserObject *selectedUser in checkedArray) {
        if ([selectedUser.userID isEqualToString:userObject.userID]) {
            found = YES;
            break;
        }
    }
    
    if (found) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
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
            
            MGSwipeButton *btnInform = nil;
            
            btnInform = [MGSwipeButton buttonWithTitle:LocalizedString(@"Inform") icon:[UIImage imageNamed:@"ic_alert_white"] backgroundColor:ALERT_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];
            
            MGSwipeButton *btnOff = nil;
            
            btnOff = [MGSwipeButton buttonWithTitle:LocalizedString(@"Absent") icon:[UIImage imageNamed:@"ic_off"] backgroundColor:OFF_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];
            
            MGSwipeButton *btnLate = nil;
            
            btnLate = [MGSwipeButton buttonWithTitle:LocalizedString(@"Late") icon:[UIImage imageNamed:@"ic_late"] backgroundColor:LATE_COLOR padding:5 callback:^BOOL(MGSwipeTableCell *sender) {
                return NO;
            }];
            
            return @[btnLate, btnOff, btnInform];
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
- (IBAction)btnChooseClassClick:(id)sender {
    [self showDataPicker:Picker_Classes];
}

- (IBAction)btnChooseSubjectClick:(id)sender {
    [self showDataPicker:Picker_Subject];
}


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
    dateTimePicker.view.alpha = 0;
    
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
@end
