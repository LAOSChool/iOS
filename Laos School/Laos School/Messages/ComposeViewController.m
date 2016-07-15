//
//  ComposeViewController.m
//  Laos School
//
//  Created by HuKhong on 2/29/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ComposeViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "StudentsListViewController.h"

#import "ShareData.h"
#import "RequestToServer.h"
#import "LocalizeHelper.h"
#import "UserObject.h"
#import "CommonDefine.h"
#import "SVProgressHUD.h"
#import "CoreDataUtil.h"
#import "Common.h"
#import "CommonAlert.h"

#define PLACEHOLDER_SUBJECT @"Subject"
#define PLACEHOLDER_CONTENT @"Content"

@interface ComposeViewController ()
{
    RequestToServer *requestToServer;
    
    BOOL isSMSChecked;
    
    UIImage *imgCheck;
    UIImage *imgUncheck;
    
    NSMutableArray *reasonList;
}
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"New message")];
    
    [self.navigationController setNavigationColor];
    
    [lbTeacherReceiverList setTextColor:BLUE_COLOR];
    [txtContent setFont:[UIFont systemFontOfSize:15]];
    
    lbTo.text = LocalizedString(@"To:");
    lbSMS.text = LocalizedString(@"SMS:");

    if (_receiverArray == nil) {
        _receiverArray = [[NSMutableArray alloc] init];
    } else {
        [self selectReceiverCompletedHandle];
    }
    
    if (_content && _content.length > 0) {
        txtContent.text = _content;
    }
    
    if (_messageObject == nil) {
        _messageObject = [[MessageObject alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if ([[ShareData sharedShareData] userObj].userRole == UserRole_Student) {
        lbTeacherReceiverList.text = [[ShareData sharedShareData] userObj].classObj.teacherName;
    }
    
    if (_isTeacherForm) {
        if (_messageObject.importanceType == ImportanceHigh) {
            [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
            
        } else {
            [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
        }
        
        imgCheck = [UIImage imageNamed:@"ic_check_gray.png"];
        imgUncheck = [UIImage imageNamed:@"ic_uncheck_gray.png"];
        isSMSChecked = YES;
        [btnCheck setImage:imgCheck forState:UIControlStateNormal];
        
        //setting for sample message view
        if (_composeType == MessageCompose_Attendance ||
            _composeType == MessageCompose_Inform) {
            if (reasonList == nil) {
                reasonList = [[NSMutableArray alloc] init];
            }
            
            
            if (_composeType == MessageCompose_Attendance) {
                [reasonList addObject:LocalizedString(@"Sample 1")];
                [reasonList addObject:LocalizedString(@"Sample 2")];
                [reasonList addObject:LocalizedString(@"Sample 3")];
                [reasonList addObject:LocalizedString(@"Sample 4")];
                [reasonList addObject:LocalizedString(@"Sample 5")];
                [reasonList addObject:LocalizedString(@"Sample 6")];
                [reasonList addObject:LocalizedString(@"Sample 7")];
                [reasonList addObject:LocalizedString(@"Sample 8")];
                
                [self getAttendanceMessageContentSample];
                
            } else {
                [reasonList addObject:LocalizedString(@"Inform 1")];
                [reasonList addObject:LocalizedString(@"Inform 2")];
                [reasonList addObject:LocalizedString(@"Inform 3")];
                [reasonList addObject:LocalizedString(@"Inform 4")];
                [reasonList addObject:LocalizedString(@"Inform 5")];
                [reasonList addObject:LocalizedString(@"Inform 6")];
                [reasonList addObject:LocalizedString(@"Inform 7")];
                [reasonList addObject:LocalizedString(@"Inform 8")];
                [reasonList addObject:LocalizedString(@"Inform 9")];
                
                [self getInformMessageContentSample];
            }
            
            btnSampleMessage.hidden = NO;
            viewSampleMessage.layer.cornerRadius = 3;
            viewSampleMessage.clipsToBounds = YES;
            
            viewSampleMessage.layer.borderColor = BLUE_COLOR.CGColor;
            viewSampleMessage.layer.borderWidth = 3.0f;

            
        } else {
            btnSampleMessage.hidden = YES;
        }
        
        viewSampleMessage.hidden = YES;
        
    } else {
        btnSampleMessage.hidden = YES;
        viewSampleMessage.hidden = YES;
    }
    
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(btnSendClick)];
    
    self.navigationItem.rightBarButtonItems = @[btnSend];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
    
    [txtContent becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectReceiverCompletedHandle)
                                                 name:@"SelectReceiverCompleted"
                                               object:nil];
    
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

#pragma mark - keyboard movements
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = txtContent.frame;
        rect.size.height = self.view.frame.size.height - (rect.origin.y +                                                                                                                      keyboardSize.height);
        txtContent.frame = rect;
    }];
    
    //do not call btnSampleMessageClick
    [UIView animateWithDuration:0.3 animations:^(void) {
        viewSampleMessage.alpha = 0;
    } completion:^(BOOL finished) {
        viewSampleMessage.hidden = YES;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = txtContent.frame;
        rect.size.height = self.view.frame.size.height - rect.origin.y;
        txtContent.frame = rect;
    }];
}

- (void)getAttendanceMessageContentSample {
    [requestToServer getAttendanceMessageContentSample];
}

- (void)getInformMessageContentSample {
    [requestToServer getInformMessageContentSample];
}

- (IBAction)swipeGestureHandle:(id)sender {
    [txtContent resignFirstResponder];
    [txtSubject resignFirstResponder];
}

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnSendClick {
    if ([[Common sharedCommon]networkIsActive]) {
        if ([self validateInputs]) {
            [self sendNewMessage];
            
        } else {
            [self showAlertInvalidInputs];
        }
        
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
}

- (IBAction)btnCheckClick:(id)sender {
    if (_isTeacherForm) {
        isSMSChecked = !isSMSChecked;
        if (isSMSChecked) {
            [btnCheck setImage:imgCheck forState:UIControlStateNormal];
            
        } else {
            [btnCheck setImage:imgUncheck forState:UIControlStateNormal];
        }
    }
}

//return NO if not valid
- (BOOL)validateInputs {
    BOOL res = YES;
    
//    NSString *subject = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtSubject.text];
    NSString *content = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtContent.text];
    
    if (content.length == 0) {
        //show alert invalid
        res = NO;
    }
    
    if (_isTeacherForm) {
        if ([_receiverArray count] == 0) {
            res = NO;
        }
    }
    
    return res;
}

- (void)sendNewMessage {
    if (_isTeacherForm) {
        [self sendNewMessageByTeacher];
        
    } else {
        [self sendNewMessageByStudent];
    }
}

- (void)sendNewMessageByStudent {
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    //create message json
    /*
     {
     channel = 1;
     "class_id" = 1;
     content = "test message";
     "from_user_name" = NamNT1;
     "from_usr_id" = 1;
     id = 1;
     "imp_flg" = 1;
     "is_read" = 1;
     "is_sent" = 1;
     messageType = NX;
     "msg_type_id" = 1;
     other = "ko co gi quan trong";
     "read_dt" = "2016-03-24 00:00:00.0";
     schoolName = "Truong Tieu Hoc Thanh Xuan Trung";
     "school_id" = 1;
     "sent_dt" = "2016-03-24 00:00:00.0";
     title = title;
     "to_user_name" = Hue1;
     "to_usr_id" = "2,3,4,5,6";
     }
     
     },*/
    [messageDict setValue:[[ShareData sharedShareData] userObj].shoolID forKey:@"school_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].classObj.classID forKey:@"class_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].userID forKey:@"from_usr_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].classObj.teacherID forKey:@"to_usr_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    
    if (txtSubject.text && txtSubject.text.length > 0) {
        [messageDict setValue:txtSubject.text forKey:@"title"];
    } else {
        [messageDict setValue:LocalizedString(@"[No subject]") forKey:@"title"];
    }
    
    [messageDict setValue:txtContent.text forKey:@"content"];
    
    [messageDict setObject:[NSNumber numberWithInteger:0] forKey:@"imp_flg"];
    
    [requestToServer createMessageWithObject:messageDict];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendNewMessageByTeacher {
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    
    [messageDict setValue:[[ShareData sharedShareData] userObj].shoolID forKey:@"school_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].classObj.classID forKey:@"class_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].userID forKey:@"from_usr_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].classObj.teacherID forKey:@"to_usr_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    
    if (txtSubject.text && txtSubject.text.length > 0) {
        [messageDict setValue:txtSubject.text forKey:@"title"];
    } else {
        [messageDict setValue:@"[No subject]" forKey:@"title"];
    }
    
    [messageDict setValue:txtContent.text forKey:@"content"];
    
    if (_messageObject.importanceType == ImportanceHigh) {
        [messageDict setObject:[NSNumber numberWithInteger:1] forKey:@"imp_flg"];
        
    } else {
        [messageDict setObject:[NSNumber numberWithInteger:0] forKey:@"imp_flg"];
    }
    
    if (isSMSChecked) {
        [messageDict setObject:[NSNumber numberWithInteger:1] forKey:@"channel"];
    } else {
        [messageDict setObject:[NSNumber numberWithInteger:0] forKey:@"channel"];
    }
    
    NSString *ccList = @"";
    
    for (UserObject *recipient in _receiverArray) {
        ccList = [ccList stringByAppendingFormat:@"%@,", recipient.userID];
    }
    
    [messageDict setObject:ccList forKey:@"cc_list"];
    
    [requestToServer createMessageWithObject:messageDict];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark text view delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:txtSubject]) {
        [txtContent becomeFirstResponder];
        
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //set placeholder, because it's not support by default
//    if ([textView isEqual:txtContent]) {
//        if ([textView.text isEqualToString:PLACEHOLDER_CONTENT]) {
//            textView.text = @"";
//            textView.textColor = [UIColor blackColor]; //optional
//        }
//    }
//    
//    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    if ([textView isEqual:txtContent]) {
//        if ([textView.text isEqualToString:@""]) {
//            textView.text = PLACEHOLDER_CONTENT;
//            textView.textColor = [UIColor lightGrayColor]; //optional
//        }
//    }
//    
//    [textView resignFirstResponder];
    
    //need scroll to this textview -> do this if have time
}


#pragma mark teacher view
- (IBAction)btnAddClick:(id)sender {
    StudentsListViewController *studentsList = [[StudentsListViewController alloc] initWithNibName:@"StudentsListViewController" bundle:nil];
    studentsList.selectedArray = _receiverArray;
    studentsList.studentListType = StudentList_Message;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:studentsList];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnPriorityFlagClick:(id)sender {
    if (_messageObject.importanceType == ImportanceNormal) {
        _messageObject.importanceType = ImportanceHigh;
        
    } else {
        _messageObject.importanceType = ImportanceNormal;
    }
    
    if (_messageObject.importanceType == ImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
}


- (void)selectReceiverCompletedHandle {
    NSString *receiverString = @"";
    
    if ([_receiverArray count] > 0) {
        for (UserObject *userObj in _receiverArray) {
            receiverString = [receiverString stringByAppendingFormat:@"%@, ", userObj.nickName];
        }
        
        receiverString = [receiverString stringByAppendingString:@"\n"];
        receiverString = [receiverString stringByAppendingString:@"\n"];
    }
    
    lbTeacherReceiverList.text = receiverString;
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if (url != nil && [url rangeOfString:API_NAME_CREATEMESSAGE].location != NSNotFound) {
        
        [SVProgressHUD showSuccessWithStatus:@"Sent"];
        NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
        
        if (statusCode == HttpOK) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SentNewMessage" object:nil];

        } else {
            [self sendMessageFailed];       
            
        }
        
    } else if (url != nil && ([url rangeOfString:API_NAME_MESSAGE_CONTENT_SAMPLE].location != NSNotFound)) {
        [reasonList removeAllObjects];
        NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
        
        if (statusCode == HttpOK) {
            NSDictionary *returnedData = [jsonObj valueForKey:@"messageObject"];
            
            if (returnedData) {
                NSArray *reasonArr = [returnedData valueForKey:@"list"];
                
                if (reasonArr) {
                    NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
                    
                    for (NSDictionary *reason in reasonArr) {
                        if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
                            [reasonList addObject:[reason valueForKey:@"sval"]];
                            
                        } else if ([curLang isEqualToString:LANGUAGE_LAOS]) {
                            [reasonList addObject:[reason valueForKey:@"lval"]];
                        }
                    }
                    
                } else {
                    
                    [self hardCodeForAttendanceMessageSample];
                }
                
            } else {
                
                [self hardCodeForAttendanceMessageSample];
            }
            
        } else {
            [self hardCodeForAttendanceMessageSample];
            
        }
    } else if (url != nil && ([url rangeOfString:API_NAME_INFORM_CONTENT_SAMPLE].location != NSNotFound)) {
        [reasonList removeAllObjects];
        NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
        
        if (statusCode == HttpOK) {
            NSDictionary *returnedData = [jsonObj valueForKey:@"messageObject"];
            
            if (returnedData) {
                NSArray *reasonArr = [returnedData valueForKey:@"list"];
                
                if (reasonArr) {
                    NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
                    
                    for (NSDictionary *reason in reasonArr) {
                        if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
                            [reasonList addObject:[reason valueForKey:@"sval"]];
                            
                        } else if ([curLang isEqualToString:LANGUAGE_LAOS]) {
                            [reasonList addObject:[reason valueForKey:@"lval"]];
                        }
                    }
                    
                } else {
                    
                    [self hardCodeForInformMessageSample];
                }
                
            } else {
                
                [self hardCodeForInformMessageSample];
            }
            
        } else {
            [self hardCodeForInformMessageSample];
            
        }
    }
}

- (void)hardCodeForAttendanceMessageSample {
    if ([reasonList count] == 0) {
        [reasonList addObject:LocalizedString(@"Sample 1")];
        [reasonList addObject:LocalizedString(@"Sample 2")];
        [reasonList addObject:LocalizedString(@"Sample 3")];
        [reasonList addObject:LocalizedString(@"Sample 4")];
        [reasonList addObject:LocalizedString(@"Sample 5")];
        [reasonList addObject:LocalizedString(@"Sample 6")];
        [reasonList addObject:LocalizedString(@"Sample 7")];
        [reasonList addObject:LocalizedString(@"Sample 8")];
        
        [tableViewSampleMessage reloadData];
    }
}

- (void)hardCodeForInformMessageSample {
    if ([reasonList count] == 0) {
        [reasonList addObject:LocalizedString(@"Inform 1")];
        [reasonList addObject:LocalizedString(@"Inform 2")];
        [reasonList addObject:LocalizedString(@"Inform 3")];
        [reasonList addObject:LocalizedString(@"Inform 4")];
        [reasonList addObject:LocalizedString(@"Inform 5")];
        [reasonList addObject:LocalizedString(@"Inform 6")];
        [reasonList addObject:LocalizedString(@"Inform 7")];
        [reasonList addObject:LocalizedString(@"Inform 8")];
        [reasonList addObject:LocalizedString(@"Inform 9")];
        
        [tableViewSampleMessage reloadData];
    }
}

- (void)failToConnectToServer {
    [self showAlertFailedToConnectToServer];
}

- (void)sendPostRequestFailedWithUnknownError {
    
}

- (void)accountLoginByOtherDevice {
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)sendMessageFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while sending message. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
}

- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)showAlertInvalidInputs {
    NSString *content = @"";
    
    if (_isTeacherForm) {
        content = LocalizedString(@"Please enter recipient and content!");
        
    } else {
        content = LocalizedString(@"Please enter content!");
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}


#pragma mark sample reason view
- (IBAction)btnShowSampleClick:(id)sender {
    [txtContent resignFirstResponder];
    
    if (viewSampleMessage.hidden == YES) {
        viewSampleMessage.alpha = 0;
        viewSampleMessage.hidden = NO;
        
        [UIView animateWithDuration:0.3 animations:^(void) {
            viewSampleMessage.alpha = 1;
        }];
        
    } else {
        viewSampleMessage.alpha = 1;
        
        [UIView animateWithDuration:0.3 animations:^(void) {
            viewSampleMessage.alpha = 0;
        } completion:^(BOOL finished) {
            viewSampleMessage.hidden = YES;
        }];
    }
    
    [self hardCodeForAttendanceMessageSample];
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [reasonList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *reasonSampleCellId = @"reasonSampleCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reasonSampleCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reasonSampleCellId];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    cell.textLabel.textColor = [UIColor darkGrayColor];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    [cell.textLabel setNumberOfLines:2];
    cell.textLabel.text = [reasonList objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *sample = [reasonList objectAtIndex:indexPath.row];
    
    txtContent.text = [txtContent.text stringByAppendingFormat:@"\n%@", sample];
    
    [self btnShowSampleClick:nil];
}
@end
