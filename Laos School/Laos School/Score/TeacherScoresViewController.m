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
#import "ScoreObject.h"

#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"

@interface TeacherScoresViewController ()
{
    BOOL isShowingViewInfo;
    NSMutableArray *studentsArray;
    NSMutableArray *searchResults;
    
    LevelPickerViewController *dataPicker;
}
@end

@implementation TeacherScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Scores")];
    
    isShowingViewInfo = YES;
    
    if (studentsArray == nil) {
        studentsArray = [[NSMutableArray alloc] init];
    }
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
#if 0
    //for test
    UserScore *userScore = [[UserScore alloc] init];
    userScore.userID = @"1";
    userScore.username = @"Nguyen Thi Nga";
    userScore.averageScore = @"9";
    
    ScoreObject *scoreObj1 = [[ScoreObject alloc] init];
    scoreObj1.scoreID = @"1";
    scoreObj1.scoreType = @"He so 1";
    scoreObj1.score = @"9";
    scoreObj1.weight = 1;
    
    [userScore.scoreArray addObject:scoreObj1];
    
    //score 2
    ScoreObject *scoreObj2 = [[ScoreObject alloc] init];
    scoreObj2.scoreID = @"2";
    scoreObj2.scoreType = @"He so 1";
    scoreObj2.score = @"10";
    scoreObj1.weight = 1;
    
    [userScore.scoreArray addObject:scoreObj2];
    
    //score 3
    ScoreObject *scoreObj3 = [[ScoreObject alloc] init];
    scoreObj3.scoreID = @"3";
    scoreObj3.scoreType = @"He so 2";
    scoreObj3.score = @"9";
    scoreObj3.weight = 2;
    
    [userScore.scoreArray addObject:scoreObj3];
    
    //score 4
    ScoreObject *scoreObj4 = [[ScoreObject alloc] init];
    scoreObj4.scoreID = @"4";
    scoreObj4.scoreType = @"Final exam";
    scoreObj4.score = @"9";
    scoreObj4.weight = 3;
    
    [userScore.scoreArray addObject:scoreObj4];
    
    [studentsArray addObject:userScore];
    
    [searchResults addObjectsFromArray:studentsArray];
#endif
    
    
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

#pragma mark show pick
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


#pragma mark button click
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
    dataPicker.view.alpha = 0;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [dataPicker.view setFrame:rect];
    
    [self.view addSubview:dataPicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        dataPicker.view.alpha = 1;
    }];
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
    
    [studentTableView reloadData];
}
@end
