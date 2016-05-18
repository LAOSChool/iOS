//
//  StudentTimeTableViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentTimeTableViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "RequestToServer.h"
#import "ShareData.h"
#import "TTSessionObject.h"

#import "MHTabBarController.h"
#import "SVProgressHUD.h"

#import "LocalizeHelper.h"

@interface StudentTimeTableViewController ()
{
    MHTabBarController *tabViewController;
    
    RequestToServer *requestToServer;
    
    NSMutableArray *sessionsArray;
}
@end

@implementation StudentTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Time table")];
    
    [self.navigationController setNavigationColor];

//    tabViewController = [[MHTabBarController alloc] init];
//    
//    tabViewController.delegate = (id)self;
//    tabViewController.viewControllers = nil;
//    
//    [tabViewController.view setFrame:viewContainer.frame];
//    
//    tabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
//    UIViewAutoresizingFlexibleHeight |
//    UIViewAutoresizingFlexibleLeftMargin |
//    UIViewAutoresizingFlexibleRightMargin |
//    UIViewAutoresizingFlexibleBottomMargin |
//    UIViewAutoresizingFlexibleTopMargin;
//    
//    [viewContainer addSubview:tabViewController.view];
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (sessionsArray == nil) {
        sessionsArray = [[NSMutableArray alloc] init];
    }
    
    [self loadData];
    
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

- (void)reloadScoreData {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD show];
    [requestToServer getMyTimeTable:[ShareData sharedShareData].userObj.classObj.classID];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    
    [sessionsArray removeAllObjects];
    
    [SVProgressHUD dismiss];
    
    NSArray *sessions = [jsonObj objectForKey:@"list"];
    
    if (sessions != (id)[NSNull null]) {
        
        for (NSDictionary *sessionDict in sessions) {
            /*
             {
             "class_id" = 1;
             description = "Test timetable";
             id = 4;
             "school_id" = 1;
             session = "Ra choi giua gio@20 phut";
             "session_id" = 4;
             subject = English;
             "subject_id" = 4;
             "teacher_id" = 9;
             "teacher_name" = "Teacher 4 - Class 4";
             term = "Term 1";
             "term_id" = 1;
             weekday = "Thu 2";
             "weekday_id" = 1;
             }
             
             @property (nonatomic, strong) NSString *subject;
             @property (nonatomic, strong) NSString *session;
             @property (nonatomic, assign) SESSION_TYPE sessionType;
             @property (nonatomic, strong) NSString *duration;
             @property (nonatomic, strong) NSString *teacherName;
             */
            TTSessionObject *sessionObj = [[TTSessionObject alloc] init];
            
            if ([sessionDict valueForKey:@"subject"] != (id)[NSNull null]) {
                sessionObj.subject = [sessionDict valueForKey:@"subject"];
            }
        }
    }
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];

    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}
@end
