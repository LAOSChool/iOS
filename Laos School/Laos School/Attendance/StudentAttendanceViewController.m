//
//  StudentAttendanceViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentAttendanceViewController.h"
#import "CreatePermissionViewController.h"
#import "StuAttendanceTableViewCell.h"

#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "SVProgressHUD.h"

#import "RequestToServer.h"
#import "ShareData.h"

@interface StudentAttendanceViewController ()
{
    UISegmentedControl *segmentedControl;
    RequestToServer *requestToServer;
}
@end

@implementation StudentAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewFormGetAllowance)];
    
    self.navigationItem.rightBarButtonItems = @[btnAdd];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:LocalizedString(@"Term 1"), LocalizedString(@"Term 2"), LocalizedString(@"All"),
                                             nil]];
    segmentedControl.frame = CGRectMake(0, 0, 210, 30);
    [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:2];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segmentedControl;
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    //Load data
    [self loadData];
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

- (void)viewWillAppear:(BOOL)animated {
    lbTotalSection.text = [NSString stringWithFormat:@"%@: %d", LocalizedString(@"Total"), 10];
    lbPermittedSection.text = [NSString stringWithFormat:@"%@: %d", LocalizedString(@"Permission"), 9];
    lbNoPermittedSection.text = [NSString stringWithFormat:@"%@: %d", LocalizedString(@"No permission"), 1];
}

- (IBAction)segmentAction:(id)sender {
    
}

- (void)loadData {
    [SVProgressHUD show];
    if (segmentedControl.selectedSegmentIndex == 0) {  //term 1
        [requestToServer getAttendancesListWithUserID:[[ShareData sharedShareData] userObj].userID inClass:[[ShareData sharedShareData] userObj].classObj.classID];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //term 2
        
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //year
        
        
    }
}

- (void)createNewFormGetAllowance {
    CreatePermissionViewController *createPermissionView = [[CreatePermissionViewController alloc] initWithNibName:@"CreatePermissionViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:createPermissionView];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *studentAttendanceCellIdentifier = @"StudentAttendanceCellIdentifier";
    
    StuAttendanceTableViewCell *cell = [permissionTable dequeueReusableCellWithIdentifier:studentAttendanceCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StuAttendanceTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    /*
     {
     "from_row" = 0;
     list =     (
     {
     absent = 1;
     "att_dt" = "2016-04-16 00:00:00.0";
     "chk_user_id" = 10;
     "class_id" = 1;
     excused = 0;
     id = 1;
     late = 0;
     notice = "Test vang mat";
     "school_id" = 1;
     session = "Tiet 1";
     "session_id" = 1;
     subject = Toan;
     "subject_id" = 1;
     term = "Hoc Ky 1 - 2016";
     "term_id" = 1;
     "user_id" = 10;
     "user_name" = HoavQ;
     },
     {
     absent = 1;
     "att_dt" = "2016-05-16 00:00:00.0";
     "chk_user_id" = 10;
     "class_id" = 1;
     excused = 0;
     id = 2;
     late = 0;
     notice = "test vang mat";
     "school_id" = 1;
     session = "Tiet 1";
     "session_id" = 1;
     subject = Toan;
     "subject_id" = 1;
     term = "Hoc Ky 1 - 2016";
     "term_id" = 1;
     "user_id" = 11;
     "user_name" = HuyNQ;
     },
     {
     absent = 1;
     "att_dt" = "2016-04-16 00:00:00.0";
     "chk_user_id" = 11;
     "class_id" = 1;
     excused = 0;
     id = 3;
     late = 0;
     notice = "Test vang mat";
     "school_id" = 1;
     session = "Tiet 2";
     "session_id" = 2;
     subject = Toan;
     "subject_id" = 1;
     term = "Hoc Ky 1 - 2016";
     "term_id" = 1;
     "user_id" = 12;
     "user_name" = HuyNQ;
     },
     {
     absent = 1;
     "att_dt" = "2016-04-16 00:00:00.0";
     "chk_user_id" = 11;
     "class_id" = 1;
     excused = 0;
     id = 4;
     late = 0;
     notice = "Test vang mat";
     "school_id" = 1;
     session = "Tiet 2";
     "session_id" = 2;
     subject = Toan;
     "subject_id" = 1;
     term = "Hoc Ky 1 - 2016";
     "term_id" = 1;
     "user_id" = 13;
     "user_name" = HoavQ;
     },
     {
     absent = 1;
     "att_dt" = "2016-04-16 00:00:00.0";
     "chk_user_id" = 12;
     "class_id" = 1;
     excused = 0;
     id = 5;
     late = 0;
     notice = "Test vang mat";
     "school_id" = 1;
     session = "Tiet 2";
     "session_id" = 2;
     subject = Toan;
     "subject_id" = 1;
     term = "Hoc Ky 1 - 2016";
     "term_id" = 1;
     "user_id" = 14;
     "user_name" = HoavQ;
     }
     );
     "to_row" = 5;
     "total_count" = 5;
     }
     */
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
//    [refreshControl endRefreshing];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
//    [refreshControl endRefreshing];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
//    [refreshControl endRefreshing];
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}
@end
