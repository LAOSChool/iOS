//
//  CreatePermissionViewController.m
//  Laos School
//
//  Created by HuKhong on 3/3/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "CreatePermissionViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "TimerViewController.h"
#import "DateTimeHelper.h"
#import "RequestToServer.h"
#import "Common.h"
#import "CommonAlert.h"
#import "ShareData.h"
#import "SVProgressHUD.h"

@interface CreatePermissionViewController ()
{
    TimerViewController *dateTimePicker;
    
    IBOutlet UILabel *lbDate;
    IBOutlet UITextView *txtReason;
    
    RequestToServer *requestToServer;
}
@end

@implementation CreatePermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Absence request")];
    
    [self.navigationController setNavigationColor];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(btnSendClick)];
    
    self.navigationItem.rightBarButtonItems = @[btnSend];
    
    lbDate.text = [[DateTimeHelper sharedDateTimeHelper] dateStringFromDate:[NSDate date] withFormat:@"yyyy-MM-dd EEEE"];
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
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

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendNewAbsenceRequest {
    [SVProgressHUD show];
    NSMutableDictionary *requestDict = [[NSMutableDictionary alloc] init];

    /*
     {"school_id":1,"class_id":1,"att_dt":"2016-05-16 00:00:00.0","user_id":14,"absent":1,"notice":"Test vang mat from request"}
     */
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    NSString *reason = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtReason.text];
    
    [requestDict setValue:userObj.shoolID forKey:@"school_id"];
    [requestDict setValue:classObj.classID forKey:@"class_id"];
    [requestDict setValue:[[DateTimeHelper sharedDateTimeHelper] dateStringFromString:lbDate.text withFormat:@"yyyy-MM-dd"] forKey:@"att_dt"];
    [requestDict setValue:userObj.userID forKey:@"student_id"];
    [requestDict setValue:[NSNumber numberWithInteger:1] forKey:@"state"];
    [requestDict setValue:reason forKey:@"notice"];
    
    [requestToServer createAbsenceRequest:requestDict];
}

//return NO if not valid
- (BOOL)validateInputs {
    BOOL res = YES;

    NSString *reason = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtReason.text];
    
    if (reason.length == 0 || reason.length == 0) {
        //show alert invalid
        res = NO;
    }
    
    return res;
}

- (void)btnSendClick {
    [txtReason resignFirstResponder];
    
    if ([self validateInputs]) {
        [self confirmBeforeSendingRequest];
        
    } else {
        [self showAlertInvalidInputs];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

- (IBAction)tapGestureHandle:(id)sender {
    [txtReason resignFirstResponder];
}
- (IBAction)swipeGestureHandle:(id)sender {
    [txtReason resignFirstResponder];
}

- (IBAction)btnChooseDateClick:(id)sender {
    [txtReason resignFirstResponder];
    [self showDateTimePicker];
}

- (void)showDateTimePicker {
    dateTimePicker = [[TimerViewController alloc] initWithNibName:@"TimerViewController" bundle:nil];
    dateTimePicker.view.alpha = 0;
    dateTimePicker.delegate = (id)self;
    dateTimePicker.dateTime = lbDate.text;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [dateTimePicker.view setFrame:rect];
    
    [self.view addSubview:dateTimePicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        dateTimePicker.view.alpha = 1;
    }];
}

- (void)btnDoneClick:(id)sender withValueReturned:(NSString *)value {
    lbDate.text = value;
}

#pragma mark alert
- (void)confirmBeforeSendingRequest {
    NSString *content = LocalizedString(@"Please double check informations before sending your request.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Are you sure?") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)showAlertInvalidInputs {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"Please enter your reason!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)sendRequestFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while sending request. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}

- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {    //confirmBeforeSendingRequest
        if (buttonIndex != 0) {
            if ([[Common sharedCommon]networkIsActive]) {
                [self sendNewAbsenceRequest];
            } else {
                [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
            }
        }
    }
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    
    if (statusCode == HttpOK) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
            [SVProgressHUD showSuccessWithStatus:@"Sent"];
        }];
        
    } else {
        [self sendRequestFailed];
        
        
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
@end
