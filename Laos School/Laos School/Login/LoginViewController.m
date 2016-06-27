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
    [viewContainer setBackgroundColor:[UIColor whiteColor]];
    
    viewContainer.layer.cornerRadius = 8.0f;
    viewContainer.layer.masksToBounds = YES;
    
    if (IS_IPAD) {
        [txtUsername setColor:COMMON_COLOR andImage:[UIImage imageNamed:@"ic_user_gray"]];
        [txtPassword setColor:COMMON_COLOR andImage:[UIImage imageNamed:@"ic_key"]];

    } else {
        [txtUsername setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_user_gray"]];
        [txtPassword setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_key"]];
    }
    
    [txtUsername setPlaceholder:LocalizedString(@"User name")];
    [txtPassword setPlaceholder:LocalizedString(@"Password")];
    
    [btnLogin setTitle:LocalizedString(@"Login") forState:UIControlStateNormal];
    [btnForgot setTitle:LocalizedString(@"Forgot password?") forState:UIControlStateNormal];
    
    
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
        if ([[Common sharedCommon]networkIsActive]) {
            [SVProgressHUD show];
            [requestToServer getMyProfile];
            
        } else {
            [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
        }
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
    [self showAlertUnknowError];
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
     classes =     (
     {
     "class_type" = 1;
     "end_dt" = "2017-06-30 00:00:00.0";
     fee = 0;
     "grade_type" = 1;
     headTeacherName = "Teacher class 1";
     "head_teacher_id" = 5;
     id = 1;
     location = "1A1room - floor 2";
     "school_id" = 1;
     "start_dt" = "2016-09-05 00:00:00.0";
     sts = 1;
     term = 1;
     title = 1A1;
     years = "2016-2017";
     }
     );
     "default_pass" = "<null>";
     email = "<null>";
     ext = "<null>";
     fullname = "Student 10";
     gender = "<null>";
     id = 10;
     nickname = "Student 10";
     permisions = "<null>";
     phone = 1234567890;
     photo = "http://192.168.0.202:9090/eschool_content/avatar/student1.png";
     roles = STUDENT;
     schoolName = "Truong Tieu Hoc Thanh Xuan Trung";
     "school_id" = 1;
     "sso_id" = 00000010;
     state = 1;
     "std_contact_email" = "<null>";
     "std_contact_name" = "<null>";
     "std_contact_phone" = "<null>";
     "std_graduation_dt" = "<null>";
     "std_parent_name" = "<null>";
     "std_payment_dt" = "<null>";
     "std_valid_through_dt" = "<null>";
     }
     }
     
     */
    UserObject *userObject = [[UserObject alloc] init];
    
    if ([jsonObj valueForKey:@"id"] != (id)[NSNull null]) {
        userObject.userID = [NSString stringWithFormat:@"%@", [jsonObj valueForKey:@"id"]];
    }
    
    if ([jsonObj valueForKey:@"sso_id"] != (id)[NSNull null]) {
        userObject.username = [jsonObj valueForKey:@"sso_id"];
    }
    
    if ([jsonObj valueForKey:@"fullname"] != (id)[NSNull null]) {
        userObject.displayName = [jsonObj valueForKey:@"fullname"];
    }
    
    if ([jsonObj valueForKey:@"nickname"] != (id)[NSNull null]) {
        userObject.nickName = [jsonObj valueForKey:@"nickname"];
    }
    
    if ([jsonObj valueForKey:@"gender"] != (id)[NSNull null]) {
        userObject.gender = [jsonObj valueForKey:@"gender"];
    }
    
    if ([jsonObj valueForKey:@"photo"] != (id)[NSNull null]) {
        userObject.avatarPath = [jsonObj valueForKey:@"photo"];
    }
    
    if ([jsonObj valueForKey:@"phone"] != (id)[NSNull null]) {
        userObject.phoneNumber = [jsonObj valueForKey:@"phone"];
    }
    
    if ([jsonObj valueForKey:@"roles"] != (id)[NSNull null]) {
        NSString *role = [jsonObj objectForKey:@"roles"];
        if (role != (id)[NSNull null] && role && role.length > 0) {
            
            if ([role isEqualToString:USER_ROLE_STUDENT]) {
                userObject.userRole = UserRole_Student;
                userObject.permission = Permission_Normal | Permission_SendMessage;
                
            } else if ([role isEqualToString:USER_ROLE_PRESIDENT]) {
                userObject.userRole = UserRole_Student;
                userObject.permission = Permission_Normal | Permission_SendMessage | Permission_CheckAttendance;
                
            } else if ([role isEqualToString:USER_ROLE_HEAD_TEACHER]) {
                userObject.userRole = UserRole_Teacher;
                userObject.permission = Permission_Normal | Permission_SendMessage | Permission_CheckAttendance | Permission_SendAnnouncement | Permission_AddScore;
                
            }
            
        }
    }
    
    if ([jsonObj valueForKey:@"school_id"] != (id)[NSNull null]) {
        userObject.shoolID = [jsonObj objectForKey:@"school_id"];
    }
    
    if ([jsonObj valueForKey:@"schoolName"] != (id)[NSNull null]) {
        userObject.schoolName = [jsonObj objectForKey:@"schoolName"];
    }
    
    ClassObject *classObject = [[ClassObject alloc] init];
    NSArray *classesArr = [jsonObj objectForKey:@"classes"];
    if ([classesArr count] > 0) {
        NSDictionary *classDictionary = [classesArr objectAtIndex:0];
        if (classDictionary) {
            classObject.classID = [NSString stringWithFormat:@"%@", [classDictionary valueForKey:@"id"]];
            classObject.className = [classDictionary valueForKey:@"title"];
            classObject.teacherID = [NSString stringWithFormat:@"%@", [classDictionary valueForKey:@"head_teacher_id"]];
            classObject.teacherName = [classDictionary valueForKey:@"headTeacherName"];
            classObject.classLocation = [classDictionary valueForKey:@"location"];
            classObject.currentTerm = [NSString stringWithFormat:@"%@", [classDictionary valueForKey:@"term"]];
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
        splitViewController = [[UISplitViewController alloc] init];
        [splitViewController setViewControllers:[NSArray arrayWithObjects:navMessage, nil]];
        messageViewController.splitViewController = splitViewController;
        splitViewController.delegate = (id)messageViewController;
        splitViewController.extendedLayoutIncludesOpaqueBars = YES;
        
        splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    
    //Announcement
    AnnouncementViewController *announcementViewController = [[AnnouncementViewController alloc] initWithNibName:@"AnnouncementViewController" bundle:nil];
    UINavigationController *navAnnouncement = [[UINavigationController alloc] initWithRootViewController:announcementViewController];
    
    //for iPad
    UISplitViewController *splitViewController_announce = nil;
    if (IS_IPAD) {
        splitViewController_announce = [[UISplitViewController alloc] init];
        [splitViewController_announce setViewControllers:[NSArray arrayWithObjects:navAnnouncement, nil]];
        announcementViewController.splitViewController = splitViewController_announce;
        splitViewController_announce.delegate = (id)announcementViewController;
        splitViewController_announce.extendedLayoutIncludesOpaqueBars = YES;
        
        splitViewController_announce.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }
    
    //Scrore
    UINavigationController *navScoreView = nil;
    
    if ([ShareData sharedShareData].userObj.userRole == UserRole_Student) {
        ScoresViewController *scoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
        scoreViewController.tableType = ScoreTable_Normal;
        
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
    /*
    //for iPad
    UISplitViewController *splitViewController_More = nil;
    if (IS_IPAD) {
        SchoolProfileViewController *schoolProfileView = [[SchoolProfileViewController alloc] initWithNibName:@"SchoolProfileViewController" bundle:nil];
        UINavigationController *navschoolProfile = [[UINavigationController alloc] initWithRootViewController:schoolProfileView];
        
        splitViewController_More = [[UISplitViewController alloc] init];
        [splitViewController_More setViewControllers:[NSArray arrayWithObjects:navMore, navschoolProfile, nil]];
        moreViewController.splitViewController = splitViewController_More;
        splitViewController_More.preferredDisplayMode = UISplitViewControllerDisplayModeAllVisible;
    }*/
    
    NSArray *tabArray = nil;
    if (IS_IPAD) {
        tabArray = [[NSArray alloc] initWithObjects:splitViewController, splitViewController_announce, navAttendance, navScoreView, navMore, nil];
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

- (IBAction)txtUsernameChange:(id)sender {
    
}

- (IBAction)txtPassChange:(id)sender {
//    if (txtUsername.text.length != 0 &&
//        txtPassword.text.length != 0) {
//        
//        btnLogin.enabled = YES;
//        
//    } else {
//        btnLogin.enabled = NO;
//    }
}

@end
