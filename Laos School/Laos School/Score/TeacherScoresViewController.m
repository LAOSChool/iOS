//
//  TeacherScoresViewController.m
//  Laos School
//
//  Created by HuKhong on 3/30/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherScoresViewController.h"
#import "AppDelegate.h"
#import "LevelPickerViewController.h"
#import "AddScoresViewController.h"
#import "TeacherScoreTableViewCell.h"
#import "AddSingleScore.h"
#import "UserScore.h"
#import "ScoreObject.h"
#import "SubjectObject.h"
#import "ShareData.h"
#import "CommonDefine.h"
#import "Common.h"
#import "RequestToServer.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "CommonAlert.h"

#import "SVProgressHUD.h"

@interface TeacherScoresViewController ()
{
    BOOL isShowingViewInfo;
    NSMutableArray *subjectsArray;
    NSMutableArray *userScroreArray;
    NSMutableDictionary *userScoreDict;     //group scores by studentID
    NSMutableArray *searchResults;
    
    LevelPickerViewController *dataPicker;
    AddSingleScore *addSingleScoreView;
    SubjectObject *selectedSubject;
    
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
}
@end

@implementation TeacherScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Scores")];
    
    if (([ShareData sharedShareData].userObj.permission & Permission_AddScore) == Permission_AddScore) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewScore)];
        
        self.navigationItem.rightBarButtonItems = @[addButton];
    }
    
    isShowingViewInfo = YES;
    selectedSubject = nil;
    
    if (subjectsArray == nil) {
        subjectsArray = [[NSMutableArray alloc] init];
    }
    
    if (userScroreArray == nil) {
        userScroreArray = [[NSMutableArray alloc] init];
    }
    
    if (userScoreDict == nil) {
        userScoreDict = [[NSMutableDictionary alloc] init];
    }
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadStudentsData) forControlEvents:UIControlEventValueChanged];
    [studentTableView addSubview:refreshControl];
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;

    lbClass.text = [NSString stringWithFormat:@"%@ | %@ Term %@", classObj.className, classObj.currentYear, classObj.currentTerm];
    
    [viewTerm setBackgroundColor:GREEN_COLOR];
    [viewInfo setBackgroundColor:[UIColor whiteColor]];
    [viewSubject setBackgroundColor:GREEN_COLOR];
    
    lbSubject.text = LocalizedString(@"Select a subject");
    [lbSubject setTextColor:[UIColor lightGrayColor]];
    
    [self loadSubjectList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showScoreEdit:)
                                                 name:@"TapOnScoreCell"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadSelectedScoreList)
                                                 name:@"SubmitSingleScoreSuccessfully"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadSelectedScoreList)
                                                 name:@"NeedToRefreshScoreList"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)reloadSelectedScoreList {
    if (selectedSubject) {
        [self loadScoresListBySubjectID:selectedSubject.subjectID];
        
    }
}

- (void)reloadStudentsData {
    if (selectedSubject) {
        [self loadScoresListBySubjectID:selectedSubject.subjectID];
        
    } else {
        [self loadSubjectList];
    }
}

- (void)loadSubjectList {
    if ([[Common sharedCommon]networkIsActive]) {
        [SVProgressHUD show];
        
        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;
        
        [requestToServer getSubjectsListByClassID:classObj.classID];
        
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

- (void)addNewScore {
    AddScoresViewController *addScoresView = [[AddScoresViewController alloc] initWithNibName:@"AddScoresViewController" bundle:nil];
    addScoresView.subjectsArray = subjectsArray;
    addScoresView.selectedSubject = selectedSubject;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addScoresView];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)showScoreEdit:(NSNotification *)notification {
    UserScore *userScoreObj = (UserScore *)notification.object;
    
    if (userScoreObj) {
        ScoreObject *scoreObj = [userScoreObj.scoreArray objectAtIndex:0];
        BOOL editFlag = YES;
        
        if (scoreObj.scoreType == ScoreType_Normal ||
            scoreObj.scoreType == ScoreType_Exam ||
            scoreObj.scoreType == ScoreType_ExamAgain ||
            scoreObj.scoreType == ScoreType_Graduate) {
            
            editFlag = YES;
            
        } else {
            editFlag = NO;
        }
        
        if (addSingleScoreView == nil) {
            addSingleScoreView = [[AddSingleScore alloc] initWithNibName:@"AddSingleScore" bundle:nil];
        }
        
        addSingleScoreView.userScoreObj = userScoreObj;
        addSingleScoreView.editFlag = editFlag;
        addSingleScoreView.view.alpha = 0;
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        CGRect rect = appDelegate.window.frame;
        [addSingleScoreView.view setFrame:rect];
        
        [appDelegate.window addSubview:addSingleScoreView.view];
        
        [UIView animateWithDuration:0.3 animations:^(void) {
            addSingleScoreView.view.alpha = 1;
        }];
    }
}


#pragma mark button click
- (IBAction)btnChooseSubjectClick:(id)sender {
    [self showDataPicker:Picker_Subject];
}

#pragma mark data picker
- (void)showDataPicker:(PICKER_TYPE)pickerType {
    [searchBar resignFirstResponder];
    
    if (dataPicker == nil) {
        dataPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    }
    
    dataPicker.pickerType = pickerType;
    dataPicker.dataArray = subjectsArray;
    dataPicker.selectedItem = selectedSubject;
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
        [lbSubject setTextColor:[UIColor whiteColor]];
        SubjectObject *subjectObj = (SubjectObject *)returnedObj;
        lbSubject.text = subjectObj.subjectName;
        selectedSubject = subjectObj;
        
        [self loadScoresListBySubjectID:subjectObj.subjectID];
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
    return 210.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *teacherScoreCellIdentifier = @"TeacherScoreTableViewCell";
    
    TeacherScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:teacherScoreCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TeacherScoreTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UserScore *userScoreObject = nil;
    
    userScoreObject = [searchResults objectAtIndex:indexPath.row];
    
    cell.lbStudentName.text = userScoreObject.username;
    cell.lbAdditionalInfo.text = userScoreObject.additionalInfo;
    cell.userScoreObj = userScoreObject;
    
    if (userScoreObject.avatarLink && userScoreObject.avatarLink.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgAvatar];
        
        //load the image
        cell.imgAvatar.imageURL = [NSURL URLWithString:userScoreObject.avatarLink];
        
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self showHideHeaderView:NO];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self->searchResults removeAllObjects]; // First clear the filtered array.

    if (searchText.length == 0) {
        self->searchResults = [userScroreArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[cd] %@", searchText];

        NSArray *filterKeys = [userScroreArray filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    
    [studentTableView reloadData];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    
    NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    
    if (statusCode == HttpOK) {
        NSString *url = [jsonObj objectForKey:@"url"];
        
        if ([url rangeOfString:API_NAME_TEACHER_GET_SUBJECTS_LIST].location != NSNotFound) {
            [subjectsArray removeAllObjects];
            
            NSArray *subjects = [jsonObj objectForKey:@"messageObject"];
            
            if (subjects != (id)[NSNull null]) {
                for (NSDictionary *subjectDict in subjects) {
                    SubjectObject *subjectObj = [[SubjectObject alloc] init];
                    
                    if ([subjectDict valueForKey:@"id"] != (id)[NSNull null]) {
                        subjectObj.subjectID = [NSString stringWithFormat:@"%@", [subjectDict valueForKey:@"id"]];
                    }
                    
                    if ([subjectDict valueForKey:@"sval"] != (id)[NSNull null]) {
                        subjectObj.subjectName = [subjectDict valueForKey:@"sval"];
                    }
                    
                    [subjectsArray addObject:subjectObj];
                }
                
                if (selectedSubject) {
                    [self loadScoresListBySubjectID:selectedSubject.subjectID];
                    
                }
            }
            
        } else if ([url rangeOfString:API_NAME_TEACHER_SCORE_LIST].location != NSNotFound) {
            [userScroreArray removeAllObjects];
            [userScoreDict removeAllObjects];
            [searchResults removeAllObjects];
            
            NSArray *scores = [jsonObj objectForKey:@"messageObject"];
            /*{
             "class_id" = 1;
             "exam_dt" = "<null>";
             "exam_id" = 1;
             "exam_month" = 9;
             "exam_name" = "Normal exam";
             "exam_type" = 1;
             "exam_year" = "<null>";
             id = "<null>";
             notice = BLANK;
             "sch_year_id" = 1;
             "school_id" = 1;
             sresult = "<null>";
             "std_nickname" = "Student 10";
             "std_photo" = "http://192.168.0.202:9090/eschool_content/avatar/student1.png";
             "student_id" = 10;
             "student_name" = 00000010;
             subject = Ly;
             "subject_id" = 2;
             teacher = "<null>";
             "teacher_id" = "<null>";
             term = "HK 1";
             "term_id" = 1;
             "term_val" = 1;
             }*/
            if (scores != (id)[NSNull null]) {
                for (NSDictionary *scoreDict in scores) {
                    
                    ScoreObject *scoreObj = [[ScoreObject alloc] init];
                    NSString *studentID = @"";
                    NSString *studentName = @"";
                    NSString *nickname = @"";
                    NSString *avatarLink = @"";
                    
                    if ([scoreDict valueForKey:@"student_id"] != (id)[NSNull null]) {
                        studentID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"student_id"]];
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
                        scoreObj.scoreID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"id"]];
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
                
                [userScroreArray addObjectsFromArray:[userScoreDict allValues]];
                
                [searchResults addObjectsFromArray:userScroreArray];
            }
            
            [studentTableView reloadData];
        }
    } else {
        [self failToGetInfo];
    }
}

- (void)failToGetInfo {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There is an error while trying to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
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

#pragma mark show hide header
- (void)showHideHeaderView:(BOOL)flag {
    if (flag == YES) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            CGRect headerRect = viewHeader.frame;
            CGRect tableRect = viewTableView.frame;
            
            headerRect.origin.y = 0;
            [viewHeader setFrame:headerRect];
            
            tableRect.origin.y = headerRect.size.height;
            tableRect.size.height = self.view.frame.size.height - headerRect.size.height;
            [viewTableView setFrame:tableRect];
            
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^(void) {
            CGRect headerRect = viewHeader.frame;
            CGRect tableRect = viewTableView.frame;
            
            headerRect.origin.y = 0 - headerRect.size.height;
            [viewHeader setFrame:headerRect];
            
            tableRect.origin.y = 0;
            tableRect.size.height = self.view.frame.size.height;
            [viewTableView setFrame:tableRect];
            
        }];
    }
}

- (IBAction)panGestureHandle:(id)sender {
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
    
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (velocity.y > VERLOCITY) {
        [self showHideHeaderView:YES];
    } else if (velocity.y < - VERLOCITY) {
        [self showHideHeaderView:NO];
    }
}
@end
