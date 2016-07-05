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
    NSMutableArray *searchResults;
    
    LevelPickerViewController *dataPicker;
    AddSingleScore *addSingleScoreView;
    SubjectObject *selectedSubject;
    
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
    
    BOOL isVisible;
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
    
    isVisible = NO;
    isShowingViewInfo = YES;
    selectedSubject = nil;
    
    if (subjectsArray == nil) {
        subjectsArray = [[NSMutableArray alloc] init];
    }
    
    if (userScroreArray == nil) {
        userScroreArray = [[NSMutableArray alloc] init];
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

    lbClass.text = [NSString stringWithFormat:@"%@ | %@ %@ %@", classObj.className, classObj.currentYear, LocalizedString(@"Term"), classObj.currentTerm];
    
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
- (void)viewDidAppear:(BOOL)animated {
    isVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    isVisible = NO;
}

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
    NSDictionary *passedObj = (NSDictionary *)notification.object;
    UserScore *userScoreObj = [passedObj objectForKey:@"UserScoreObj"];
    ScoreObject *scoreObj = [passedObj objectForKey:@"ScoreObj"];
    
    if (isVisible) {
        if (userScoreObj) {
            BOOL editFlag = YES;
            
            if (scoreObj.scoreTypeObj.scoreType == ScoreType_Normal ||
                scoreObj.scoreTypeObj.scoreType == ScoreType_Exam ||
                scoreObj.scoreTypeObj.scoreType == ScoreType_ExamAgain ||
                scoreObj.scoreTypeObj.scoreType == ScoreType_Graduate) {
                
                editFlag = YES;
                
            } else {
                editFlag = NO;
            }
            
            if (addSingleScoreView == nil) {
                addSingleScoreView = [[AddSingleScore alloc] initWithNibName:@"AddSingleScore" bundle:nil];
            }
            
            addSingleScoreView.scoreObj = scoreObj;
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
    
    if (IS_IPAD) {
        return 175.0;
    }

    if ([[[[ShareData sharedShareData] userObj] classObj].currentTerm isEqualToString:TERM_VALUE_1]) {
        return 155.0;
        
    } else {
        return 210.0;
    }
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
    
    if (IS_IPAD) {
        CGRect rect = cell.contentView.frame;
        rect.size.width = self.view.frame.size.width;
        
        [cell.contentView setFrame:rect];
    }
    
    cell.curTerm = [[[ShareData sharedShareData] userObj] classObj].currentTerm;
    
    UserScore *userScoreObject = nil;
    
    userScoreObject = [searchResults objectAtIndex:indexPath.row];
    
    cell.lbStudentName.text = userScoreObject.displayName;
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
    if (!IS_IPAD) {
        [self showHideHeaderView:NO];
    }
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
            [searchResults removeAllObjects];
            
            NSArray *scores = [jsonObj objectForKey:@"messageObject"];
            /**/
            if (scores != (id)[NSNull null]) {
                for (NSDictionary *scoreDict in scores) {
                    /*{
                     "class_id" = "<null>";
                     id = 8;
                     m1 = "<null>";
                     m10 = "<null>";
                     m11 = "<null>";
                     m12 = "<null>";
                     m13 = "<null>";
                     m14 = "<null>";
                     m15 = "<null>";
                     m16 = "<null>";
                     m17 = "<null>";
                     m18 = "<null>";
                     m19 = "<null>";
                     m2 = "<null>";
                     m20 = "<null>";
                     m3 = "<null>";
                     m4 = "<null>";
                     m5 = "<null>";
                     m6 = "<null>";
                     m7 = "<null>";
                     m8 = "<null>";
                     m9 = "<null>";
                     notice = "<null>";
                     "sch_year_id" = 2;
                     "school_id" = 1;
                     "std_nickname" = "Student 11";
                     "std_photo" = "http://192.168.0.202:9090/eschool_content/avatar/student2.png";
                     "student_id" = 11;
                     "student_name" = 00000011;
                     "subject_id" = 1;
                     "subject_name" = Toan;
                     }
                     @property (nonatomic, strong) NSString *userID;
                     @property (nonatomic, strong) NSString *username;
                     @property (nonatomic, strong) NSString *displayName;
                     @property (nonatomic, strong) NSString *additionalInfo;
                     @property (nonatomic, strong) NSString *avatarLink;
                     @property (nonatomic, strong) NSMutableArray *scoreArray;
                     @property (nonatomic, strong) NSString *subjectID;
                     @property (nonatomic, strong) NSString *subject;*/

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
                    
                    [userScroreArray addObject:newUserScoreObj];
                }
                
                NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
                
                [userScroreArray sortUsingDescriptors:[NSArray arrayWithObjects:sortByName, nil]];

                [searchResults addObjectsFromArray:userScroreArray];
            }
            
            [studentTableView reloadData];
        }
    } else {
        [self failToGetInfo];
    }
}

- (void)failToGetInfo {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while trying to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
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
    if (dataPicker.view.alpha == 0) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        if (velocity.y > VERLOCITY) {
            [self showHideHeaderView:YES];
        } else if (velocity.y < - VERLOCITY) {
            [self showHideHeaderView:NO];
        }
    }
}

- (void)dealloc {
    requestToServer.delegate = nil;
    dataPicker.delegate = nil;
}
@end
