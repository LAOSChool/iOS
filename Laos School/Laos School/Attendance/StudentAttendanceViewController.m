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
#import "CommonDefine.h"
#import "AttendanceObject.h"
#import "AttendanceCellData.h"
#import "DateTimeHelper.h"

@interface StudentAttendanceViewController ()
{
    NSMutableArray *attendancesArray;
    NSMutableArray *attendanceCellData;
    
    UISegmentedControl *segmentedControl;
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
}
@end

@implementation StudentAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setTitle:LocalizedString(@"Attendance")];
    
    UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createNewFormGetAllowance)];
    
    self.navigationItem.rightBarButtonItems = @[btnAdd];
/*
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
 */
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (attendancesArray == nil) {
        attendancesArray = [[NSMutableArray alloc] init];
    }
    
    if (attendanceCellData == nil) {
        attendanceCellData = [[NSMutableArray alloc] init];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadAttendanceData) forControlEvents:UIControlEventValueChanged];
    [attendanceTable addSubview:refreshControl];
    
    lbTotal.text = [NSString stringWithFormat:@"%@: %d day(s)", LocalizedString(@"Total"), 0];
    lbRequested.text = [NSString stringWithFormat:@"%@: %d day(s)", LocalizedString(@"Have reason"), 0];
    lbNoRequested.text = [NSString stringWithFormat:@"%@: %d day(s)", LocalizedString(@"No reason"), 0];
    
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


- (IBAction)segmentAction:(id)sender {
    
}

- (void)reloadAttendanceData {
    [self loadData];
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
    return [attendanceCellData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    AttendanceCellData *attCellData = [attendanceCellData objectAtIndex:indexPath.row];
    
    if (attCellData.cellType == CellType_Detail) {
        return 28;
    }
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttendanceCellData *attCellData = [attendanceCellData objectAtIndex:indexPath.row];
    
    if (attCellData.cellType == CellType_Detail) {
        static NSString *stdAttendanceDetailIdentifier = @"StdAttendanceDetailIdentifier";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:stdAttendanceDetailIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stdAttendanceDetailIdentifier];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        cell.textLabel.textColor = [UIColor whiteColor];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        
        [cell.contentView setBackgroundColor:[UIColor lightGrayColor]];
        [cell setBackgroundColor:[UIColor lightGrayColor]];
        
        NSString *session = (NSString *)attCellData.cellData;
        cell.textLabel.text = session;
        
        cell.userInteractionEnabled = NO;
        
        return cell;
    }
    
    static NSString *studentAttendanceCellIdentifier = @"StudentAttendanceCellIdentifier";
    
    StuAttendanceTableViewCell *cell = [attendanceTable dequeueReusableCellWithIdentifier:studentAttendanceCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StuAttendanceTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    AttendanceObject *attObj = (AttendanceObject *)attCellData.cellData;
    
    if (attObj.hasRequest) {
        cell.lbReason.text = attObj.reason;
        cell.lbReason.textColor = [UIColor grayColor];
    } else {
        cell.lbReason.text = LocalizedString(@"No reason");
        cell.lbReason.textColor = [UIColor redColor];
    }
    
    cell.lbDate.text = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:attObj.dateTime withFormat:@"yyyy-MM-dd"];
    
    if (attObj.hasRequest) {
        [cell.contentView setBackgroundColor:READ_COLOR];
        [cell setBackgroundColor:READ_COLOR];
    } else {
        [cell.contentView setBackgroundColor:UNREAD_COLOR];
        [cell setBackgroundColor:UNREAD_COLOR];
    }
    
    NSArray *sessionArr = [attObj.detailSession valueForKey:attObj.dateTime];
    
    if ([sessionArr count] > 0) {
        cell.userInteractionEnabled = YES;
    } else {
        cell.userInteractionEnabled = NO;
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AttendanceCellData *attCellData = [attendanceCellData objectAtIndex:indexPath.row];
    
    if (attCellData.cellType == CellType_Normal) {
        AttendanceObject *attObj = (AttendanceObject *)attCellData.cellData;
        
        if (attObj.dateTime.length > 0) {
            if (attCellData.isShowDetail == NO) {
                NSArray *sessionArr = [attObj.detailSession valueForKey:attObj.dateTime];
                
                if (sessionArr && [sessionArr count] > 0) {
                    for (NSString *session in sessionArr) {
                        AttendanceCellData *cellData = [[AttendanceCellData alloc] init];
                        
                        cellData.cellData = session;
                        cellData.cellType = CellType_Detail;
                        cellData.isShowDetail = NO;
                        
                        [attendanceCellData insertObject:cellData atIndex:indexPath.row + 1];
                    }
                    
                    [self insertDetailCellAtIndex:indexPath.row numberOfInsertCell:[sessionArr count]];
                    
                    if (indexPath.row + 1 == [attendanceCellData count] - 1) {
                        [attendanceTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    }
                    
                    attCellData.isShowDetail = YES;
                }
                
            } else {
                NSMutableArray *arr = [[NSMutableArray alloc] init];
                for (NSInteger i = indexPath.row + 1; i < [attendanceCellData count] ; i ++) {
                    AttendanceCellData *detailCellData = [attendanceCellData objectAtIndex:i];
                    
                    if (detailCellData.cellType == CellType_Detail) {
                        [arr addObject:detailCellData];
                    } else {
                        break;
                    }
                }
                
                [attendanceCellData removeObjectsInArray:arr];
                
                [self deleteDetailCellAtIndex:indexPath.row numberOfDeleteCell:[arr count]];
                
                attCellData.isShowDetail = NO;
            }
        }
    }
    
}

- (void)insertDetailCellAtIndex:(NSInteger)index numberOfInsertCell:(NSInteger)numbOfInsert {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 1; i <= numbOfInsert; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index + i inSection:0]];
    }
    NSIndexPath *indexPathSelected = [NSIndexPath indexPathForRow:index inSection:0];
    
    //set color of the selected cell
//    DocumentManifestCell *selectedCell = (DocumentManifestCell*)[documentTable cellForRowAtIndexPath:indexPathSelected];
//    selectedCell.contentView.backgroundColor = DOCUMENT_SELECTED_CELL_COLOR;
//    //set indicator icon
//    [selectedCell.indicatorIcon setImage:[UIImage imageNamed:@"arrow_up_light_.png"]];
    
    [attendanceTable beginUpdates];
    [attendanceTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [attendanceTable endUpdates];
}

- (void)deleteDetailCellAtIndex:(NSInteger)index numberOfDeleteCell:(NSInteger)numbOfDelete {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 1; i <= numbOfDelete; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index + i inSection:0]];
    }
    
    NSIndexPath *indexPathOldSelected = [NSIndexPath indexPathForRow:index inSection:0];
    
    //set color of the old selected cell
//    DocumentManifestCell *oldSelectedCell = (DocumentManifestCell*)[documentTable cellForRowAtIndexPath:indexPathOldSelected];
//    oldSelectedCell.contentView.backgroundColor = DOCUMENT_NORMAL_CELL_COLOR;
//    //set indicator icon
//    [oldSelectedCell.indicatorIcon setImage:[UIImage imageNamed:@"arrow_down_darker_.png"]];
    
    [attendanceTable beginUpdates];
    [attendanceTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [attendanceTable endUpdates];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    NSInteger countRequest = 0;
    NSInteger countNoRequest = 0;
    
    [attendancesArray removeAllObjects];
    [attendanceCellData removeAllObjects];
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    NSArray *attendances = [jsonObj objectForKey:@"list"];

    /*
     {
     "from_row" = 0;
     list =     (
     {
     "att_dt" = "2016-04-16";
     auditor = 2;
     "auditor_name" = "Admin 1 -School 1";
     "class_id" = 1;
     excused = 0;
     id = 1;
     "is_requested" = 0;
     notice = "Test vang mat";
     "requested_dt" = "<null>";
     "school_id" = 1;
     session = "Tiet 1";
     "session_id" = 1;
     state = 1;
     "student_id" = 10;
     "student_name" = "Student 10";
     subject = Toan;
     "subject_id" = 1;
     term = "Hoc Ky 1 - 2016";
     "term_id" = 1;
     }
     );
     "to_row" = 1;
     "total_count" = 1;
     }
     */
    if (attendances != (id)[NSNull null]) {
        
        for (NSDictionary *attendanceDict in attendances) {
            AttendanceObject *attendanceObj = [[AttendanceObject alloc] init];
            
            if ([attendanceDict valueForKey:@"att_dt"] != (id)[NSNull null]) {
                attendanceObj.dateTime = [attendanceDict valueForKey:@"att_dt"];
            }
            
            if ([attendanceDict valueForKey:@"is_requested"] != (id)[NSNull null]) {
                attendanceObj.hasRequest = [[attendanceDict valueForKey:@"is_requested"] boolValue];
            }
            
            if (attendanceObj.hasRequest) {
                countRequest ++;
            } else {
                countNoRequest ++;
            }
            
            if ([attendanceDict valueForKey:@"notice"] != (id)[NSNull null]) {
                attendanceObj.reason = [attendanceDict valueForKey:@"notice"];
            }
            
            //add every time that has the same day to detail session
            
            if (attendanceObj.dateTime.length > 0) {
                if ([attendanceDict valueForKey:@"session"] != (id)[NSNull null] ||
                    [attendanceDict valueForKey:@"subject"] != (id)[NSNull null]) {
                    
                    NSString *session = @"";
                    NSString *subject = @"";
                    
                    if ([attendanceDict valueForKey:@"session"] != (id)[NSNull null]) {
                        session = [attendanceDict valueForKey:@"session"];
                    }
                    
                    if ([attendanceDict valueForKey:@"subject"] != (id)[NSNull null]) {
                        subject = [attendanceDict valueForKey:@"subject"];
                    }
                    
                    if (session && session.length > 0) {
                        if (subject && subject.length > 0) {
                            session = [NSString stringWithFormat:@"%@ - %@", session, subject];
                        }
                    } else {
                        if (subject && subject.length > 0) {
                            session = subject;
                        }
                    }
                    
                    BOOL found = NO;
                    for (AttendanceObject *att in attendancesArray) {
                        NSArray *sessionArr = [att.detailSession valueForKey:attendanceObj.dateTime];
                        
                        if (sessionArr && [sessionArr count] > 0) {
                            NSMutableArray *newArr = [[NSMutableArray alloc] initWithArray:sessionArr];
                            [newArr addObject:session];
                            [attendanceObj.detailSession setObject:newArr forKey:attendanceObj.dateTime];
                            
                            found = YES;
                            break;
                        }
                    }
                    
                    if (found == NO) {
                        NSMutableArray *newArr = [[NSMutableArray alloc] init];
                        [newArr addObject:session];
                        [attendanceObj.detailSession setObject:newArr forKey:attendanceObj.dateTime];
                        
                        [attendancesArray addObject:attendanceObj];
                    }
                    
                } else {
                    [attendancesArray addObject:attendanceObj];
                }
            }
        }
        
        lbTotal.text = [NSString stringWithFormat:@"%@: %lu day(s)", LocalizedString(@"Total"), (unsigned long)[attendancesArray count]];
        lbRequested.text = [NSString stringWithFormat:@"%@: %ld day(s)", LocalizedString(@"Have reason"), (long)countRequest];
        lbNoRequested.text = [NSString stringWithFormat:@"%@: %ld day(s)", LocalizedString(@"No reason"), (long)countNoRequest];
        
        [self prepareDataForTableView];
        [attendanceTable reloadData];
    }
}

- (void)prepareDataForTableView {
    for (AttendanceObject *att in attendancesArray) {
        AttendanceCellData *cellData = [[AttendanceCellData alloc] init];
        
        cellData.cellData = att;
        cellData.cellType = CellType_Normal;
        cellData.isShowDetail = NO;
        
        [attendanceCellData addObject:cellData];
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
