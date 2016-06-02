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
#import "StuDetailAttendanceTableViewCell.h"

#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#import "RequestToServer.h"
#import "ShareData.h"
#import "CommonDefine.h"
#import "AttendanceObject.h"
#import "AttendanceCellData.h"
#import "DateTimeHelper.h"

#import "InformationViewController.h"

@interface StudentAttendanceViewController ()
{
    NSMutableArray *attendancesArray;
    NSMutableArray *attendanceCellData;
    
    UISegmentedControl *segmentedControl;
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
    
    InformationViewController *infoView;
}
@end

@implementation StudentAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setTitle:LocalizedString(@"Attendance")];
    
    [viewHeader setBackgroundColor:GREEN_COLOR];
    
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

    lbTotal.text = @"";
    lbRequested.text = LocalizedString(@"Got reason");
    lbNoRequested.text = LocalizedString(@"No reason");
    
    lbFullday.text = LocalizedString(@"Full day");
    lbSession.text = LocalizedString(@"Session");
    
    lbFulldayGotReasonValue.text = @"0";
    lbFulldayNoReasonValue.text = @"0";
    lbSessionGotReasonValue.text = @"0";
    lbSessionNoReasonValue.text = @"0";
    
    //Load data
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sentAttendanceRequest)
                                                 name:@"SentAttendanceRequest"
                                               object:nil];
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


- (void)sentAttendanceRequest {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD show];
//    if (segmentedControl.selectedSegmentIndex == 0) {  //term 1
        [requestToServer getAttendancesListWithUserID:[[ShareData sharedShareData] userObj].userID inClass:[[ShareData sharedShareData] userObj].classObj.classID];
        
//    } else if(segmentedControl.selectedSegmentIndex == 1) {    //term 2
    
        
//    } else if(segmentedControl.selectedSegmentIndex == 2) {    //year
//        
//        
//    }
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
        return 40;
    }
    
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AttendanceCellData *attCellData = [attendanceCellData objectAtIndex:indexPath.row];
    
    if (attCellData.cellType == CellType_Detail) {
        static NSString *stdAttendanceDetailIdentifier = @"StuDetailAttendanceTableViewCell";
        
        StuDetailAttendanceTableViewCell *cell = [attendanceTable dequeueReusableCellWithIdentifier:stdAttendanceDetailIdentifier];
        if (cell == nil) {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StuDetailAttendanceTableViewCell" owner:nil options:nil];
            cell = [nib objectAtIndex:0];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        [cell.contentView setBackgroundColor:[UIColor darkGrayColor]];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
        
        AttendanceObject *attObj = (AttendanceObject *)attCellData.cellData;
        
        if (attObj.hasRequest) {
            cell.lbReason.textColor = [UIColor whiteColor];
            cell.lbSession.textColor = [UIColor whiteColor];
            cell.lbReason.text = attObj.reason;
            
        } else {
            cell.lbReason.textColor = [UIColor redColor];
            cell.lbSession.textColor = [UIColor whiteColor];
            cell.lbReason.text = LocalizedString(@"No reason");
        }
        
        
        
        NSString *session = attObj.session;
        NSString *subject = attObj.subject;
        
        if (session && session.length > 0) {
            if (subject && subject.length > 0) {
                session = [NSString stringWithFormat:@"%@ - %@", session, subject];
            }
        } else {
            if (subject && subject.length > 0) {
                session = subject;
            }
        }
        
        cell.lbSession.text = session;
        
        return cell;
    }
    
    static NSString *studentAttendanceCellIdentifier = @"StuAttendanceTableViewCell";
    
    StuAttendanceTableViewCell *cell = [attendanceTable dequeueReusableCellWithIdentifier:studentAttendanceCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StuAttendanceTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.delegate = (id)self;
    
    AttendanceObject *attObj = (AttendanceObject *)attCellData.cellData;
    
    cell.lbDate.text = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:attObj.dateTime withFormat:@"yyyy-MM-dd"];
    
    if (attObj.hasRequest) {
        [cell.contentView setBackgroundColor:READ_COLOR];
        [cell setBackgroundColor:READ_COLOR];
    } else {
        [cell.contentView setBackgroundColor:UNREAD_COLOR];
        [cell setBackgroundColor:UNREAD_COLOR];
    }
    
    if ([attObj.detailSession count] > 0) {
        cell.imgArrow.hidden = NO;
        
        cell.lbSession.text = [NSString stringWithFormat:@"%lu %@", (unsigned long)[attObj.detailSession count], LocalizedString(@"Session(s)")];
        cell.lbReason.text = LocalizedString(@"(Tap to view detail)");
        cell.lbReason.textColor = [UIColor lightGrayColor];
        
//        CGRect rect = cell.lbSession.frame;
//        CGRect rectImgArrow = cell.imgArrow.frame;
//        rect.origin.y = rectImgArrow.origin.y + 2;
//        
//        [cell.lbSession setFrame:rect];
//        
//        rect = cell.lbDate.frame;
//        rect.origin.y = rectImgArrow.origin.y + 2;
//        
//        [cell.lbDate setFrame:rect];
        
    } else {
        cell.imgArrow.hidden = YES;
        cell.lbSession.text = LocalizedString(@"Full day");
        
        cell.lbReason.hidden = NO;
        if (attObj.hasRequest) {
            cell.lbReason.text = attObj.reason;
            cell.lbReason.textColor = BLUE_COLOR;
        } else {
            cell.lbReason.text = LocalizedString(@"No reason");
            cell.lbReason.textColor = [UIColor redColor];
        }
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AttendanceCellData *attCellData = [attendanceCellData objectAtIndex:indexPath.row];
    
    if (attCellData.cellType == CellType_Normal) {
        AttendanceObject *attObj = (AttendanceObject *)attCellData.cellData;
        NSArray *sessionArr = attObj.detailSession;
        
        if ([sessionArr count] > 0) {
            if (attCellData.isShowDetail == NO) {

                for (AttendanceObject *session in sessionArr) {
                    AttendanceCellData *cellData = [[AttendanceCellData alloc] init];
                    
                    cellData.cellData = session;
                    cellData.cellType = CellType_Detail;
                    cellData.isShowDetail = NO;
                    
                    [attendanceCellData insertObject:cellData atIndex:indexPath.row + 1];
                }
                
                [self insertDetailCellAtIndex:indexPath.row numberOfInsertCell:[sessionArr count]];
                
//                if (indexPath.row + [sessionArr count] + 1 >= [attendanceCellData count]) {
//                    [attendanceTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + [sessionArr count] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//                }
                [attendanceTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                
                attCellData.isShowDetail = YES;
                
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
            
        } else {
            [self showReasonDetail:indexPath forDetailCell:NO];
        }
    } else {
        [self showReasonDetail:indexPath forDetailCell:YES];
    }
    
}

- (void)insertDetailCellAtIndex:(NSInteger)index numberOfInsertCell:(NSInteger)numbOfInsert {
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 1; i <= numbOfInsert; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:index + i inSection:0]];
    }
    NSIndexPath *indexPathSelected = [NSIndexPath indexPathForRow:index inSection:0];
    
    //set color of the selected cell
    StuAttendanceTableViewCell *selectedCell = (StuAttendanceTableViewCell*)[attendanceTable cellForRowAtIndexPath:indexPathSelected];
//    selectedCell.contentView.backgroundColor = DOCUMENT_SELECTED_CELL_COLOR;
    //set indicator icon
    [selectedCell.imgArrow setImage:[UIImage imageNamed:@"ic_up_arrow.png"]];
    
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
    StuAttendanceTableViewCell *oldSelectedCell = (StuAttendanceTableViewCell*)[attendanceTable cellForRowAtIndexPath:indexPathOldSelected];
//    oldSelectedCell.contentView.backgroundColor = DOCUMENT_NORMAL_CELL_COLOR;
    //set indicator icon
    [oldSelectedCell.imgArrow setImage:[UIImage imageNamed:@"ic_down_arrow.png"]];
    
    [attendanceTable beginUpdates];
    [attendanceTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
    [attendanceTable endUpdates];
}

//cell delegate
- (void)showReasonDetail:(NSIndexPath *)indexPath forDetailCell:(BOOL)isDetailCell {
    AttendanceCellData *cellData = [attendanceCellData objectAtIndex:indexPath.row];
    AttendanceObject *attObj = (AttendanceObject *)cellData.cellData;
    
    if (infoView == nil) {
        infoView = [[InformationViewController alloc] initWithNibName:@"InformationViewController" bundle:nil];
    }
    
    infoView.attObj = attObj;
    infoView.view.alpha = 0;
    
    infoView.isDetail = isDetailCell;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    CGRect rect = appDelegate.window.frame;
    [infoView.view setFrame:rect];
    
    [appDelegate.window addSubview:infoView.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        infoView.view.alpha = 1;
    }];
    
    [infoView loadInformation];
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    NSInteger countFDRequest = 0;
    NSInteger countFDNoRequest = 0;
    NSInteger countSessionRequest = 0;
    NSInteger countSessionNORequest = 0;
    
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
            
            if ([attendanceDict valueForKey:@"id"] != (id)[NSNull null]) {
                attendanceObj.attendanceID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"id"]];
            }
            
            if ([attendanceDict valueForKey:@"att_dt"] != (id)[NSNull null]) {
                attendanceObj.dateTime = [attendanceDict valueForKey:@"att_dt"];
            }
            
            if ([attendanceDict valueForKey:@"excused"] != (id)[NSNull null]) {
                attendanceObj.hasRequest = [[attendanceDict valueForKey:@"excused"] boolValue];
            }
            
            if ([attendanceDict valueForKey:@"notice"] != (id)[NSNull null]) {
                attendanceObj.reason = [attendanceDict valueForKey:@"notice"];
            }
            
            if ([attendanceDict valueForKey:@"session"] != (id)[NSNull null]) {
                attendanceObj.session = [attendanceDict valueForKey:@"session"];
            }
            
            if ([attendanceDict valueForKey:@"session_id"] != (id)[NSNull null]) {
                attendanceObj.sessionID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"session_id"]];
            }
            
            if ([attendanceDict valueForKey:@"subject"] != (id)[NSNull null]) {
                attendanceObj.subject = [attendanceDict valueForKey:@"subject"];
            }
            
            if ([attendanceDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                attendanceObj.subjectID = [NSString stringWithFormat:@"%@", [attendanceDict valueForKey:@"subject_id"]];
            }
            
            //add every time that has the same day to detail session
            if (attendanceObj.dateTime.length > 0) {
                if (attendanceObj.session.length > 0 ||
                    attendanceObj.subject.length > 0) {

                    BOOL found = NO;
                    for (AttendanceObject *att in attendancesArray) {
                        if ([att.dateTime isEqualToString:attendanceObj.dateTime]) {
                            //add if it is not a fullday off
                            if (att.session.length > 0 ||
                                att.subject.length > 0) {
                                
                                [att.detailSession addObject:attendanceObj];
                                
                                if (attendanceObj.hasRequest) {
                                    countSessionRequest ++;
                                    
                                } else {
                                    if (att.hasRequest == YES) {
                                        att.hasRequest = NO;
                                    }
                                    
                                    countSessionNORequest ++;
                                }
                                
                                found = YES;
                                break;
                            }
                        }
                    }
                    
                    if (found == NO) {
                        //add itself into it
                        [attendanceObj.detailSession addObject:attendanceObj];
                        
                        //only count before add
                        if (attendanceObj.hasRequest) {
                            countSessionRequest ++;
                        } else {
                            countSessionNORequest ++;
                        }
                        
                        [attendancesArray addObject:attendanceObj];
                    }
                    
                } else {
                    //only count before add
                    if (attendanceObj.hasRequest) {
                        countFDRequest ++;
                    } else {
                        countFDNoRequest ++;
                    }
                    
                    [attendancesArray addObject:attendanceObj];
                }
            }
        }
        
        lbTotal.text = @"";
        
        lbFulldayGotReasonValue.text = [NSString stringWithFormat:@"%ld", (long)countFDRequest];
        lbFulldayNoReasonValue.text = [NSString stringWithFormat:@"%ld", (long)countFDNoRequest];
        lbSessionGotReasonValue.text = [NSString stringWithFormat:@"%ld", (long)countSessionRequest];
        lbSessionNoReasonValue.text = [NSString stringWithFormat:@"%ld", (long)countSessionNORequest];
        
        [self prepareDataForTableView];
        [attendanceTable reloadData];
    }
}

- (void)prepareDataForTableView {
    [self sortAttendancesArrayByDateTime];
    
    for (AttendanceObject *att in attendancesArray) {
        AttendanceCellData *cellData = [[AttendanceCellData alloc] init];
        
        cellData.cellData = att;
        cellData.cellType = CellType_Normal;
        cellData.isShowDetail = NO;
        
        [attendanceCellData addObject:cellData];
    }
}

- (void)sortAttendancesArrayByDateTime {
    NSSortDescriptor *dateTime = [NSSortDescriptor sortDescriptorWithKey:@"dateTime" ascending:NO];
    NSArray *resultArr = [attendancesArray sortedArrayUsingDescriptors:[NSArray arrayWithObjects:dateTime, nil]];
    
    [attendancesArray removeAllObjects];
    [attendancesArray addObjectsFromArray:resultArr];
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
