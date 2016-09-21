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
#import "AddScoreTableViewCell.h"
#import "AddCommentView.h"
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

@import FirebaseAnalytics;

#define NOTE_WIDTH 250
#define NOTE_HEIGHT 250

@interface AddScoresViewController ()
{
    NSMutableArray *scoresArray;    //store usersocre corresponding to a specific score type
//    NSMutableDictionary *userScoreDict; //store userscore corresponding to a specific subject

    NSMutableArray *searchResults;
    NSMutableArray *scoreTypesArray;
    
    ScoreTypeObject *_selectedType;
    
    LevelPickerViewController *dataPicker;
    
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
    
    AddCommentView *addCommentView;
    
    BOOL keyBoardFlag;
}
@end

@implementation AddScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Add scores")];
    
    UIBarButtonItem *btnSubmit = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Submit") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(btnSubmitClick)];
    
    self.navigationItem.rightBarButtonItems = @[btnSubmit];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
    
    
    if (scoresArray == nil) {
        scoresArray = [[NSMutableArray alloc] init];
    }
    
//    if (userScoreDict == nil) {
//        userScoreDict = [[NSMutableDictionary alloc] init];
//    }
    
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
    
//    refreshControl = [[UIRefreshControl alloc] init];
//    [refreshControl addTarget:self action:@selector(reloadScoresData) forControlEvents:UIControlEventValueChanged];
//    [studentTableView addSubview:refreshControl];
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    lbClass.text = [NSString stringWithFormat:@"%@ | %@ %@ %@", classObj.className, classObj.currentYear, LocalizedString(@"Term"), classObj.currentTerm];
    
    [viewClass setBackgroundColor:GREEN_COLOR];
    [viewInfo setBackgroundColor:[UIColor whiteColor]];
    [viewSubject setBackgroundColor:GREEN_COLOR];
    [viewScoreType setBackgroundColor:GREEN_COLOR];
    
    if (_selectedSubject) {
        lbSubject.text = _selectedSubject.subjectName;
        [lbSubject setTextColor:[UIColor whiteColor]];
        
        [self loadScoresListBySubjectID:_selectedSubject.subjectID];
        
    } else {
        lbSubject.text = LocalizedString(@"Select a subject");
        [lbSubject setTextColor:[UIColor lightGrayColor]];
    }
    
    lbScoreType.text = LocalizedString(@"Select a score type");
    [lbScoreType setTextColor:[UIColor lightGrayColor]];

    [self loadScoresType];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification {
    keyBoardFlag = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    keyBoardFlag = NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        if (addCommentView != nil && addCommentView.isShowing == YES) {
            CGRect rect = addCommentView.frame;
            
            rect.origin.x = (size.width - NOTE_WIDTH)/2;
            rect.origin.y = (size.height - NOTE_HEIGHT)/2 - 60;
            
            [addCommentView setFrame:rect];
        }
    }];
    
    if (dataPicker != nil) {
        [dataPicker.view removeFromSuperview];;
    }
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

- (void)cancelButtonClick {
    if (_selectedType) {
        if (self.navigationItem.rightBarButtonItem.enabled == YES) {
            [self confirmCancelAddScore];
            
        } else {
        
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedToRefreshScoreList" object:nil];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
        
    } else {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)btnSubmitClick {
    [self dismissKeyboard];
    
    if ([self validateInputs]) {
        [self confirmBeforeSubmitScore];
    }
}


- (BOOL)validateInputs {
    BOOL res = YES;
    NSInteger count = 0;
    for (UserScore *userScore in scoresArray) {
        ScoreObject *scoreObj = nil;
        
        for (ScoreObject *score in userScore.scoreArray) {
            if ([score.scoreTypeObj.scoreKey isEqualToString:_selectedType.scoreKey]) {
                scoreObj = score;
                break;
            }
        }
        
        if (scoreObj) {
            NSString *score  = scoreObj.score;
            
            if (score == nil || score.length == 0) {
                res = NO;
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count inSection:0];
                
                [studentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                AddScoreTableViewCell *cell = [studentTableView cellForRowAtIndexPath:indexPath];
                [cell.txtScore becomeFirstResponder];
                
                [self incompleteFillingScore];
                break;
            }
            
            count++;
        }
    }
    
    return res;
}

- (void)submitScoresToServer {
    [SVProgressHUD show];
    
    NSMutableArray *scoresArr = [[NSMutableArray alloc] init];
    //create scores json

    for (UserScore *userScore in scoresArray) {
        if ([userScore.scoreArray count] > 0) {
            NSMutableDictionary *scoreDict = [[NSMutableDictionary alloc] init];
            ScoreObject *scoreObj = nil;
            
            for (ScoreObject *score in userScore.scoreArray) {
                if ([score.scoreTypeObj.scoreKey isEqualToString:_selectedType.scoreKey]) {
                    scoreObj = score;
                    break;
                }
            }
            
            [scoreDict setValue:[[ShareData sharedShareData] userObj].shoolID forKey:@"school_id"];
            [scoreDict setValue:[[ShareData sharedShareData] userObj].classObj.classID forKey:@"class_id"];
            [scoreDict setValue:userScore.userID forKey:@"student_id"];
            [scoreDict setValue:userScore.subjectID forKey:@"subject_id"];
            
            NSMutableDictionary *scoreValueDict = [[NSMutableDictionary alloc] init];
            
            [scoreValueDict setValue:scoreObj.comment forKey:@"notice"];
            [scoreValueDict setValue:scoreObj.score forKey:@"sresult"];
            
            NSString *dateTime = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeWithFormat:COMMON_DATE_FORMATE];
            [scoreValueDict setValue:dateTime forKey:@"exam_dt"];
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:scoreValueDict options:0 error:nil];
            NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            [scoreDict setValue:myString forKey:scoreObj.scoreTypeObj.scoreKey];
            
            [scoresArr addObject:scoreDict];
        }
    }

    if ([scoresArr count] > 0) {
        [requestToServer submitMultipleScoresWithObject:scoresArr];
        
        [FIRAnalytics logEventWithName:@"submit_multi_score" parameters:@{
                                                                           kFIRParameterValue:@(1)
                                                                           }];
    }
    
    
}

- (void)reloadScoresData {
    if (_selectedType == nil) {
        [self loadScoresType];
        
    } else {
        if (_selectedSubject) {
            [self loadScoresListBySubjectID:_selectedSubject.subjectID];
        } else {
            [refreshControl endRefreshing];
        }
    }
}

- (void)loadScoresType {
    if ([[Common sharedCommon]networkIsActive]) {
        [SVProgressHUD show];

        [requestToServer getScoreTypeList];
        
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
    
//    if (dataPicker == nil) {
        dataPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
//    }
    
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
            
            [self loadScoresListBySubjectID:subjectObj.subjectID];
            
        } else if (dataPicker.pickerType == Picker_ScoreType) {
            [lbScoreType setTextColor:[UIColor whiteColor]];
            ScoreTypeObject *typeObj = (ScoreTypeObject *)returnedObj;
            
            if (typeObj) {
                lbScoreType.text = typeObj.scoreName;
                _selectedType = typeObj;
                
                if ([scoresArray count] > 0) {
                    [searchBar resignFirstResponder];
                    searchBar.text = @"";
                    [searchResults removeAllObjects];
                    [searchResults addObjectsFromArray:scoresArray];

                    [self resizeTableView];
                
                    [studentTableView reloadData];
                }
            }
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
    if (_selectedType) {
        return [searchResults count];
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *addScoreCellIdentifier = @"AddScoreTableViewCell";
    
    AddScoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:addScoreCellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AddScoreTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.delegate = (id)self;
    
    UserScore *userScoreObject = [searchResults objectAtIndex:indexPath.row];
    ScoreObject *scoreObj = nil;
    
    for (ScoreObject *score in userScoreObject.scoreArray) {
        if ([score.scoreTypeObj.scoreKey isEqualToString:_selectedType.scoreKey]) {
            scoreObj = score;
            break;
        }
    }
    
    cell.scoreKey = _selectedType.scoreKey;
    cell.userScore = userScoreObject;
    cell.lbStudentName.text = userScoreObject.displayName;
    cell.lbAdditionalInfo.text = userScoreObject.additionalInfo;

    cell.txtScore.text =  scoreObj.score;
    
    cell.imgAvatar.image = [UIImage imageNamed:@"ic_user_gray.png"];
    
    if (userScoreObject.avatarLink && userScoreObject.avatarLink.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgAvatar];
        
        //load the image
        cell.imgAvatar.imageURL = [NSURL URLWithString:userScoreObject.avatarLink];
        
    } else {
        cell.imgAvatar.image = [UIImage imageNamed:@"ic_user_gray.png"];
    }
    
    return cell;
}

- (void)inputScoreTo:(id)sender withValueReturned:(NSString *)value {

}

- (void)textFieldDidBegin:(id)sender {
    AddScoreTableViewCell *cell = (AddScoreTableViewCell *)sender;
//    NSIndexPath *indexPath = [studentTableView indexPathForCell:cell];
//    
//    [studentTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    CGRect rect = cell.frame;
    rect.origin.y = 0;
    
    [scrollView scrollRectToVisible:rect animated:YES];
}

- (void)txtScoreChanged:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)btnCommentClick:(id)sender {
    AddScoreTableViewCell *cell = (AddScoreTableViewCell *)sender;
    [self displayCommentView:cell.userScore];
    
    //dismiss keyboard
    AddScoreTableViewCell *c = nil;
    for (int i = 0; i < [searchResults count]; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
        
        c = [studentTableView cellForRowAtIndexPath:index];
        [c.txtScore resignFirstResponder];
    }
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    AddScoreTableViewCell *cell = nil;
    for (int i = 0; i < [searchResults count]; i++) {
        NSIndexPath *index = [NSIndexPath indexPathForItem:i inSection:0];
        
        cell = [studentTableView cellForRowAtIndexPath:index];
        [cell.txtScore resignFirstResponder];
    }
    
    
    [searchBar resignFirstResponder];
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
    [self btnCloseClick];
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchText.length == 0) {
        self->searchResults = [scoresArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[cd] %@", searchText];
        
        NSArray *filterKeys = [scoresArray filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    
    [studentTableView reloadData];
    
    CGSize size = scrollView.contentSize;
    if (keyBoardFlag) {
        size.height = [searchResults count]*44 + 232; //232: keyboard height;
    } else {
        size.height = [searchResults count]*44;
    }
    scrollView.contentSize = size;
    
    CGRect rect = studentTableView.frame;
    rect.size.height = [searchResults count]*44;
    studentTableView.frame = rect;
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [refreshControl endRefreshing];
    
    NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if (statusCode == HttpOK) {        
        if ([url rangeOfString:API_NAME_TEACHER_GET_EXAM_TYPE_LIST].location != NSNotFound) {
            NSArray *scoreTypeArr = [jsonObj objectForKey:@"messageObject"];
            
            if (scoreTypeArr != (id)[NSNull null]) {
                [self parseScoreTypeList:scoreTypeArr];

            }
            
            [SVProgressHUD dismiss];
            //API_NAME_TEACHER_ADD_MULTIPLE_SCORE must put before API_NAME_TEACHER_SCORE_LIST
        } else if ([url rangeOfString:API_NAME_TEACHER_ADD_MULTIPLE_SCORE].location != NSNotFound) {
            [SVProgressHUD showSuccessWithStatus:LocalizedString(@"Successfully")];
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
        } else if ([url rangeOfString:API_NAME_TEACHER_SCORE_LIST].location != NSNotFound) {
            NSArray *scores = [jsonObj objectForKey:@"messageObject"];
            
            if (scores != (id)[NSNull null]) {
                [self parseScoreList:scores];
            }
            
            [SVProgressHUD dismiss];
        }
        
    } else {
        [SVProgressHUD dismiss];
        if ([url rangeOfString:API_NAME_TEACHER_ADD_MULTIPLE_SCORE].location != NSNotFound) {
            [self submitScoreFailed];
            
        } else {
            [self failToGetInfo];
        }
    }
}

- (void)parseScoreTypeList:(NSArray *)scoreTypeArr {
    [scoreTypesArray removeAllObjects];

    for (NSDictionary *scoreTypeDict in scoreTypeArr) {
        ScoreTypeObject *scoreTypeObj = [[ScoreTypeObject alloc] init];
        
        if ([scoreTypeDict valueForKey:@"ex_key"] != (id)[NSNull null]) {
            scoreTypeObj.scoreKey = [scoreTypeDict valueForKey:@"ex_key"];
            
            if ([scoreTypeDict valueForKey:@"term_val"] != (id)[NSNull null]) {
                NSString *term = [NSString stringWithFormat:@"%@", [scoreTypeDict valueForKey:@"term_val"]];
                UserObject *userObj = [[ShareData sharedShareData] userObj];
                ClassObject *classObj = userObj.classObj;
                
                if ([term isEqualToString:classObj.currentTerm]) {
                    if (scoreTypeObj.scoreType == ScoreType_Normal ||
                        scoreTypeObj.scoreType == ScoreType_Exam ||
                        scoreTypeObj.scoreType == ScoreType_ExamAgain ||
                        scoreTypeObj.scoreType == ScoreType_Graduate) {
                        
                        [scoreTypesArray addObject:scoreTypeObj];
                    }
                }
            }
        }
    }
    
    NSSortDescriptor *sortTypeDes = [NSSortDescriptor sortDescriptorWithKey:@"scoreType" ascending:YES];
    [scoreTypesArray sortUsingDescriptors:[NSArray arrayWithObjects:sortTypeDes, nil]];
}

- (void)parseScoreList:(NSArray *)scores {
    [scoresArray removeAllObjects];
//    [userScoreDict removeAllObjects];
    [searchResults removeAllObjects];

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
    
    NSSortDescriptor *sortByName = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    
    [scoresArray sortUsingDescriptors:[NSArray arrayWithObjects:sortByName, nil]];
    
    [searchResults addObjectsFromArray:scoresArray];

    if (_selectedType && [searchResults count] > 0) {
        [self resizeTableView];
        [studentTableView reloadData];
    }
}

//call this function whenever changing scoresArray
- (void)resizeTableView {
    [self btnCloseClick];
    
//    if ([scoresArray count] > 0) {
//        self.navigationItem.rightBarButtonItem.enabled = YES;
//    } else {
//        self.navigationItem.rightBarButtonItem.enabled = NO;
//    }
    
    CGSize size = scrollView.contentSize;
    if (keyBoardFlag) {
        size.height = [searchResults count]*44 + 232; //232: keyboard height;
    } else {
        size.height = [searchResults count]*44;
    }
    scrollView.contentSize = size;
    
    CGRect rect = studentTableView.frame;
    rect.size.height = [scoresArray count]*44;
    studentTableView.frame = rect;
    
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

#pragma add comment
- (void)displayCommentView:(UserScore *)userScore {
    CGRect rect;
    CGRect webRect = self.view.frame;
    rect.size.width = NOTE_WIDTH;
    rect.size.height = NOTE_HEIGHT;
    
    rect.origin.x = (webRect.size.width - NOTE_WIDTH)/2;
    
    rect.origin.y = (webRect.size.height - NOTE_HEIGHT)/2 - 60; //60 :: to move the save button from the keyboard
    
    if (addCommentView == nil) {

        addCommentView = [[AddCommentView alloc] initWithFrame:rect];
        addCommentView.delegate = (id)self;
        addCommentView.scoreKey = _selectedType.scoreKey;   //must pass this scorekey prior to userScore
        addCommentView.userScore = userScore;
        [addCommentView setAlpha:0];
        [self.view addSubview:addCommentView];
        
    } else {
        addCommentView.scoreKey = _selectedType.scoreKey;   //must pass this scorekey prior to userScore
        addCommentView.userScore = userScore;
        [addCommentView setFrame:rect];
        [self.view addSubview:addCommentView];
    }
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        [addCommentView setAlpha:1];
    }];
}

- (void)btnCloseClick {
    if (addCommentView) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            [addCommentView setAlpha:0];
            
        } completion:^(BOOL finished) {
            [addCommentView removeFromSuperview];
            [addCommentView setAlpha:1];
        }];
    }
}

- (void)btnSaveClick {
    if (addCommentView) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            [addCommentView setAlpha:0];
            
        } completion:^(BOOL finished) {
            [addCommentView removeFromSuperview];
            [addCommentView setAlpha:1];
        }];
        
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

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
    
    if ([searchResults count] > 0) {
        CGSize size = scrollView.contentSize;
        if (keyBoardFlag) {
            size.height = [searchResults count]*44 + 232; //232: keyboard height;
        } else {
            size.height = [searchResults count]*44;
        }
        scrollView.contentSize = size;
        
        CGRect rect = studentTableView.frame;
        rect.size.height = [searchResults count]*44;
        studentTableView.frame = rect;
    }
}

- (IBAction)swipeUpHandle:(id)sender {
    [self showHideHeaderView:NO];
}

- (IBAction)swipeDownHandle:(id)sender {
    [self showHideHeaderView:YES];
}


- (IBAction)panGestureHandle:(id)sender {
    if (dataPicker.view.alpha == 0 && (addCommentView == nil || addCommentView.alpha == 0)) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)sender;
        
        CGPoint velocity = [recognizer velocityInView:self.view];
        
        if (velocity.y > VERLOCITY) {
            [self showHideHeaderView:YES];
        } else if (velocity.y < - VERLOCITY) {
            [self showHideHeaderView:NO];
        }
    }
}

#pragma mark alert
- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)confirmBeforeSubmitScore {
    NSString *content = LocalizedString(@"Please double check information before you submit scores. Are you sure?");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Confirmation") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
    alert.tag = 2;
    
    [alert show];
}

- (void)incompleteFillingScore {
    NSString *content = LocalizedString(@"You do not complete filling scores. Submit now?");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Attention") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)confirmCancelAddScore {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Confirmation") message:LocalizedString(@"Are you sure you want to cancel?") delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
    alert.tag = 4;
    
    [alert show];
}

- (void)failToGetInfo {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while trying to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}

- (void)submitScoreFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while submitting scores. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 6;
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 2 ||       //confirmBeforeSubmitScore
        alertView.tag == 3) {       //incompleteFillingScore
        
        if (buttonIndex != 0) {
            
            if ([[Common sharedCommon]networkIsActive]) {
                [self submitScoresToServer];
                
            } else {
                [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
            }
        }
        
    } else if (alertView.tag == 4) {    //confirmCancelAddScore
        if (buttonIndex != 0) {
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}
@end
