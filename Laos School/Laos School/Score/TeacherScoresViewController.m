//
//  TeacherScoresViewController.m
//  Laos School
//
//  Created by HuKhong on 3/30/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherScoresViewController.h"
#import "LevelPickerViewController.h"
#import "TeacherScoresTableViewCell.h"
#import "UserScore.h"
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
    NSMutableArray *searchResults;
    
    LevelPickerViewController *dataPicker;
    
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
    
    isShowingViewInfo = YES;
    
    if (subjectsArray == nil) {
        subjectsArray = [[NSMutableArray alloc] init];
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

- (void)reloadStudentsData {

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
    //    [SVProgressHUD show];

        UserObject *userObj = [[ShareData sharedShareData] userObj];
        ClassObject *classObj = userObj.classObj;
        
   //     [requestToServer getScoresListByClassID:classObj.classID andSubjectID:subjectID];
        
    } else {
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
}


#pragma mark button click
- (IBAction)btnChooseClassClick:(id)sender {
    [self showDataPicker:Picker_Classes];
}

- (IBAction)btnChooseSubjectClick:(id)sender {
    [self showDataPicker:Picker_Subject];
}

- (IBAction)btnShowListClick:(id)sender {
    isShowingViewInfo = NO;
    [self showHideInfoView:isShowingViewInfo];
}

- (IBAction)btnExpandClick:(id)sender {
    isShowingViewInfo = !isShowingViewInfo;
    [self showHideInfoView:isShowingViewInfo];
    
    
}

- (void)showHideInfoView:(BOOL)showHideFlag {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        CGRect rectViewTerm = viewTerm.frame;
        CGRect rectViewInfo = viewInfo.frame;
        CGRect rectViewTableView = viewTableView.frame;
        
        if (showHideFlag) {
            rectViewInfo.origin.y = rectViewTerm.size.height + 2;
            
            [viewInfo setFrame:rectViewInfo];
            
            rectViewTableView.origin.y = rectViewInfo.origin.y + rectViewInfo.size.height;
            rectViewTableView.size.height = self.view.frame.size.height - rectViewTableView.origin.y;
            
            [viewTableView setFrame:rectViewTableView];
            
        } else {
            rectViewInfo.origin.y = rectViewTerm.size.height - rectViewInfo.size.height;
            
            [viewInfo setFrame:rectViewInfo];
            
            rectViewTableView.origin.y = rectViewTerm.origin.y + rectViewTerm.size.height;
            rectViewTableView.size.height = self.view.frame.size.height - rectViewTableView.origin.y;
            
            [viewTableView setFrame:rectViewTableView];
            
        }
    }];
}

#pragma mark data picker
- (void)showDataPicker:(PICKER_TYPE)pickerType {
    dataPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    dataPicker.pickerType = pickerType;
    dataPicker.dataArray = subjectsArray;
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
    [lbSubject setTextColor:[UIColor whiteColor]];
    SubjectObject *subjectObj = (SubjectObject *)returnedObj;
    lbSubject.text = subjectObj.subjectName;
    
    [self loadScoresListBySubjectID:subjectObj.subjectID];
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
    return 100.0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//    NSString *headerTitle = @"";
//    headerTitle = [NSString stringWithFormat:@"%@: %lu", LocalizedString(@"Count"), (unsigned long)[_selectedArray count]];
//
//    return headerTitle;
//}
//
//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//
//    header.textLabel.textColor = [UIColor grayColor];
//    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
//    CGRect headerFrame = header.frame;
//    header.textLabel.frame = headerFrame;
//    header.textLabel.textAlignment = NSTextAlignmentLeft;
//
//    header.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *teacherScoresCellIdentifier = @"TeacherScoresCellIdentifier";
    
    TeacherScoresTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:teacherScoresCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"TeacherScoresTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UserScore *userScoreObject = nil;
    
    userScoreObject = [searchResults objectAtIndex:indexPath.row];
    
    cell.lbFullname.text = userScoreObject.username;
    cell.lbAdditionalInfo.text = userScoreObject.additionalInfo;

    NSMutableDictionary *scoreGroupedByType = [[NSMutableDictionary alloc] init];
    NSArray *keyArr = nil;
    
//    for (ScoreObject *scoreObject in userScoreObject.scoreArray) {
//        NSMutableArray *arr = [scoreGroupedByType objectForKey:scoreObject.scoreType];
//        
//        if (arr == nil) {
//            arr = [[NSMutableArray alloc] init];
//        }
//        [arr addObject:scoreObject.score];
//        
//        [scoreGroupedByType setObject:arr forKey:scoreObject.scoreType];
//    }
    
    keyArr = [scoreGroupedByType allKeys];
    keyArr = [keyArr sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

    NSString *score1 = @"";
    NSString *score2 = @"";
    NSString *finalTest = @"";
    
    for (int i = 0; i < [keyArr count]; i++) {
        NSString *key = [keyArr objectAtIndex:i];
        
        if (i == 0) {
            score1 = [NSString stringWithFormat:@"%@: ",key];
            
            for (NSString *score in [scoreGroupedByType objectForKey:key]) {
                score1 = [score1 stringByAppendingFormat:@"%@   ", score];
            }
            
        } else if (i == 1) {
            score2 = [NSString stringWithFormat:@"%@: ",key];
            
            for (NSString *score in [scoreGroupedByType objectForKey:key]) {
                score2 = [score2 stringByAppendingFormat:@"%@   ", score];
            }
            
        } else if (i == 2) {
            finalTest = [NSString stringWithFormat:@"%@: ",key];
            
            for (NSString *score in [scoreGroupedByType objectForKey:key]) {
                finalTest = [finalTest stringByAppendingFormat:@"%@   ", score];
            }
        }
    }
    
    cell.lbScore1.text = score1;
    cell.lbScore2.text = score2;
    cell.lbScoreFinalTest.text = finalTest;
    cell.lbAverage.text = userScoreObject.averageScore;

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


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self->searchResults removeAllObjects]; // First clear the filtered array.
   /*
    if (searchText.length == 0) {
        self->searchResults = [studentsArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[cd] %@", searchText];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [studentsArray filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    
    [studentTableView reloadData];*/
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if ([url rangeOfString:API_NAME_TEACHER_GET_SUBJECTS_LIST].location != NSNotFound) {
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
        }
    } else {
        
    }
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
