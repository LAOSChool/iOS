//
//  TeacherScoresViewController.m
//  Laos School
//
//  Created by HuKhong on 3/30/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherScoresViewController.h"
#import "LevelPickerViewController.h"
#import "StudentsListTableViewCell.h"
#import "UserObject.h"

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
    return 50.0;
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
    
    static NSString *studentsListAttandanceCellIdentifier = @"StudentsListCellIdentifier";
    
    StudentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsListAttandanceCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentsListTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UserObject *userObject = nil;
    
    userObject = [searchResults objectAtIndex:indexPath.row];
    
    cell.lbFullname.text = userObject.username;
    cell.lbAdditionalInfo.text = userObject.nickName;
    
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
