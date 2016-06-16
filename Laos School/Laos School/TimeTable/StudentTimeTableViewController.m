//
//  StudentTimeTableViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentTimeTableViewController.h"
#import "StdTimeTableDayViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "RequestToServer.h"
#import "ShareData.h"
#import "TTSessionObject.h"
#import "UserObject.h"
#import "ClassObject.h"
#import "CommonDefine.h"
#import "DateTimeHelper.h"

#import "MHTabBarController.h"
#import "SVProgressHUD.h"

#import "LocalizeHelper.h"

@interface StudentTimeTableViewController ()
{
    MHTabBarController *tabViewController;
    
    RequestToServer *requestToServer;
    
    NSMutableDictionary *sessionsGroupByDay;
}
@end

@implementation StudentTimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Time table")];
    
    [self.navigationController setNavigationColor];
    [viewHeader setBackgroundColor:GREEN_COLOR];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTimeTableData)];
    
    self.navigationItem.rightBarButtonItems = @[refreshButton];
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (sessionsGroupByDay == nil) {
        sessionsGroupByDay = [[NSMutableDictionary alloc] init];
    }
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    lbClass.text = classObj.className;
    lbTeacherName.text = classObj.teacherName;
    lbTerm.text = [NSString stringWithFormat:@"%@ %@ %@", classObj.currentYear, LocalizedString(@"Term") , classObj.currentTerm];
    
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

- (void)reloadTimeTableData {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD show];
    [requestToServer getMyTimeTable:[ShareData sharedShareData].userObj.classObj.classID];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    
    [sessionsGroupByDay removeAllObjects];
    
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
             
             @property (nonatomic, strong) NSString *weekDay;
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
            
            if ([sessionDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                sessionObj.subjectID = [NSString stringWithFormat:@"%@", [sessionDict valueForKey:@"subject_id"]];
            }
            
            if ([sessionDict valueForKey:@"description"] != (id)[NSNull null]) {
                sessionObj.additionalInfo = [sessionDict valueForKey:@"description"];
            }
            
            if ([sessionDict valueForKey:@"teacher_name"] != (id)[NSNull null]) {
                sessionObj.teacherName = [sessionDict valueForKey:@"teacher_name"];
            }
            
            if ([sessionDict valueForKey:@"weekday_id"] != (id)[NSNull null]) {
                sessionObj.weekDayID = [[sessionDict valueForKey:@"weekday_id"] integerValue];
            }
            
            if ([sessionDict valueForKey:@"weekday"] != (id)[NSNull null]) {
                sessionObj.weekDay = [sessionDict valueForKey:@"weekday"];
            }
            
            if ([sessionDict valueForKey:@"session"] != (id)[NSNull null]) {
                if ([sessionDict valueForKey:@"session_id"] != (id)[NSNull null]) {
                    sessionObj.sessionID = [NSString stringWithFormat:@"%@", [sessionDict valueForKey:@"session_id"]];
                }
                
                NSString *val = [sessionDict valueForKey:@"session"];
                
                NSArray *splitedArr = [val componentsSeparatedByString:@"@"];
                
                if ([splitedArr count] == 1) {
                    sessionObj.session = [splitedArr objectAtIndex:0];
                }
                
                if ([splitedArr count] == 2) {
                    sessionObj.duration = [splitedArr objectAtIndex:1];
                }
                
                if ([splitedArr count] == 3) {
                    if ([[splitedArr objectAtIndex:2] isEqualToString:@"1"]) {
                        sessionObj.sessionType = SessionType_Morning;
                        
                    } else if ([[splitedArr objectAtIndex:2] isEqualToString:@"2"]) {
                        sessionObj.sessionType = SessionType_Afternoon;
                        
                    } else if ([[splitedArr objectAtIndex:2] isEqualToString:@"3"]) {
                        sessionObj.sessionType = SessionType_Evening;
                    }
                }
                
                if ([splitedArr count] == 4) {
                    sessionObj.order = [[splitedArr objectAtIndex:3] integerValue];
                }
            }
            
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[sessionsGroupByDay objectForKey:sessionObj.weekDay]];
            
            [arr addObject:sessionObj];
            [sessionsGroupByDay setObject:arr forKey:sessionObj.weekDay];
        }

        if ([sessionsGroupByDay count] > 0) {
            //group session by weekday
            NSArray *keyArr = [sessionsGroupByDay allKeys];
            keyArr = [self sortSessionByWeekDay:keyArr];
            
            if (tabViewController == nil) {
                tabViewController = [[MHTabBarController alloc] init];
            }
            
            tabViewController.delegate = (id)self;
            
            NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
            
            for (NSString *key in keyArr) {
                StdTimeTableDayViewController *weekDayViewController = [[StdTimeTableDayViewController alloc] initWithNibName:@"StdTimeTableDayViewController" bundle:nil];
                weekDayViewController.title = key;
                weekDayViewController.sessionsArray = [sessionsGroupByDay objectForKey:key];
                weekDayViewController.timeTableType = TimeTableFull;
                
                [viewControllers addObject:weekDayViewController];
                
            }
            
            if ([viewControllers  count] > 0) {
                tabViewController.viewControllers = viewControllers;
                CGRect rect = viewContainer.frame;
                rect.origin.y = 0;
                [tabViewController.view setFrame:rect];
                
                tabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                UIViewAutoresizingFlexibleHeight |
                UIViewAutoresizingFlexibleLeftMargin |
                UIViewAutoresizingFlexibleRightMargin |
                UIViewAutoresizingFlexibleBottomMargin |
                UIViewAutoresizingFlexibleTopMargin;
                
                [viewContainer addSubview:tabViewController.view];
                
                NSInteger dayIndex = [[DateTimeHelper sharedDateTimeHelper] convertWeekdayToIndexFromDate:[NSDate date]];
                
                if (dayIndex <= [viewControllers  count]) {
                    [tabViewController setSelectedIndex:dayIndex - 1 animated:YES];
                }
            }

        } else {
            if (tabViewController) {
                [tabViewController.view removeFromSuperview];
            }
        }
        
    }
}

- (NSArray *)sortSessionByWeekDay:(NSArray *)arr {
    
    if ([arr count] > 1) {
        NSMutableArray *sortArr = [[NSMutableArray alloc] initWithArray:arr];
        [sortArr sortUsingComparator:^(NSString *a, NSString *b){
            return [a compare:b];
        }];
        
        return sortArr;
    }
    return arr;
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
