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
#import "MessageDetailViewController.h"
#import "AnnouncementViewController.h"
#import "StudentAttendanceViewController.h"
#import "TeacherAttendanceViewController.h"
#import "MoreViewController.h"
#import "SchoolProfileViewController.h"
#import "ScoresViewController.h"
#import "TeacherScoresViewController.h"

#import "ForgotPasswordViewController.h"
#import "HelpViewController.h"

#import "RequestToServer.h"

#import "UserObject.h"
#import "ShareData.h"
#import "ArchiveHelper.h"
#import "SVProgressHUD.h"
#import "CommonAlert.h"

@interface LoginViewController ()
{
    RequestToServer *requestToServer;
    
    NSInteger timeCounter;
    NSTimer *timer;
}
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view setBackgroundColor:COMMON_COLOR];
    
    [txtUsername setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_user_gray"]];
    [txtPassword setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_key"]];
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    NSString *authkey = [[ArchiveHelper sharedArchiveHelper] loadAuthKey];
    NSString *username = [[ArchiveHelper sharedArchiveHelper] loadUsername];
    
    if (username && username.length > 0) {
        txtUsername.text = username;
    }
    
    if (authkey && authkey.length > 0) {
        
        [SVProgressHUD show];
        [requestToServer getMyProfile];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(disableForgotPassword)
                                                 name:@"SentForgotPassRequest"
                                               object:nil];
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
    if ([[Common sharedCommon]networkIsActive]) {
        [self login];
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
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
        
    } else if ([textField isEqual:txtPassword]) {
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
        res = NO;
    }
    
    return res;
}

- (void)login {
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
    if ([self validateInputs]) {
        NSString *username = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:txtUsername.text];
        
        [[ArchiveHelper sharedArchiveHelper] saveUsername:username];
        
        [SVProgressHUD showWithStatus:LocalizedString(@"Login...")];
        [requestToServer loginWithUsername:username andPassword:txtPassword.text];
        
        /*UserObject *userObject = [[UserObject alloc] init];
         
         userObject.userID = @"1";
         userObject.username = @"Nguyen Tien Nam";
         userObject.displayName = @"Nguyen Nam";
         userObject.nickName = @"Yukan";
         userObject.avatarPath = @"";
         userObject.phoneNumber = @"0938912885";
         userObject.userRole = UserRole_Teacher;
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
         
         [[ShareData sharedShareData] setUserObj:userObject];*/
        
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

- (void)loginWithWrongUserPassword {
    [SVProgressHUD dismiss];
    [[ArchiveHelper sharedArchiveHelper] clearAuthKey];
    [self showAlertWrongUsernamePassword];
}
- (void)loginSuccessfully {
    [requestToServer getMyProfile];
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
    [[ArchiveHelper sharedArchiveHelper] clearAuthKey];
    [self showAlertAccountLoginByOtherDevice];
}

- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    /*
     {
     addr1 = "<null>";
     addr2 = "<null>";
     birthday = "<null>";
     eclass =     {
     "class_type" = 1;
     "end_dt" = "2017-06-30 00:00:00.0";
     fee = 0;
     "grade_type" = 1;
     "head_teacher_id" = 3;
     id = 1;
     location = "1A1room - floor 2";
     "school_id" = 1;
     "start_dt" = "2016-09-05 00:00:00.0";
     sts = 1;
     term = 1;
     title = 1A1;
     years = "2016-2017";
     };
     email = "<null>";
     ext = "<null>";
     fullname = "Nguyen Quang Huy";
     gender = "<null>";
     id = 1;
     nickname = Huy;
     phone = "<null>";
     photo = "<null>";
     roles = ADMIN;
     "school_id" = 1;
     "sso_id" = huynq;
     state = Active;
     "std_contact_email" = "<null>";
     "std_contact_name" = "<null>";
     "std_contact_phone" = "<null>";
     "std_graduation_dt" = "<null>";
     "std_parent_name" = "<null>";
     "std_payment_dt" = "<null>";
     "std_valid_through_dt" = "<null>";
     }
     
     */
    //for test
    UserObject *userObject = [[UserObject alloc] init];
    
    userObject.userID = [jsonObj objectForKey:@"id"];
    userObject.username = [jsonObj objectForKey:@"fullname"];
    userObject.displayName = @"";
    userObject.nickName = [jsonObj objectForKey:@"nickname"];
    userObject.avatarPath = [jsonObj objectForKey:@"photo"];
    userObject.phoneNumber = [jsonObj objectForKey:@"phone"];
    userObject.userRole = UserRole_Student;
    userObject.permission = Permission_Normal | Permission_SendMessage | Permission_SendAnnouncement;
    
    userObject.shoolID = [jsonObj objectForKey:@"school_id"];
    userObject.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject = [[ClassObject alloc] init];
    NSArray *classesArr = [jsonObj objectForKey:@"classes"];
    if ([classesArr count] > 0) {
        NSDictionary *classDictionary = [classesArr objectAtIndex:0];
        if (classDictionary) {
            classObject.classID = [classDictionary valueForKey:@"id"];
            classObject.className = [classDictionary valueForKey:@"title"];
            classObject.teacherID = [classDictionary valueForKey:@"head_teacher_id"];
            classObject.teacherName = [classDictionary valueForKey:@"headTeacherName"];
            classObject.classLocation = [classDictionary valueForKey:@"location"];
            classObject.currentTerm = [classDictionary valueForKey:@"term"];
            classObject.currentYear = [classDictionary valueForKey:@"years"];
            classObject.pupilArray = nil;
        }
    }
    
    userObject.classObj = classObject;
    userObject.classArray = nil;
    
    [[ShareData sharedShareData] setUserObj:userObject];
    
    //Tabbar
    NSArray *tabArray = [self prepareForMaintabViewController];
    
    MainTabBarViewController *tab = [[MainTabBarViewController alloc] initWithViewControllers:tabArray];
    
    [tab.tabBar setTranslucent:NO];
    [tab.tabBar setBarTintColor:[UIColor whiteColor]];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = tab;
}

- (NSArray *)prepareForMaintabViewController {
    //Message
    MessagesViewController *messageViewController = [[MessagesViewController alloc] initWithNibName:@"MessagesViewController" bundle:nil];
    UINavigationController *navMessage = [[UINavigationController alloc] initWithRootViewController:messageViewController];
    
    //for iPad
    UISplitViewController *splitViewController = nil;
    if (IS_IPAD) {
        MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewController" bundle:nil];
        UINavigationController *navMessageDetail = [[UINavigationController alloc] initWithRootViewController:messageDetailViewController];
        
        splitViewController = [[UISplitViewController alloc] init];
        [splitViewController setViewControllers:[NSArray arrayWithObjects:navMessage, navMessageDetail, nil]];
        messageViewController.splitViewController = splitViewController;
        splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    
    //Announcement
    AnnouncementViewController *announcementViewController = [[AnnouncementViewController alloc] initWithNibName:@"AnnouncementViewController" bundle:nil];
    UINavigationController *navAnnouncement = [[UINavigationController alloc] initWithRootViewController:announcementViewController];
    
    //Scrore
    UINavigationController *navScoreView = nil;
    
    if ([ShareData sharedShareData].userObj.userRole == UserRole_Student) {
        ScoresViewController *scoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
        navScoreView = [[UINavigationController alloc] initWithRootViewController:scoreViewController];
        
    } else {
        TeacherScoresViewController *teacherScoresViewController = [[TeacherScoresViewController alloc] initWithNibName:@"TeacherScoresViewController" bundle:nil];
        navScoreView = [[UINavigationController alloc] initWithRootViewController:teacherScoresViewController];
        
    }
    
    
    //Attendance
    UINavigationController *navAttendance = nil;
    
    if ([ShareData sharedShareData].userObj.userRole == UserRole_Student) {
        StudentAttendanceViewController *attendanceViewController = [[StudentAttendanceViewController alloc] initWithNibName:@"StudentAttendanceViewController" bundle:nil];
        
        navAttendance = [[UINavigationController alloc] initWithRootViewController:attendanceViewController];
        
    } else {
        TeacherAttendanceViewController *teacherAttendanceViewController = [[TeacherAttendanceViewController alloc] initWithNibName:@"TeacherAttendanceViewController" bundle:nil];
        navAttendance = [[UINavigationController alloc] initWithRootViewController:teacherAttendanceViewController];
    }
    
    //More
    MoreViewController *moreViewController = [[MoreViewController alloc] initWithNibName:@"MoreViewController" bundle:nil];
    UINavigationController *navMore = [[UINavigationController alloc] initWithRootViewController:moreViewController];
    
    //for iPad
    UISplitViewController *splitViewController_More = nil;
    if (IS_IPAD) {
        SchoolProfileViewController *schoolProfileView = [[SchoolProfileViewController alloc] initWithNibName:@"SchoolProfileViewController" bundle:nil];
        UINavigationController *navschoolProfile = [[UINavigationController alloc] initWithRootViewController:schoolProfileView];
        
        splitViewController_More = [[UISplitViewController alloc] init];
        [splitViewController_More setViewControllers:[NSArray arrayWithObjects:navMore, navschoolProfile, nil]];
        moreViewController.splitViewController = splitViewController_More;
        splitViewController_More.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    
    NSArray *tabArray = nil;
    if (IS_IPAD) {
        tabArray = [[NSArray alloc] initWithObjects:splitViewController, navAnnouncement, navAttendance, navScoreView, splitViewController_More, nil];
    } else {
        tabArray = [[NSArray alloc] initWithObjects:navMessage, navAnnouncement, navAttendance, navScoreView, navMore, nil];
    }
    
    return tabArray;
}

#pragma mark alert
- (void)showAlertInvalidInputs {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"Please enter your username and password!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)showAlertWrongUsernamePassword {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Username or password is incorrect!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
}

- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)showAlertUnknowError {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There is an error while trying to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 4;
    
    [alert show];
}

#pragma mark timer
- (void)disableForgotPassword {
    //disable Get PIN button for 60s
    btnForgot.enabled = NO;
    timeCounter = 60;
    timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(resetForgotButton) userInfo:nil repeats:YES];
}

- (void)resetForgotButton {
    if (timeCounter == 0) {
        btnForgot.enabled = YES;
        [timer invalidate];
        
    } else {
        timeCounter--;
        btnForgot.enabled = NO;
    }
}
@end
