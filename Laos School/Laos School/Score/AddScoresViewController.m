//
//  AddScoresViewController.m
//  Laos School
//
//  Created by HuKhong on 6/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "AddScoresViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LevelPickerViewController.h"
#import "ScoreTypeObject.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "ShareData.h"
#import "ScoreObject.h"
#import "UserScore.h"
#import "CommonDefine.h"
#import "Common.h"
#import "CommonAlert.h"

#import "SVProgressHUD.h"

@interface AddScoresViewController ()
{
    NSMutableArray *scoresArray;
    NSMutableDictionary *userScoreDict;
    NSMutableArray *searchResults;
    NSMutableArray *scoreTypesArray;
    
    ScoreTypeObject *_selectedType;
    
    LevelPickerViewController *dataPicker;
    
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
}
@end

@implementation AddScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Add scores")];
    
    UIBarButtonItem *btnSubmit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(btnSubmitClick)];
    
    self.navigationItem.rightBarButtonItems = @[btnSubmit];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
    
    
    if (scoresArray == nil) {
        scoresArray = [[NSMutableArray alloc] init];
    }
    
    if (userScoreDict == nil) {
        userScoreDict = [[NSMutableDictionary alloc] init];
    }
    
    if (scoreTypesArray == nil) {
        scoreTypesArray = [[NSMutableArray alloc] init];
    }
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    _selectedType = nil;
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadScoresData) forControlEvents:UIControlEventValueChanged];
    [studentTableView addSubview:refreshControl];
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    lbClass.text = [NSString stringWithFormat:@"%@ | %@ Term %@", classObj.className, classObj.currentYear, classObj.currentTerm];
    
    [viewClass setBackgroundColor:GREEN_COLOR];
    [viewInfo setBackgroundColor:[UIColor whiteColor]];
    [viewSubject setBackgroundColor:GREEN_COLOR];
    [viewScoreType setBackgroundColor:GREEN_COLOR];
    
    if (_selectedSubject) {
        lbSubject.text = _selectedSubject.subjectName;
        [lbSubject setTextColor:[UIColor whiteColor]];
        
    } else {
        lbSubject.text = LocalizedString(@"Select a subject");
        [lbSubject setTextColor:[UIColor lightGrayColor]];
    }
    
    lbScoreType.text = LocalizedString(@"Select a score type");
    [lbScoreType setTextColor:[UIColor lightGrayColor]];

    [self loadScoresType];
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
- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnSubmitClick {
    if ([[Common sharedCommon]networkIsActive]) {
//        if ([self validateInputs]) {
//            
//        } else {
//           
//        }
        
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
}

- (void)reloadScoresData {
//    if (selectedType.length > 0) {
//        [self loadScoresData];
//    }
}

- (void)loadScoresType {
    if ([[Common sharedCommon]networkIsActive]) {
        [SVProgressHUD show];

        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;

        [requestToServer getScoreTypeListInClass:classObj.classID];
        
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
}

- (void)loadScoresListBySubjectID:(NSString *)subjectID {
    if ([[Common sharedCommon]networkIsActive]) {
        [SVProgressHUD show];
        
        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;
        
        [requestToServer getScoresListByClassID:classObj.classID andSubjectID:subjectID];
        
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
}

#pragma mark button handle
- (IBAction)btnSubjectClick:(id)sender {
    [self showDataPicker:Picker_Subject];
}

- (IBAction)btnScoreTypeClick:(id)sender {
    [self showDataPicker:Picker_ScoreType];
}

#pragma mark data picker
- (void)showDataPicker:(PICKER_TYPE)pickerType {
    [searchBar resignFirstResponder];
    
    if (dataPicker == nil) {
        dataPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    }
    
    dataPicker.pickerType = pickerType;
    
    if (pickerType == Picker_Subject) {
        dataPicker.dataArray = _subjectsArray;
        dataPicker.selectedItem = _selectedSubject;
        
    } else if (pickerType == Picker_ScoreType) {
        dataPicker.dataArray = scoreTypesArray;
        dataPicker.selectedItem = _selectedType;
    }
    
    dataPicker.view.alpha = 0;
    
    dataPicker.delegate = (id)self;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [dataPicker.view setFrame:rect];
    
    [self.view addSubview:dataPicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        dataPicker.view.alpha = 1;
    }];
}

- (void)btnDoneClick:(id)sender withObjectReturned:(id)returnedObj {
    if (returnedObj) {
        if (dataPicker.pickerType == Picker_Subject) {
            [lbSubject setTextColor:[UIColor whiteColor]];
            SubjectObject *subjectObj = (SubjectObject *)returnedObj;
            lbSubject.text = subjectObj.subjectName;
            _selectedSubject = subjectObj;
            
            //        [self loadScoresListBySubjectID:subjectObj.subjectID];
            
        } else if (dataPicker.pickerType == Picker_ScoreType) {
            [lbScoreType setTextColor:[UIColor whiteColor]];
            ScoreTypeObject *typeObj = (ScoreTypeObject *)returnedObj;
            lbScoreType.text = typeObj.scoreName;
            _selectedType = typeObj;
            
            //        [self loadScoresListBySubjectID:subjectObj.subjectID];
        }
    }
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [searchResults count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if ([url rangeOfString:API_NAME_TEACHER_GET_EXAM_TYPE_LIST].location != NSNotFound) {
        NSArray *scoreTypeArr = [jsonObj objectForKey:@"messageObject"];
        
        if (scoreTypeArr != (id)[NSNull null]) {
            [self parseScoreTypeList:scoreTypeArr];

        }
        
    } else if ([url rangeOfString:API_NAME_TEACHER_SCORE_LIST].location != NSNotFound) {
        NSArray *scores = [jsonObj objectForKey:@"messageObject"];
        
        if (scores != (id)[NSNull null]) {
            [self parseScoreList:scores];
        }
    }
}

- (void)parseScoreTypeList:(NSArray *)scoreTypeArr {
    [scoreTypesArray removeAllObjects];
    
    for (NSDictionary *scoreTypeDict in scoreTypeArr) {
        ScoreTypeObject *scoreTypeObj = [[ScoreTypeObject alloc] init];
        
        if ([scoreTypeDict valueForKey:@"id"] != (id)[NSNull null]) {
            scoreTypeObj.typeID = [NSString stringWithFormat:@"%@", [scoreTypeDict valueForKey:@"id"]];
        }
        
        if ([scoreTypeDict valueForKey:@"ex_name"] != (id)[NSNull null]) {
            scoreTypeObj.scoreName = [scoreTypeDict valueForKey:@"ex_name"];
        }
        
        if ([scoreTypeDict valueForKey:@"ex_month"] != (id)[NSNull null]) {
            scoreTypeObj.scoreMonth = [NSString stringWithFormat:@"%@", [scoreTypeDict valueForKey:@"ex_month"]];
        }
        
        if ([scoreTypeDict valueForKey:@"ex_type"] != (id)[NSNull null]) {
            NSInteger type = [[scoreTypeDict valueForKey:@"ex_type"] integerValue];
            
            if (type == 1) {
                scoreTypeObj.scoreType = ScoreType_Normal;
                
            } else if (type == 2) {
                scoreTypeObj.scoreType = ScoreType_Exam;
                
            } else if (type == 3) {
                scoreTypeObj.scoreType = ScoreType_Average;
                
            } else if (type == 4) {
                scoreTypeObj.scoreType = ScoreType_Final;
                
            } else if (type == 5) {
                scoreTypeObj.scoreType = ScoreType_YearFinal;
                
            } else if (type == 6) {
                scoreTypeObj.scoreType = ScoreType_ExamAgain;
                
            } else if (type == 7) {
                scoreTypeObj.scoreType = ScoreType_Graduate;
            }
        }
        
        [scoreTypesArray addObject:scoreTypeObj];
    }
}

- (void)parseScoreList:(NSArray *)scores {
    [scoresArray removeAllObjects];
    [userScoreDict removeAllObjects];
    [searchResults removeAllObjects];
    
    for (NSDictionary *scoreDict in scores) {
        
        ScoreObject *scoreObj = [[ScoreObject alloc] init];
        NSString *studentID = @"";
        NSString *studentName = @"";
        NSString *nickname = @"";
        NSString *avatarLink = @"";
        
        if ([scoreDict valueForKey:@"student_id"] != (id)[NSNull null]) {
            studentID = [scoreDict valueForKey:@"student_id"];
        }
        
        if ([scoreDict valueForKey:@"student_name"] != (id)[NSNull null]) {
            studentName = [scoreDict valueForKey:@"student_name"];
        }
        
        if ([scoreDict valueForKey:@"std_nickname"] != (id)[NSNull null]) {
            nickname = [scoreDict valueForKey:@"std_nickname"];
        }
        
        if ([scoreDict valueForKey:@"std_photo"] != (id)[NSNull null]) {
            avatarLink = [scoreDict valueForKey:@"std_photo"];
        }
        
        if ([scoreDict valueForKey:@"id"] != (id)[NSNull null]) {
            scoreObj.scoreID = [scoreDict valueForKey:@"id"];
        }
        
        if ([scoreDict valueForKey:@"sresult"] != (id)[NSNull null]) {
            scoreObj.score = [scoreDict valueForKey:@"sresult"];
        }
        
        if ([scoreDict valueForKey:@"subject"] != (id)[NSNull null]) {
            scoreObj.subject = [scoreDict valueForKey:@"subject"];
        }
        
        if ([scoreDict valueForKey:@"exam_dt"] != (id)[NSNull null]) {
            scoreObj.dateTime = [scoreDict valueForKey:@"exam_dt"];
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
        
        UserScore *oldUserScoreObj = [userScoreDict objectForKey:studentID];
        
        if (oldUserScoreObj) {
            [oldUserScoreObj.scoreArray addObject:scoreObj];
            
        } else {
            UserScore *newUserScoreObj = [[UserScore alloc] init];
            
            newUserScoreObj.userID = studentID;
            newUserScoreObj.username = studentName;
            newUserScoreObj.additionalInfo = nickname;
            newUserScoreObj.avatarLink = avatarLink;
            
            [newUserScoreObj.scoreArray addObject:scoreObj];
            
            [userScoreDict setObject:newUserScoreObj forKey:studentID];
        }
    }
    
    [scoresArray addObjectsFromArray:[userScoreDict allValues]];
    
    [searchResults addObjectsFromArray:scoresArray];

    [studentTableView reloadData];
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}
@end
