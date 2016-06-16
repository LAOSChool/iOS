//
//  SchoolProfileViewController.m
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "SchoolProfileViewController.h"
#import "SchoolRecordTableViewCell.h"
#import "LevelPickerViewController.h"
#import "ScoresViewController.h"
#import "LocalizeHelper.h"
#import "UINavigationController+CustomNavigation.h"
#import "CommonDefine.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "TagManagerHelper.h"

#import "TermObject.h"
#import "ScoreObject.h"

#import "SVProgressHUD.h"
#import "MHTabBarController.h"

typedef enum {
    TabType
    TabType_Max
} TAB_TYPE;

@interface SchoolProfileViewController ()
{
    //overal data
    NSString *className;
    NSString *averageTermOne;
    NSString *averageTermSecond;
    NSString *overalYear;
    NSString *comment;
    NSString *additionalInfo;
    NSInteger rank;
    NSString *grade;
    
    NSMutableArray *averageMonthArr;
    NSString *average4Months;
    NSString *averageExams;
    NSMutableArray *gradeMonthArr;
    NSMutableArray *rankMonthArr;
    
    //subject data
    NSMutableArray *scoresArray;
    NSMutableDictionary *scoresStore;
    
    NSMutableArray *termsArray;
    TermObject *selectedTerm;
    
    LevelPickerViewController *termPicker;
    
    MHTabBarController *tabViewController;
    
    RequestToServer *requestToServer;
}
@end

@implementation SchoolProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TagManagerHelper pushOpenScreenEvent:@"iSchoolRecords"];
    [self setTitle:LocalizedString(@"School records")];
    
    [self.navigationController setNavigationColor];
    
    [viewHeaderContainer setBackgroundColor:GREEN_COLOR];
    [viewTerm setBackgroundColor:GREEN_COLOR];
    
    lbClass.text = LocalizedString(@"Class:");
    lbAverage1.text = LocalizedString(@"Average of tern I:");
    lbAverage2.text = LocalizedString(@"Average of tern II:");
    lbAverageYear.text = LocalizedString(@"Average of year:");
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadSchoolProfileData)];
    
    self.navigationItem.rightBarButtonItems = @[refreshButton];
    
    btnMoreInfo.enabled = NO;   //enable after got the information
    
    if (termsArray == nil) {
        termsArray = [[NSMutableArray alloc] init];
    }
    
    if (scoresArray == nil) {
        scoresArray = [[NSMutableArray alloc] init];
    }
    
    if (scoresStore == nil) {
        scoresStore = [[NSMutableDictionary alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    lbSchoolYear.text = LocalizedString(@"Select a school year");
    [lbSchoolYear setTextColor:[UIColor lightGrayColor]];

    [self loadTermList];
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

- (void)reloadSchoolProfileData {
    if (termPicker && termPicker.view.alpha == 1) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            termPicker.view.alpha = 0;
        } completion:^(BOOL finished) {
            [termPicker.view removeFromSuperview];
        }];
    }
    [self loadTermList];
}

- (IBAction)showTermsListPicker:(id)sender {
    [self showLevelPicker];
}

- (void)showLevelPicker {
    if (termPicker == nil) {
        termPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    }
    
    termPicker.pickerType = Picker_Terms;
    termPicker.dataArray = termsArray;
    termPicker.selectedItem = selectedTerm;
    termPicker.view.alpha = 0;
    
    termPicker.delegate = (id)self;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [termPicker.view setFrame:rect];
    
    [self.view addSubview:termPicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        termPicker.view.alpha = 1;
    }];
}

- (void)btnDoneClick:(id)sender withObjectReturned:(id)returnedObj {
    if (returnedObj) {
        [lbSchoolYear setTextColor:[UIColor whiteColor]];
        TermObject *termObj = (TermObject *)returnedObj;
        lbSchoolYear.text = termObj.termName;
        selectedTerm = termObj;
        
        [self loadSchoolRecordForYear:termObj.termID];
    }
}

- (void)loadTermList {
    [SVProgressHUD show];
    [requestToServer getStudentTermList];
}

- (void)loadSchoolRecordForYear:(NSString *)termID {
    [SVProgressHUD show];
    [requestToServer getSchoolRecordForYear:termID];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if ([url rangeOfString:API_NAME_STU_TERMS_LIST].location != NSNotFound) {
        [termsArray removeAllObjects];
        
        NSArray *terms = [jsonObj objectForKey:@"messageObject"];
        
        if (terms != (id)[NSNull null]) {
            for (NSDictionary *termDict in terms) {
                TermObject *termObj = [[TermObject alloc] init];
                
                if ([termDict valueForKey:@"id"] != (id)[NSNull null]) {
                    termObj.termID = [NSString stringWithFormat:@"%@", [termDict valueForKey:@"id"]];
                }
                
                if ([termDict valueForKey:@"years"] != (id)[NSNull null]) {
                    termObj.termName = [termDict valueForKey:@"years"];
                }
                
                [termsArray addObject:termObj];
            }
        }
        
    } else if ([url rangeOfString:API_NAME_STU_SCHOOL_RECORDS].location != NSNotFound) {
        NSDictionary *scoresDict = [jsonObj objectForKey:@"messageObject"];
        
        if (scoresDict != (id)[NSNull null]) {
            [self parseSchoolRecords:scoresDict];
        }
    }
}

- (void)parseSchoolRecords:(NSDictionary *)scoresDict {
    [scoresArray removeAllObjects];
    [scoresStore removeAllObjects];
    
    NSArray *scores = [scoresDict objectForKey:@"messageObject"];
    
    if (scores != (id)[NSNull null]) {
        
        for (NSDictionary *scoreDict in scores) {
            ScoreObject *scoreObj = [[ScoreObject alloc] init];
            /*
             {"class_id" = 1;
             "exam_dt" = "2016-06-15 16:10:45.0";
             "exam_id" = 2;
             "exam_month" = 10;
             "exam_name" = "October score";
             "exam_type" = 1;
             "exam_year" = 2016;
             id = 2;
             notice = "Nam test - 2016-06-15";
             "sch_year_id" = 1;
             "school_id" = 1;
             sresult = 9;
             "std_nickname" = "Student 10";
             "std_photo" = "http://192.168.0.202:9090/eschool_content/avatar/student1.png";
             "student_id" = 10;
             "student_name" = 00000010;
             subject = Toan;
             "subject_id" = 1;
             teacher = "Teacher class 1";
             "teacher_id" = 5;
             term = "HK 1";
             "term_id" = 1;
             "term_val" = 1;
             }
             */
            if ([scoreDict valueForKey:@"id"] != (id)[NSNull null]) {
                scoreObj.scoreID = [scoreDict valueForKey:@"id"];
            }
            
            if ([scoreDict valueForKey:@"sresult"] != (id)[NSNull null]) {
                scoreObj.score = [scoreDict valueForKey:@"sresult"];
            }
            
            if ([scoreDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                scoreObj.subjectID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"subject_id"]];
            }
            
            if ([scoreDict valueForKey:@"subject"] != (id)[NSNull null]) {
                scoreObj.subject = [scoreDict valueForKey:@"subject"];
            }
            
            if ([scoreDict valueForKey:@"exam_dt"] != (id)[NSNull null]) {
                scoreObj.dateTime = [scoreDict valueForKey:@"exam_dt"];
            }
            
            if ([scoreDict valueForKey:@"exam_id"] != (id)[NSNull null]) {
                scoreObj.examID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"exam_id"]];
            }
            
            if ([scoreDict valueForKey:@"exam_name"] != (id)[NSNull null]) {
                scoreObj.scoreName = [scoreDict valueForKey:@"exam_name"];
            }
            
            if ([scoreDict valueForKey:@"exam_type"] != (id)[NSNull null]) {
                NSInteger type = [[scoreDict valueForKey:@"exam_type"] integerValue];
                
                if (type == 1) {
                    scoreObj.scoreType = ScoreType_Normal;
                    
                } else if (type == 2) {
                    scoreObj.scoreType = ScoreType_Exam;
                    
                } else if (type == 3) {
                    scoreObj.scoreType = ScoreType_Average;
                    
                } else if (type == 4) {
                    scoreObj.scoreType = ScoreType_Final;
                    
                } else if (type == 5) {
                    scoreObj.scoreType = ScoreType_YearFinal;
                    
                } else if (type == 6) {
                    scoreObj.scoreType = ScoreType_ExamAgain;
                    
                } else if (type == 7) {
                    scoreObj.scoreType = ScoreType_Graduate;
                }
            }
            
            if ([scoreDict valueForKey:@"exam_month"] != (id)[NSNull null]) {
                scoreObj.month = [[scoreDict valueForKey:@"exam_month"] integerValue];
            }
            
            if ([scoreDict valueForKey:@"exam_year"] != (id)[NSNull null]) {
                scoreObj.year = [[scoreDict valueForKey:@"exam_year"] integerValue];
            }
            
            if ([scoreDict valueForKey:@"teacher"] != (id)[NSNull null]) {
                scoreObj.teacherName = [scoreDict valueForKey:@"teacher"];
            }
            
            if ([scoreDict valueForKey:@"notice"] != (id)[NSNull null]) {
                scoreObj.comment = [scoreDict valueForKey:@"notice"];
            }
            
            if ([scoreDict valueForKey:@"term_id"] != (id)[NSNull null]) {
                scoreObj.termID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"term_id"]];
            }
            
            if ([scoreDict valueForKey:@"term"] != (id)[NSNull null]) {
                scoreObj.term = [scoreDict valueForKey:@"term"];
            }
            
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[scoresStore objectForKey:scoreObj.termID]];
            
            [arr addObject:scoreObj];
            [scoresStore setObject:arr forKey:scoreObj.termID];
        }
    }
}

- (void)groupScoresByTermAndDisplay:(NSArray *)scores {
    if (tabViewController == nil) {
        tabViewController = [[MHTabBarController alloc] init];
    }
    
    tabViewController.delegate = (id)self;
    
    ScoresViewController *allYearScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    allYearScoreViewController.title = @"Overall year";
    allYearScoreViewController.tableType = ScoreTable_SchoolRecord;
    
    //term 1
    ScoresViewController *term1ScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    term1ScoreViewController.title = @"Term I";
    term1ScoreViewController.tableType = ScoreTable_SchoolRecord;
    
    //Term 2
    ScoresViewController *term2ScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    term2ScoreViewController.title = @"Term II";
    term2ScoreViewController.tableType = ScoreTable_SchoolRecord;
    
    
    //add tab view
    tabViewController.viewControllers = @[allYearScoreViewController, term1ScoreViewController, term2ScoreViewController];
    CGRect rect = viewMainContainer.frame;
    rect.origin.y = 0;
    [tabViewController.view setFrame:rect];
    
    tabViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleTopMargin;
    
    [viewMainContainer addSubview:tabViewController.view];
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
