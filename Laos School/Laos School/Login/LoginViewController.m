//
//  LoginViewController.m
//  Laos School
//
//  Created by HuKhong on 2/22/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "LoginViewController.h"
#import "TagManagerHelper.h"
#import "AppDelegate.h"
#import "Common.h"
#import "LocalizeHelper.h"

#import "MainTabBarViewController.h"
#import "MessagesViewController.h"
#import "AnnouncementViewController.h"
#import "StudentAttendanceViewController.h"
#import "TeacherAttendanceViewController.h"
#import "StudentTimeTableViewController.h"
#import "TeacherTimeTableViewController.h"
#import "MoreViewController.h"

#import "ForgotPasswordViewController.h"
#import "HelpViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
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
- (IBAction)btnHelpClick:(id)sender {
    HelpViewController *helpViewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:helpViewController];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnLoginClick:(id)sender {
    //call login function
    [self login];
}


- (IBAction)btnForgotClick:(id)sender {
    //transfer to forgot passw screen
    ForgotPasswordViewController *forgotPassViewcontroller = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:forgotPassViewcontroller];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self presentViewController:nav animated:YES completion:nil];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField isEqual:txtUsername]) {
        [txtPassword becomeFirstResponder];
        
    } else if ([textField isEqual:txtUsername]) {
        [txtPassword resignFirstResponder];
        
        //call login function
        [self login];
    }
    
    return NO;
}

//return NO if not valid
- (BOOL)validateInputs {
    BOOL res = YES;
    
    NSString *username = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtUsername.text];
    
    if (username.length == 0 || txtPassword.text.length == 0) {
        //show alert invalid
//        res = NO;
        res = YES;//for test
    }
    
    return res;
}

- (void)login {
    if ([self validateInputs]) {
        NSString *username = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtUsername.text];
        
        
        //for test
        //Tabbar
        NSArray *tabArray = [self prepareForMaintabViewController];
        
        MainTabBarViewController *tab = [[MainTabBarViewController alloc] initWithViewControllers:tabArray];

        [tab.tabBar setTranslucent:NO];
        [tab.tabBar setBarTintColor:[UIColor whiteColor]];

        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = tab;
        
    } else {
        //show alert
        [self showAlertInvalidInputs];
    }
}

- (NSArray *)prepareForMaintabViewController {
    //Message
    MessagesViewController *messageViewController = [[MessagesViewController alloc] initWithNibName:@"MessagesViewController" bundle:nil];
    UINavigationController *navMessage = [[UINavigationController alloc] initWithRootViewController:messageViewController];
    
    //Announcement
    AnnouncementViewController *announcementViewController = [[AnnouncementViewController alloc] initWithNibName:@"AnnouncementViewController" bundle:nil];
    UINavigationController *navAnnouncement = [[UINavigationController alloc] initWithRootViewController:announcementViewController];
    
    //Attendance
//    StudentAttendanceViewController *attendanceViewController = [[StudentAttendanceViewController alloc] initWithNibName:@"StudentAttendanceViewController" bundle:nil];
//    UINavigationController *navAttendance = [[UINavigationController alloc] initWithRootViewController:attendanceViewController];

    TeacherAttendanceViewController *attendanceViewController = [[TeacherAttendanceViewController alloc] initWithNibName:@"TeacherAttendanceViewController" bundle:nil];
    UINavigationController *navAttendance = [[UINavigationController alloc] initWithRootViewController:attendanceViewController];

    
    //Time table
    StudentTimeTableViewController *timetableViewController = [[StudentTimeTableViewController alloc] initWithNibName:@"StudentTimeTableViewController" bundle:nil];
    UINavigationController *navTimeTable = [[UINavigationController alloc] initWithRootViewController:timetableViewController];
    
    //More
    MoreViewController *moreViewController = [[MoreViewController alloc] initWithNibName:@"MoreViewController" bundle:nil];
    UINavigationController *navMore = [[UINavigationController alloc] initWithRootViewController:moreViewController];
    
    NSArray *tabArray = [[NSArray alloc] initWithObjects:navMessage, navAnnouncement, navAttendance, navTimeTable, navMore, nil];
    
    return tabArray;
}

#pragma mark alert
- (void)showAlertInvalidInputs {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"Please enter your user name and password!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}
@end
