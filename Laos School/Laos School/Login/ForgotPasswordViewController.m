//
//  ForgotPasswordViewController.m
//  Laos School
//
//  Created by HuKhong on 2/26/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "SVProgressHUD.h"
#import "RequestToServer.h"
#import "Common.h"

@interface ForgotPasswordViewController ()
{
    RequestToServer *requestToServer;
}
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Forget password")];
    
    [self.navigationController setNavigationColor];
    
    [txtUsername setColor:[UIColor grayColor] andImage:[UIImage imageNamed:@"ic_user_gray"]];
    [txtPhonenumber setColor:[UIColor grayColor] andImage:[UIImage imageNamed:@"ic_phone_gray"]];
    
    UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(closeButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnClose];
    
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

- (void)closeButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnSubmitClick:(id)sender {

    if ([self validateInputs]) {
        NSString *username = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtUsername.text];
        
        [requestToServer requestToResetForgotPassword:username andPhonenumber:txtPhonenumber.text];
        
    } else {
        //show alert
        [self showAlertInvalidInputs];
    }
}

#pragma mark RequestToServer delegate
- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
    [self showAlertFailedToConnectToServer];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
}

- (void)sendPostRequestSuccessfully {
    [SVProgressHUD dismiss];
}

- (void)loginWithWrongUserPassword {
    [SVProgressHUD dismiss];
    

}


- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    NSString *statuscode = [jsonObj valueForKey:@"httpStatus"];
    
    if ([statuscode isEqualToString:@"200"]) {
        [self showResetPassSuccessfully];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        [self showAlertWrongUsernamePhonenumber];
    }
}

//return NO if not valid
- (BOOL)validateInputs {
    BOOL res = YES;
    
    NSString *username = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtUsername.text];
    
    if (username.length == 0 || txtPhonenumber.text.length == 0) {
        //show alert invalid
        res = NO;
    }
    
    return res;
}

#pragma mark alert
- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)showAlertUnknowError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There is an error while trying to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
}

- (void)showResetPassSuccessfully {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Successfully") message:LocalizedString(@"A new password will be sent to your phone number.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)showAlertInvalidInputs {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"Please enter your user name and phone number!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}

- (void)showAlertWrongUsernamePhonenumber {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Username or phone number is incorrect!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}
@end
