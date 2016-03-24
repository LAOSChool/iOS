//
//  StudentsListViewController.m
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentsListViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "StudentsListTableViewCell.h"
#import "UserObject.h"
#import "ClassObject.h"

@interface StudentsListViewController ()
{
    UIBarButtonItem *btnCheck;
    NSMutableArray *searchResults;
}
@end

@implementation StudentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Students list")];
    
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Done") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(doneButtonClick)];
    
    btnCheck = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_checkall"] style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];

    self.navigationItem.rightBarButtonItems = @[btnDone, btnCheck];
    
    UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(closeButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnClose];
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    if (_selectedArray == nil) {
        _selectedArray = [[NSMutableArray alloc] init];
    }
    
    if (studentsArray == nil) {
        [self activateButtons:NO];
        studentsArray = [[NSMutableArray alloc] init];
        
        //load students list
        
    } else {
        [self activateButtons:YES];
    }
    
    //for test
#if 1
    UserObject *userObject = [[UserObject alloc] init];
    
    userObject.userID = @"1";
    userObject.username = @"Nguyen Tien Nam";
    userObject.displayName = @"Nguyen Nam";
    userObject.nickName = @"Yukan";
    userObject.avatarPath = @"";
    userObject.phoneNumber = @"0938912885";
    userObject.userRole = UserRole_Student;
    userObject.permission = Permission_Normal | Permission_SendMessage;
    
    userObject.shoolID = @"2";
    userObject.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject = [[ClassObject alloc] init];
    classObject.classID = @"1";
    classObject.className = @"Dien tu vien thong";
    classObject.pupilArray = nil;
    
    userObject.classObj = classObject;
    userObject.currentTerm = @"2015 - 2016 Hoc ky 1";
    userObject.classArray = nil;
    
    userObject.selected = NO;
    [studentsArray addObject:userObject];
    
    //student 2
    UserObject *userObject2 = [[UserObject alloc] init];
    
    userObject2.userID = @"2";
    userObject2.username = @"Nguyen Tien Nam";
    userObject2.displayName = @"Nguyen Nam";
    userObject2.nickName = @"Yukan";
    userObject2.avatarPath = @"";
    userObject2.phoneNumber = @"0938912885";
    userObject2.userRole = UserRole_Student;
    userObject2.permission = Permission_Normal | Permission_SendMessage;
    
    userObject2.shoolID = @"2";
    userObject2.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject2 = [[ClassObject alloc] init];
    classObject2.classID = @"1";
    classObject2.className = @"Dien tu vien thong";
    classObject2.pupilArray = nil;
    
    userObject2.classObj = classObject2;
    userObject2.currentTerm = @"2015 - 2016 Hoc ky 1";
    userObject2.classArray = nil;
    
    userObject2.selected = NO;
    [studentsArray addObject:userObject2];
    
    //student 3
    UserObject *userObject3 = [[UserObject alloc] init];
    
    userObject3.userID = @"3";
    userObject3.username = @"Nguyen Tien Nam";
    userObject3.displayName = @"Nguyen Nam";
    userObject3.nickName = @"Yukan";
    userObject3.avatarPath = @"";
    userObject3.phoneNumber = @"0938912885";
    userObject3.userRole = UserRole_Student;
    userObject3.permission = Permission_Normal | Permission_SendMessage;
    
    userObject3.shoolID = @"2";
    userObject3.schoolName = @"Bach khoa Ha Noi";
    
    ClassObject *classObject3 = [[ClassObject alloc] init];
    classObject3.classID = @"1";
    classObject3.className = @"Dien tu vien thong";
    classObject3.pupilArray = nil;
    
    userObject3.classObj = classObject3;
    userObject3.currentTerm = @"2015 - 2016 Hoc ky 1";
    userObject3.classArray = nil;
    
    userObject3.selected = NO;
    [studentsArray addObject:userObject3];
    
    [self activateButtons:YES];
    
    [self checkSelectedAll];
#endif
    
    [self updateHeaderInfo];
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

- (void)checkSelectedAll {
    BOOL isEqual = NO;
    if ([_selectedArray count] == [studentsArray count]) {
        isEqual = YES;
    }
    
    if (isEqual == YES) {
        [btnCheck setTintColor:[UIColor blueColor]];
        
    } else {
        [btnCheck setTintColor:[UIColor whiteColor]];
    }
}

- (void)activateButtons:(BOOL)flag {
    for (UIBarButtonItem *barButton in self.navigationItem.rightBarButtonItems) {
        barButton.enabled = flag;
    }
}

- (void)closeButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectReceiverCompleted" object:nil];
}

- (void)checkButtonClick {
    BOOL isEqual = NO;
    if ([_selectedArray count] == [studentsArray count]) {
        isEqual = YES;
    }
    
    if (isEqual == YES) {
        [_selectedArray removeAllObjects];
        
    } else {
        [_selectedArray removeAllObjects];
        
        [_selectedArray addObjectsFromArray:studentsArray];
    }
    
    [studentsTableView reloadData];
    [self checkSelectedAll];
    [self updateHeaderInfo];
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [studentsArray count];
    }
    
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
    
    static NSString *studentsListCellIdentifier = @"StudentsListCellIdentifier";
    
    StudentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsListCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentsListTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UserObject *userObject = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        userObject = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        userObject = [studentsArray objectAtIndex:indexPath.row];
    }
    
    cell.lbFullname.text = userObject.username;
    cell.lbAdditionalInfo.text = userObject.nickName;
    
    //find this user in selected array
    BOOL found = NO;
    
    for (UserObject *selectedUser in _selectedArray) {
        if ([selectedUser.userID isEqualToString:userObject.userID]) {
            found = YES;
            break;
        }
    }
    
    if (found) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UserObject *userObject = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        userObject = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        userObject = [studentsArray objectAtIndex:indexPath.row];
    }
    
    BOOL found = NO;
    for (UserObject *selectedUser in _selectedArray) {
        if ([selectedUser.userID isEqualToString:userObject.userID]) {
            found = YES;
            [_selectedArray removeObject:selectedUser];
            break;
        }
    }
    
    if (found == NO) {
        [_selectedArray addObject:userObject];
    }
    
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView endUpdates];
    
    [self checkSelectedAll];
    
    [self updateHeaderInfo];
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchString == nil || searchString.length == 0) {
        self->searchResults = [studentsArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"username CONTAINS[cd] %@", searchString];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [studentsArray filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    self.searchDisplayController.searchBar.showsCancelButton = YES;
    
    for (UIView *subView in self.searchDisplayController.searchBar.subviews){
        for (UIView *subView2 in subView.subviews){
            if([subView2 isKindOfClass:[UIButton class]]){
                [(UIButton*)subView2 setTitle:LocalizedString(@"Cancel") forState:UIControlStateNormal];
            }
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [studentsTableView reloadData];
    
    return YES;
}

- (void)updateHeaderInfo {
    lbCount.text =[NSString stringWithFormat:@"%@: %lu", LocalizedString(@"Count"), (unsigned long)[_selectedArray count]];
}
@end
