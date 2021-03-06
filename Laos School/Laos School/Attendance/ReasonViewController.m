//
//  ReasonViewController.m
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "ReasonViewController.h"
#import "OtherReasonTableViewCell.h"
#import "Common.h"
#import "CommonDefine.h"
#import "CommonAlert.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "SVProgressHUD.h"

@import FirebaseAnalytics;

@interface ReasonViewController ()
{    
    NSIndexPath *selectedIndex;
    
    RequestToServer *requestToServer;
    
    BOOL isFulldayChecked;
    UIImage *imgCheck;
    UIImage *imgUncheck;
}
@end

@implementation ReasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [navigationView setBackgroundColor:COMMON_COLOR];
    
    lbTitle.text = LocalizedString(@"Reason");
    lbFullday.text = LocalizedString(@"Full day");
    [btnSend setTitle:LocalizedString(@"Send") forState:UIControlStateNormal];
    
    [lbFullday setTextColor:BLUE_COLOR];
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (_reasonList == nil) {
        _reasonList = [[NSMutableArray alloc] init];
        
        [_reasonList addObject:LocalizedString(@"No reason")];
        [_reasonList addObject:LocalizedString(@"Reason 1")];
        [_reasonList addObject:LocalizedString(@"Reason 2")];
        [_reasonList addObject:LocalizedString(@"Reason 3")];
        [_reasonList addObject:LocalizedString(@"Reason 4")];
        [_reasonList addObject:LocalizedString(@"Reason 5")];
        [_reasonList addObject:LocalizedString(@"Reason 6")];
        [_reasonList addObject:LocalizedString(@"Reason 7")];
        [_reasonList addObject:LocalizedString(@"Reason 8")];
        [_reasonList addObject:LocalizedString(@"Other")];
        
    }
    
    selectedIndex = nil;
    
    imgCheck = [UIImage imageNamed:@"ic_check_gray.png"];
    imgUncheck = [UIImage imageNamed:@"ic_uncheck_gray.png"];
    isFulldayChecked = NO;
    [btnFullday setImage:imgUncheck forState:UIControlStateNormal];
    
    [self getAbsenceReasonSample];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

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

- (void)getAbsenceReasonSample {
    [requestToServer getAbsenceReasonSample];
}

- (void)setCheckAttendanceObj:(CheckAttendanceObject *)checkAttendanceObj {
    _checkAttendanceObj = checkAttendanceObj;
    isFulldayChecked = NO;
    [btnFullday setImage:imgUncheck forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    selectedIndex = nil;
    [reasonTableView reloadData];
    
    CGRect rect = containerView.frame;
    rect.origin.y = (self.view.frame.size.height - rect.size.height)/2;
    containerView.frame = rect;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //remove old checkmark
    OtherReasonTableViewCell *cell = [reasonTableView cellForRowAtIndexPath:selectedIndex];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[_reasonList count] - 1 inSection:0];
    selectedIndex = indexPath;
    cell = [reasonTableView cellForRowAtIndexPath:selectedIndex];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = containerView.frame;
        rect.origin.y = (self.view.frame.size.height - rect.size.height)/2 - 80;
        containerView.frame = rect;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = containerView.frame;
        rect.origin.y = (self.view.frame.size.height - rect.size.height)/2;
        containerView.frame = rect;
    }];
}

- (IBAction)tapGestureHandle:(id)sender {
    [self dismissReasonView];
}

- (IBAction)cancelBtnClick:(id)sender {
    [self dismissReasonView];
    
}

- (void)dismissReasonView {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)loadInformation {

}


- (IBAction)checkFulldayClick:(id)sender {
    isFulldayChecked = !isFulldayChecked;
    if (isFulldayChecked) {
        [btnFullday setImage:imgCheck forState:UIControlStateNormal];
        
    } else {
        [btnFullday setImage:imgUncheck forState:UIControlStateNormal];
    }
}

- (IBAction)btnSendClick:(id)sender {
    
    if (selectedIndex) {
        if ([[Common sharedCommon]networkIsActive]) {
            [self createAttendanceDict];
            
        } else {
            [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
        }
        
        
    } else {
        [self showAlertInvalidInputs];
    }
}

- (void)createAttendanceDict {
    /*
     {"school_id":1,"class_id":1,"att_dt":"2016-05-16 00:00:00.0","user_id":14,"absent":1,"notice":"Test vang mat from request"}
     */
    NSString *reason = @"";
    NSInteger hasRequesed = 1;
    if (selectedIndex.row == [_reasonList count] - 1) {  //other
        OtherReasonTableViewCell *cell = [reasonTableView cellForRowAtIndexPath:selectedIndex];
        
        reason = cell.txtOther.text;
        
    } else if (selectedIndex.row == 0) {    //no reason
        reason = LocalizedString(@"[No reason]");
        hasRequesed = 0;
    } else {
        reason = [_reasonList objectAtIndex:selectedIndex.row];
    }
    
    reason = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:reason];
    
    if (reason.length == 0) {
        [self showAlertInvalidInputs];
        
    } else {
        NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];
        
        UserObject *userObj = _checkAttendanceObj.userObject;
        ClassObject *classObj = userObj.classObj;

        [requestDict setValue:userObj.shoolID forKey:@"school_id"];
        [requestDict setValue:classObj.classID forKey:@"class_id"];
        [requestDict setValue:userObj.userID forKey:@"student_id"];
        [requestDict setValue:[[DateTimeHelper sharedDateTimeHelper] dateStringFromString:_dateTime withFormat:@"dd-MM-yyyy"] forKey:@"att_dt"];
        
        if (isFulldayChecked == NO) {
            [requestDict setValue:_currentSession.subjectID forKey:@"subject_id"];
            [requestDict setValue:_currentSession.subject forKey:@"subject"];
            [requestDict setValue:_currentSession.sessionID forKey:@"session_id"];
            [requestDict setValue:_currentSession.session forKey:@"session"];
        }
        
        [requestDict setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
        [requestDict setValue:[NSNumber numberWithInteger:hasRequesed] forKey:@"excused"];
        [requestDict setValue:reason forKey:@"notice"];
        
        [requestToServer createAttendanceChecking:requestDict];
        
        [self dismissReasonView];
        
        [FIRAnalytics logEventWithName:@"submit_attendance_checking" parameters:@{
                                                                           kFIRParameterValue:@(1)
                                                                           }];
        
        [FIRAnalytics logEventWithName:[NSString stringWithFormat:@"off_reason_%ld", (long)selectedIndex.row] parameters:@{
                                                                                  kFIRParameterValue:@(1)
                                                                                  }];
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
    return [_reasonList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    if (indexPath.row == [_reasonList count] - 1) {
        static NSString *otherReasonCellIdentifier = @"OtherReasonTableViewCell";
        
        OtherReasonTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:otherReasonCellIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"OtherReasonTableViewCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.txtOther.placeholder = LocalizedString(@"Other");
        
        if (selectedIndex && [indexPath isEqual:selectedIndex]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
        
    } else {
        
        static NSString *reasonCellId = @"reasonCellId";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reasonCellId];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reasonCellId];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        if (indexPath.row == 0) {
            cell.textLabel.textColor = [UIColor redColor];
        } else {
            cell.textLabel.textColor = [UIColor darkGrayColor];
        }
        
        [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
        cell.textLabel.text = [_reasonList objectAtIndex:indexPath.row];
        [cell.textLabel setNumberOfLines:2];
        
        if (selectedIndex && [indexPath isEqual:selectedIndex]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    
    return nil;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //remove old checkmark
    OtherReasonTableViewCell *cell = [reasonTableView cellForRowAtIndexPath:selectedIndex];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectedIndex = indexPath;
    
    //checkmark new
    cell = [reasonTableView cellForRowAtIndexPath:selectedIndex];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    //dismiss other reason
    if (indexPath.row != [_reasonList count] - 1) {
        NSIndexPath *indexPathOther = [NSIndexPath indexPathForItem:[_reasonList count] - 1 inSection:0];
        OtherReasonTableViewCell *cellOther = [reasonTableView cellForRowAtIndexPath:indexPathOther];
        [cellOther.txtOther resignFirstResponder];
    }
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if (url != nil && [url rangeOfString:API_NAME_TEACHER_CREATE_ATTENDANCE].location != NSNotFound) {
        NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
        
        if (statusCode == HttpOK) {
            NSDictionary *attendanceDict = [jsonObj objectForKey:@"messageObject"];
            
            if ([attendanceDict valueForKey:@"id"] != (id)[NSNull null]) {
                _checkAttendanceObj.attendanceID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"id"]];
            }
            
            if ([attendanceDict valueForKey:@"att_dt"] != (id)[NSNull null]) {
                _checkAttendanceObj.dateTime = [attendanceDict valueForKey:@"att_dt"];
            }
            
            if ([attendanceDict valueForKey:@"excused"] != (id)[NSNull null]) {
                _checkAttendanceObj.hasRequest = [[attendanceDict valueForKey:@"excused"] boolValue];
            }
            
            if ([attendanceDict valueForKey:@"notice"] != (id)[NSNull null]) {
                _checkAttendanceObj.reason = [attendanceDict valueForKey:@"notice"];
            }
            
            if ([attendanceDict valueForKey:@"session"] != (id)[NSNull null]) {
                _checkAttendanceObj.session = [attendanceDict valueForKey:@"session"];
            }
            
            if ([attendanceDict valueForKey:@"session_id"] != (id)[NSNull null]) {
                _checkAttendanceObj.sessionID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"session_id"]];
            }
            
            if ([attendanceDict valueForKey:@"subject"] != (id)[NSNull null]) {
                _checkAttendanceObj.subject = [attendanceDict valueForKey:@"subject"];
            }
            
            if ([attendanceDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                _checkAttendanceObj.subjectID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"subject_id"]];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"CheckAttendanceSuccessful" object:_checkAttendanceObj];
            
        } else {
            [self sendRequestFailed];
     
        }
        
    }
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
    [self showAlertFailedToConnectToServer];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertInvalidInputs {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"Please enter a reason!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)sendRequestFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}

- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}
@end
