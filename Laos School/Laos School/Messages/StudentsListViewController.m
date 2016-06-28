//
//  StudentsListViewController.m
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentsListViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "PersonalInfoViewController.h"
#import "LocalizeHelper.h"
#import "StudentsListTableViewCell.h"
#import "UserObject.h"
#import "ClassObject.h"
#import "RequestToServer.h"
#import "ShareData.h"

#import "SVProgressHUD.h"

@interface StudentsListViewController ()
{
    UIBarButtonItem *btnCheck;
    NSMutableArray *searchResults;
    
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
}
@end

@implementation StudentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Students list")];
    
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (_studentListType == StudentList_Message) {
        UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Done") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(doneButtonClick)];
        
        btnCheck = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_checkall"] style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];
        
        self.navigationItem.rightBarButtonItems = @[btnDone, btnCheck];
        
        UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(closeButtonClick)];
        
        self.navigationItem.leftBarButtonItems = @[btnClose];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadStudentData) forControlEvents:UIControlEventValueChanged];
    [studentsTableView addSubview:refreshControl];
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
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
        [self loadData];
        
    } else {
        [self activateButtons:YES];
    }
    
    if (_studentListType == StudentList_Message) {
        [self checkSelectedAll];
        
        [self updateHeaderInfo];
    }
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

- (void)reloadStudentData {
    [self loadData];
}

- (void)loadData {
    
    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQ, ^{
        [SVProgressHUD show];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [requestToServer getStudentList:[[ShareData sharedShareData] userObj].classObj.classID];
        });
    });
}

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
    return 44.0;
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
    
    cell.lbFullname.text = userObject.displayName;
    cell.lbAdditionalInfo.text = userObject.nickName;
    
    if (userObject.avatarPath && userObject.avatarPath.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgAvatar];
        
        //load the image
        cell.imgAvatar.imageURL = [NSURL URLWithString:userObject.avatarPath];
        
    } else {
        if ([userObject.gender isEqualToString:@"male"]) {
            cell.imgAvatar.image = [UIImage imageNamed:@"ic_male.png"];
            
        } else if ([userObject.gender isEqualToString:@"female"]) {
            cell.imgAvatar.image = [UIImage imageNamed:@"ic_female.png"];
        }
    }
    
    if (_studentListType == StudentList_Message) {
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
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
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
    
    if (_studentListType == StudentList_Message) {
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
        
    } else {
        PersonalInfoViewController *personalInfoView = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
        personalInfoView.userObj = userObject;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:personalInfoView];
        [nav setModalPresentationStyle:UIModalPresentationFormSheet];
        [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    UserObject *userObject = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        userObject = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        userObject = [studentsArray objectAtIndex:indexPath.row];
    }
    
    if (_studentListType == StudentList_Normal) {
        PersonalInfoViewController *personalInfoView = [[PersonalInfoViewController alloc] initWithNibName:@"PersonalInfoViewController" bundle:nil];
        personalInfoView.userObj = userObject;
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:personalInfoView];
        [nav setModalPresentationStyle:UIModalPresentationFormSheet];
        [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        
        [self.navigationController presentViewController:nav animated:YES completion:nil];
    }
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
    if (_studentListType == StudentList_Message) {
        lbCount.text =[NSString stringWithFormat:@"%@: %lu", LocalizedString(@"Selected"), (unsigned long)[_selectedArray count]];
    } else {
        lbCount.text =[NSString stringWithFormat:@"%@: %lu", LocalizedString(@"Total"), (unsigned long)[studentsArray count]];
    }
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    [studentsArray removeAllObjects];
    
    NSArray *students = [jsonObj objectForKey:@"list"];    
    
    if (students != (id)[NSNull null]) {
        
        for (NSDictionary *studentDict in students) {
            UserObject *userObject = [[UserObject alloc] init];
            
            if ([studentDict valueForKey:@"id"] != (id)[NSNull null]) {
                userObject.userID = [NSString stringWithFormat:@"%@", [studentDict valueForKey:@"id"]];
            }
            
            if ([studentDict valueForKey:@"sso_id"] != (id)[NSNull null]) {
                userObject.username = [studentDict valueForKey:@"sso_id"];
            }
            
            if ([studentDict valueForKey:@"fullname"] != (id)[NSNull null]) {
                userObject.displayName = [studentDict valueForKey:@"fullname"];
            }
            
            if ([studentDict valueForKey:@"nickname"] != (id)[NSNull null]) {
                userObject.nickName = [studentDict valueForKey:@"nickname"];
            }
            
            if ([studentDict valueForKey:@"gender"] != (id)[NSNull null]) {
                userObject.gender = [studentDict valueForKey:@"gender"];
            }
            
            if ([studentDict valueForKey:@"photo"] != (id)[NSNull null]) {
                userObject.avatarPath = [studentDict valueForKey:@"photo"];
            }
            
            if ([studentDict valueForKey:@"phone"] != (id)[NSNull null]) {
                userObject.phoneNumber = [studentDict valueForKey:@"phone"];
            }
            
            if ([studentDict valueForKey:@"roles"] != (id)[NSNull null]) {
                NSString *role = [studentDict objectForKey:@"roles"];
                if (role != (id)[NSNull null] && role && role.length > 0) {
                    
                    if ([role isEqualToString:USER_ROLE_STUDENT]) {
                        userObject.userRole = UserRole_Student;
                        userObject.permission = Permission_Normal | Permission_SendMessage;
                        
                    } else if ([role isEqualToString:USER_ROLE_PRESIDENT]) {
                        userObject.userRole = UserRole_Student;
                        userObject.permission = Permission_Normal | Permission_SendMessage | Permission_CheckAttendance;
                        
                    } else if ([role isEqualToString:USER_ROLE_HEAD_TEACHER]) {
                        userObject.userRole = UserRole_Teacher;
                        userObject.permission = Permission_Normal | Permission_SendMessage | Permission_CheckAttendance | Permission_SendAnnouncement | Permission_AddScore;
                        
                    }
                    
                }
            }
            
            if ([studentDict valueForKey:@"school_id"] != (id)[NSNull null]) {
                userObject.shoolID = [studentDict objectForKey:@"school_id"];
            }
            
            if ([studentDict valueForKey:@"schoolName"] != (id)[NSNull null]) {
                userObject.schoolName = [studentDict objectForKey:@"schoolName"];
            }
            
            if ([studentDict valueForKey:@"std_contact_email"] != (id)[NSNull null]) {
                userObject.parentEmail = [studentDict objectForKey:@"std_contact_email"];
            }
            
            if ([studentDict valueForKey:@"std_contact_name"] != (id)[NSNull null]) {
                userObject.parentName = [studentDict objectForKey:@"std_contact_name"];
            }
            
            if ([studentDict valueForKey:@"std_contact_phone"] != (id)[NSNull null]) {
                userObject.parentPhone = [studentDict objectForKey:@"std_contact_phone"];
            }
            
            if ([studentDict valueForKey:@"std_contact_address"] != (id)[NSNull null]) {
                userObject.address = [studentDict objectForKey:@"std_contact_address"];
            }

            [studentsArray addObject:userObject];
        }
    }
    
    if (_studentListType == StudentList_Message) {
        if ([studentsArray count] > 0) {
            [self activateButtons:YES];
            
        } else {
            [self activateButtons:NO];
        }
        
        [self checkSelectedAll];
    }
    
    [self updateHeaderInfo];
    
    [studentsTableView reloadData];
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
