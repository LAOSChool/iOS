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
}
@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"New Message")];
    
    [self.navigationController setNavigationColor];
    
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
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = txtContent.frame;
        rect.size.height = self.view.frame.size.height - rect.origin.y;
        txtContent.frame = rect;
    }];
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
    
    NSString *subject = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtSubject.text];
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
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:studentsList];
    
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
    [SVProgressHUD showSuccessWithStatus:@"Sent"];
    NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    
    if (statusCode == HttpOK) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SentNewMessage" object:nil];
//        MessageObject *messageObj = [[MessageObject alloc] initWithMessageDictionary:[jsonObj objectForKey:@"messageObject"]];
//        
//        if (messageObj) {
        
//            dispatch_async([CoreDataUtil getDispatch], ^(){
//                
//                [[CoreDataUtil sharedCoreDataUtil] insertNewMessage:messageObj];
//                //
//                //        dispatch_async(dispatch_get_main_queue(), ^(){
//                //
//                //        });
//            });
//        } else {
//            [self sendMessageFailed];
//        }
    } else {
        [self sendMessageFailed];
        
        
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
        content = LocalizedString(@"Please enter recipient and content before sending!");
        
    } else {
        content = LocalizedString(@"Please enter content before sending!");
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}
@end
