//
//  ChangePasswordViewController.m
//  Laos School
//
//  Created by HuKhong on 5/23/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "RequestToServer.h"
#import "LocalizeHelper.h"
#import "CommonDefine.h"
#import "ShareData.h"
#import "UserObject.h"

#import "SVProgressHUD.h"

@interface ChangePasswordViewController ()
{
    RequestToServer *requestToServer;
}
@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Change password")];
    
    [self.navigationController setNavigationColor];
    
    [txtOldPass setColor:[UIColor darkGrayColor] andImage:[UIImage imageNamed:@"ic_key"]];
    [txtNewPass setColor:[UIColor darkGrayColor] andImage:[UIImage imageNamed:@"ic_key"]];
    [txtConfirmation setColor:[UIColor darkGrayColor] andImage:[UIImage imageNamed:@"ic_key"]];
    
    [btnSubmit setTitle:LocalizedString(@"Submit") forState:UIControlStateNormal];
    
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

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtOldPass resignFirstResponder];
    [txtNewPass resignFirstResponder];
    [txtConfirmation resignFirstResponder];
}


- (IBAction)txtOldPassChange:(id)sender {
    if (txtOldPass.text.length != 0 &&
        txtNewPass.text.length != 0 &&
        txtConfirmation.text.length != 0) {

        btnSubmit.enabled = YES;
        
    } else {
        btnSubmit.enabled = NO;
    }
}

- (IBAction)txtNewPassChange:(id)sender {
    if (txtOldPass.text.length != 0 &&
        txtNewPass.text.length != 0 &&
        txtConfirmation.text.length != 0) {
        
        btnSubmit.enabled = YES;
        
    } else {
        btnSubmit.enabled = NO;
    }
}

- (IBAction)txtConfirmationChange:(id)sender {
    if (txtOldPass.text.length != 0 &&
        txtNewPass.text.length != 0 &&
        txtConfirmation.text.length != 0) {
        
        btnSubmit.enabled = YES;
        
    } else {
        btnSubmit.enabled = NO;
    }
}


- (IBAction)btnSubmitClick:(id)sender {
    [txtOldPass resignFirstResponder];
    [txtNewPass resignFirstResponder];
    [txtConfirmation resignFirstResponder];
    
    if ([txtNewPass.text isEqualToString:txtConfirmation.text]) {
        if (txtNewPass.text.length < 4 || txtNewPass.text.length > 20) {
            [self showAlertPasswordTooShort];
            
        } else {
            [SVProgressHUD show];
            UserObject *userObj = [[ShareData sharedShareData] userObj];
            
            [requestToServer requestToChangePassword:@"00000010" oldPass:txtOldPass.text byNewPass:txtNewPass.text];
        }
    } else {
        [self showAlertPasswordNotMatch];
    }
}

#pragma mark text view delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:txtOldPass]) {
        [txtNewPass becomeFirstResponder];
        
    } else if ([textField isEqual:txtNewPass]) {
        [txtConfirmation becomeFirstResponder];
        
    } else if ([textField isEqual:txtConfirmation]) {
        [txtConfirmation resignFirstResponder];
        
    }
    
    return YES;
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    NSInteger statuscode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    
    if (statuscode == HttpOK) {
        [self showChangePassSuccessfully];
        [self.navigationController popViewControllerAnimated:YES];
        
    } else {
        [self showAlertWrongPassword];
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

- (void)loginWithWrongUserPassword {
    [SVProgressHUD dismiss];
    
    
}

#pragma mark alert
- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)showChangePassSuccessfully {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Successfully") message:LocalizedString(@"Change password successfully.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)showAlertWrongPassword {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Old password is incorrect!") delegate:(id)self cancelButtonTitle:LocalizedString(@"Try again") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}

- (void)showAlertPasswordTooShort {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"The password is required a length of 4 to 20 characters!") delegate:(id)self cancelButtonTitle:LocalizedString(@"Try again") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}

- (void)showAlertPasswordNotMatch {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"New password and confirmation password do not match!") delegate:(id)self cancelButtonTitle:LocalizedString(@"Try again") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 6;
    
    [alert show];
}
@end