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

#import "TermObject.h"
#import "UserScore.h"

#import "SVProgressHUD.h"
#import "MHTabBarController.h"

@import FirebaseAnalytics;

typedef enum {
    TabType_TermFirst = 0,
    TabType_TermSecond,
    TabType_AllYear,
    TabType_Other,
    TabType_Max
} TAB_TYPE;

@interface SchoolProfileViewController ()
{

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
    [FIRAnalytics logEventWithName:@"Open_iSchoolRecordsScreen" parameters:@{
                                                                     kFIRParameterValue:@(1)
                                                                     }];
    [self setTitle:LocalizedString(@"School records")];
    
    [self.navigationController setNavigationColor];
    
    isShowingInfo = NO;
    
    [viewHeaderContainer setBackgroundColor:[UIColor whiteColor]];
    [viewTerm setBackgroundColor:GREEN_COLOR];
    
    lbClass.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Class")];
    lbAverage1.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Term I")];
    lbAverage2.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Term II")];
    lbAverageYear.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Overall")];
    
    lbPassed.text = @"...";
    lbMorality.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Morality")];
    lbAbsence.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Absence")];
    lbTeacherComment.text = [NSString stringWithFormat:@"%@:", LocalizedString(@"Teacher's comment")];
    
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if (termPicker != nil) {
        [termPicker.view removeFromSuperview];;
    }
}

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
//    if (termPicker == nil) {
        termPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
//    }
    
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
        NSArray *scoresArr = [jsonObj objectForKey:@"messageObject"];
        
        if (scoresArr != (id)[NSNull null]) {
            [self parseSchoolRecords:scoresArr];
            
        } else {
            if (tabViewController) {
                [tabViewController.view removeFromSuperview];
            }
        }
        
        [SVProgressHUD dismiss];
    }
}

- (void)parseSchoolRecords:(NSArray *)scoresArr {
    [scoresArray removeAllObjects];
    [scoresStore removeAllObjects];
    
    if ([scoresArr count] > 0) {
        NSDictionary *scoresDict = [scoresArr objectAtIndex:0];
        
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
                NSString *studentID = @"";
                NSString *studentName = @"";
                NSString *nickname = @"";
                NSString *fullname = @"";
                NSString *avatarLink = @"";
                NSString *subjectID = @"";
                NSString *subject = @"";
                
                if ([scoreDict valueForKey:@"student_id"] != (id)[NSNull null]) {
                    studentID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"student_id"]];
                }
                
                if ([scoreDict valueForKey:@"student_name"] != (id)[NSNull null]) {
                    studentName = [scoreDict valueForKey:@"student_name"];
                }
                
                if ([scoreDict valueForKey:@"std_nickname"] != (id)[NSNull null]) {
                    nickname = [scoreDict valueForKey:@"std_nickname"];
                }
                
                if ([scoreDict valueForKey:@"std_fullname"] != (id)[NSNull null]) {
                    fullname = [scoreDict valueForKey:@"std_fullname"];
                }
                
                if ([scoreDict valueForKey:@"std_photo"] != (id)[NSNull null]) {
                    avatarLink = [scoreDict valueForKey:@"std_photo"];
                }
                
                if ([scoreDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                    subjectID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"subject_id"]];
                }
                
                if ([scoreDict valueForKey:@"subject_name"] != (id)[NSNull null]) {
                    subject = [scoreDict valueForKey:@"subject_name"];
                }
                
                UserScore *newUserScoreObj = [[UserScore alloc] init];
                
                newUserScoreObj.userID = studentID;
                newUserScoreObj.username = studentName;
                newUserScoreObj.additionalInfo = nickname;
                newUserScoreObj.displayName = fullname;
                newUserScoreObj.avatarLink = avatarLink;
                newUserScoreObj.subjectID = subjectID;
                newUserScoreObj.subject = subject;
                
                NSString *key = @"";
                for (int i = 1; i <= 20; i++) {
                    key = [NSString stringWithFormat:@"m%d", i];
                    NSString *stringScoreJson = [scoreDict objectForKey:key];
                    
                    if (stringScoreJson != (id)[NSNull null]) {
                        NSData *objectData = [stringScoreJson dataUsingEncoding:NSUTF8StringEncoding];
                        NSDictionary *score = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:nil];
                        ScoreObject *scoreObj = [[ScoreObject alloc] init];
                        /*@property (nonatomic, strong) NSString *score;
                         @property (nonatomic, strong) NSString *dateTime;
                         @property (nonatomic, strong) ScoreTypeObject *scoreTypeObj;
                         @property (nonatomic, strong) NSString *comment;*/
                        
                        if ([score valueForKey:@"sresult"] != (id)[NSNull null]) {
                            scoreObj.score = [score valueForKey:@"sresult"];
                        }
                        
                        if ([score valueForKey:@"exam_dt"] != (id)[NSNull null]) {
                            scoreObj.dateTime = [score valueForKey:@"exam_dt"];
                        }
                        
                        ScoreTypeObject *typeObj = [[ScoreTypeObject alloc] init];
                        typeObj.scoreKey = key;
                        
                        scoreObj.scoreTypeObj = typeObj;
                        
                        if ([score valueForKey:@"notice"] != (id)[NSNull null]) {
                            scoreObj.comment = [score valueForKey:@"notice"];
                        }
                        
                        [newUserScoreObj.scoreArray addObject:scoreObj];
                    } else {
                        
                        ScoreObject *scoreObj = [[ScoreObject alloc] init];
                        ScoreTypeObject *typeObj = [[ScoreTypeObject alloc] init];
                        typeObj.scoreKey = key;
                        scoreObj.scoreTypeObj = typeObj;
                        [newUserScoreObj.scoreArray addObject:scoreObj];
                    }
                }
                
                NSSortDescriptor *sortByType = [NSSortDescriptor sortDescriptorWithKey:@"scoreType" ascending:YES];
                
                [newUserScoreObj.scoreArray sortUsingDescriptors:[NSArray arrayWithObjects:sortByType, nil]];
                
                [scoresArray addObject:newUserScoreObj];
            }
            
            [self groupScoresByTermAndDisplay];
            
        } else {
            if (tabViewController) {
                [tabViewController.view removeFromSuperview];
            }
        }
    }
}

- (void)groupScoresByTermAndDisplay {
    //calculate average
    float totalFirst = 0;
    float totalSecond = 0;
    float totalFinal = 0;
    NSInteger countFirst = 0;
    NSInteger countSecond = 0;
    NSInteger countTotal = 0;

    for (UserScore *userScore in scoresArray) {
        for (ScoreObject *score in userScore.scoreArray) {
            if ([score.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_AVE_TERM1]) {
                totalFirst = totalFirst + [score.score floatValue];
                countFirst ++;
                
            } else if ([score.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_AVE_TERM2]) {
                totalSecond = totalSecond + [score.score floatValue];
                countSecond ++;
                
            } else if ([score.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_OVERALL]) {
                totalFinal = totalFinal + [score.score floatValue];
                countTotal ++;
            }
        }
    }
    
    if (countFirst > 0) {
        lbAverage1Value.text = [NSString stringWithFormat:@"%.1f", totalFirst/countFirst];
    } else {
        lbAverage1Value.text = @"0";
    }
    
    if (countSecond > 0) {
        lbAverage2Value.text = [NSString stringWithFormat:@"%.1f", totalSecond/countSecond];
    } else {
        lbAverage2Value.text = @"0";
    }
    
    if (countSecond > 0) {
        lbAverageYearValue.text = [NSString stringWithFormat:@"%.1f", totalFinal/countTotal];
    } else {
        lbAverageYearValue.text = @"0";
    }
    
    NSLog(@"Final :: %f", (totalFirst/countFirst + totalSecond/countSecond)/2);
//    lbAverageYearValue.text = [NSString stringWithFormat:@"%.1f", totalFinal/2];
    
    //display score as tabs
    tabViewController = [[MHTabBarController alloc] init];
    
    tabViewController.delegate = (id)self;
    
    ScoresViewController *allYearScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    allYearScoreViewController.title = @"Overall";
    allYearScoreViewController.tableType = ScoreTable_SchoolRecord;
    allYearScoreViewController.scoresArray = scoresArray;
    allYearScoreViewController.curTerm = TERM_VALUE_OVERALL;
    
    //term 1
    ScoresViewController *term1ScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    term1ScoreViewController.title = @"Term I";
    term1ScoreViewController.scoresArray = scoresArray;
    term1ScoreViewController.curTerm = TERM_VALUE_1;
    
    //Term 2
    ScoresViewController *term2ScoreViewController = [[ScoresViewController alloc] initWithNibName:@"ScoresViewController" bundle:nil];
    term2ScoreViewController.title = @"Term II";
    term2ScoreViewController.tableType = ScoreTable_SchoolRecord;
    term2ScoreViewController.scoresArray = scoresArray;
    term2ScoreViewController.curTerm = TERM_VALUE_2;
    
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
