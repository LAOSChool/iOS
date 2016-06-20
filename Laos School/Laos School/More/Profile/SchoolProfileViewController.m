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
    TabType_TermFirst = 0,
    TabType_TermSecond,
    TabType_AllYear,
    TabType_Other,
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
    
    BOOL isShowingInfo;
    
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
    
    isShowingInfo = NO;
    
    [viewHeaderContainer setBackgroundColor:[UIColor whiteColor]];
    [viewTerm setBackgroundColor:GREEN_COLOR];
    
    lbClass.text = LocalizedString(@"Class:");
    lbAverage1.text = LocalizedString(@"Term I:");
    lbAverage2.text = LocalizedString(@"Term II:");
    lbAverageYear.text = LocalizedString(@"Overall:");
    
    lbPassed.text = @"...";
    lbMorality.text = LocalizedString(@"Morality:");
    lbAbsence.text = LocalizedString(@"Absence:");
    lbTeacherComment.text = LocalizedString(@"Teacher's comment:");
    
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
    
    lbClassValue.text = @"...";
    lbAverage1Value.text = @"0";
    lbAverage2Value.text = @"0";
    lbAverageYearValue.text = @"0";

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

- (IBAction)btnInforClick:(id)sender {
    [self showHideInfoView];
}

- (void)showHideInfoView {
    [UIView animateWithDuration:0.8 animations:^(void) {
        if (isShowingInfo) {
            isShowingInfo = NO;
            
            CGRect mainRect = viewMainContainer.frame;
            CGRect infoRect = viewAdditionalInfo.frame;
            
            mainRect.origin.y = infoRect.origin.y;
            [viewMainContainer setFrame:mainRect];
            
        } else {
            isShowingInfo = YES;
            
            CGRect mainRect = viewMainContainer.frame;
            CGRect infoRect = viewAdditionalInfo.frame;
            
            mainRect.origin.y = infoRect.origin.y + infoRect.size.height;
            [viewMainContainer setFrame:mainRect];
        }
    }];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if ([url rangeOfString:API_NAME_STU_TERMS_LIST].location != NSNotFound) {
        [termsArray removeAllObjects];
        
        NSArray *terms = [jsonObj objectForKey:@"messageObject"];
        
        if (terms != (id)[NSNull null]) {
            BOOL found = NO;
            for (NSDictionary *termDict in terms) {
                TermObject *termObj = [[TermObject alloc] init];
                
                if ([termDict valueForKey:@"id"] != (id)[NSNull null]) {
                    termObj.termID = [NSString stringWithFormat:@"%@", [termDict valueForKey:@"id"]];
                }
                
                if ([termDict valueForKey:@"years"] != (id)[NSNull null]) {
                    termObj.termName = [termDict valueForKey:@"years"];
                }
                
                [termsArray addObject:termObj];
                
                if ([termObj.termID isEqualToString:selectedTerm.termID] && found == NO) {
                    found = YES;
                }
            }
            
            if (selectedTerm != nil && found == YES) {
                [self loadSchoolRecordForYear:selectedTerm.termID];
            } else {
                [SVProgressHUD dismiss];
            }
        }
        
    } else if ([url rangeOfString:API_NAME_STU_SCHOOL_RECORDS].location != NSNotFound) {
        NSDictionary *scoresDict = [jsonObj objectForKey:@"messageObject"];
        
        if (scoresDict != (id)[NSNull null]) {
            [self parseSchoolRecords:scoresDict];
            
        } else {
            if (tabViewController) {
                [tabViewController.view removeFromSuperview];
            }
        }
        
        [SVProgressHUD dismiss];
    }
}

- (void)parseSchoolRecords:(NSDictionary *)scoresDict {
    [scoresArray removeAllObjects];
    [scoresStore removeAllObjects];
    
    //common info
    if ([scoresDict valueForKey:@"cls_name"] != (id)[NSNull null]) {
        lbClassValue.text = [scoresDict objectForKey:@"cls_name"];
    }
    
    if ([scoresDict valueForKey:@"passed"] != (id)[NSNull null]) {
        BOOL passed = [[scoresDict objectForKey:@"passed"] boolValue];
        
        if (passed) {
            lbPassed.text = LocalizedString(@"Passed");

        } else {
            lbPassed.text = LocalizedString(@"Not pass");
        }
    }
    
    if ([scoresDict valueForKey:@"day_absents"] != (id)[NSNull null]) {
        lbAbsenceValue.text = [NSString stringWithFormat:@"%@", [scoresDict objectForKey:@"day_absents"]];
    }
    
    if ([scoresDict valueForKey:@"notice"] != (id)[NSNull null]) {
        txtComment.text = [scoresDict objectForKey:@"notice"];
    } else {
        txtComment.text = LocalizedString(@"No comment");
    }
    
    NSArray *scores = [scoresDict objectForKey:@"exam_results"];
    
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
            
            if ([scoreDict valueForKey:@"ex_displayname"] != (id)[NSNull null]) {
                scoreObj.scoreDisplayName = [scoreDict valueForKey:@"ex_displayname"];
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
        
        [self groupScoresByTermAndDisplay];
        
    } else {
        if (tabViewController) {
            [tabViewController.view removeFromSuperview];
        }
    }
}

- (void)groupScoresByTermAndDisplay {
    
    //break scores into 3 arrays
    NSMutableArray *totalArray = [[NSMutableArray alloc] init];
    NSMutableArray *firstArray = [[NSMutableArray alloc] init];
    NSMutableArray *firstAverageArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *secondArray = [[NSMutableArray alloc] init];
    NSMutableArray *secondAverageArray = [[NSMutableArray alloc] init];
    
    NSArray *keyArr = [scoresStore allKeys];
    
    if ([keyArr count] > 1) {
        [keyArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue]==[obj2 intValue])
                return NSOrderedSame;
            
            else if ([obj1 intValue]<[obj2 intValue])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
            
        }];
    }
    
    if ([keyArr count] > TabType_TermFirst) {
        [firstArray addObjectsFromArray:[scoresStore objectForKey:[keyArr objectAtIndex:TabType_TermFirst]]];
    }
    
    if ([keyArr count] > TabType_TermSecond) {
        [secondArray addObjectsFromArray:[scoresStore objectForKey:[keyArr objectAtIndex:TabType_TermSecond]]];
    }
    
    //if a score is average type, copy it to totalArray
    /*
     ScoreType_Normal = 0,
     ScoreType_Average,
     ScoreType_Exam,
     ScoreType_Final,
     ScoreType_YearFinal,
     ScoreType_ExamAgain,
     ScoreType_Graduate,*/
    for (ScoreObject *score in firstArray) {
        if (score.scoreType == ScoreType_Final ||
            score.scoreType == ScoreType_YearFinal) {
            
            [totalArray addObject:score];
            [firstAverageArray addObject:score];
        }
    }
    
    for (ScoreObject *score in secondArray) {
        if (score.scoreType == ScoreType_Final ||
            score.scoreType == ScoreType_YearFinal) {
            
            [totalArray addObject:score];
            [secondAverageArray addObject:score];
        }
    }
    
    //calculate average
    float totalFirst = 0;
    float totalSecond = 0;
    float totalFinal = 0;
    
    for (ScoreObject *score in firstAverageArray) {
        totalFirst = totalFirst + [score.score floatValue];
        
    }
    
    for (ScoreObject *score in secondAverageArray) {
        totalSecond = totalSecond + [score.score floatValue];
        
    }
    totalFinal = totalFirst + totalSecond;
    
    if ([firstAverageArray count] > 0) {
        lbAverage1Value.text = [NSString stringWithFormat:@"%.1f", totalFirst/[firstAverageArray count]];
    } else {
        lbAverage1Value.text = @"0";
    }
    
    if ([firstAverageArray count] > 0) {
        lbAverage2Value.text = [NSString stringWithFormat:@"%.1f", totalSecond/[secondAverageArray count]];
    } else {
        lbAverage2Value.text = @"0";
    }

    lbAverageYearValue.text = [NSString stringWithFormat:@"%.1f", totalFinal/2];
    
    //display score as tabs
    tabViewController = [[MHTabBarController alloc] init];
    
    tabViewController.delegate = (id)self;
    
    ScoresViewController *allYearScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    allYearScoreViewController.title = @"Overall";
    allYearScoreViewController.tableType = ScoreTable_SchoolRecord;
    allYearScoreViewController.scoresArray = totalArray;
    
    //term 1
    ScoresViewController *term1ScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    term1ScoreViewController.title = @"Term I";
    term1ScoreViewController.tableType = ScoreTable_SchoolRecord;
    term1ScoreViewController.scoresArray = firstArray;
    
    //Term 2
    ScoresViewController *term2ScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    term2ScoreViewController.title = @"Term II";
    term2ScoreViewController.tableType = ScoreTable_SchoolRecord;
    term2ScoreViewController.scoresArray = secondArray;
    
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
    
    isShowingInfo = NO;
    
    CGRect mainRect = viewMainContainer.frame;
    CGRect infoRect = viewAdditionalInfo.frame;
    
    mainRect.origin.y = infoRect.origin.y;
    [viewMainContainer setFrame:mainRect];
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
