//
//  AnnouncementViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "AnnouncementViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "CreatePostViewController.h"

#import "AnnouncementTableViewCell.h"
#import "AnnouncementObject.h"
#import "LocalizeHelper.h"
#import "ShareData.h"
#import "CommonDefine.h"
#import "PhotoObject.h"

#import "RequestToServer.h"
#import "DateTimeHelper.h"
#import "CoreDataUtil.h"
#import "SVProgressHUD.h"

@interface AnnouncementViewController ()
{
    NSMutableArray *announceArray;
    NSMutableArray *unreadAnnouncementsArray;
    NSMutableArray *sentAnnouncementsArray;
    NSMutableArray *searchResults;
    
    UISegmentedControl *segmentedControl;
    
    RequestToServer *requestToServer;
    
    BOOL isReachToEnd;
    UIRefreshControl *refreshControl;
}
@end

@implementation AnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Announcements")];
    
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    isReachToEnd = NO;
    
    if (([ShareData sharedShareData].userObj.permission & Permission_SendAnnouncement) == Permission_SendAnnouncement) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAnnouncement)];
        
        self.navigationItem.rightBarButtonItems = @[addButton];
        
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
                            [NSArray arrayWithObjects:LocalizedString(@"All"), LocalizedString(@"Unread"),
                             nil]];
        segmentedControl.frame = CGRectMake(0, 0, 140, 30);
        [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
        [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
        //[segmentedControl setWidth:70.0 forSegmentAtIndex:2];
        
        [segmentedControl setSelectedSegmentIndex:0];
        
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.titleView = segmentedControl;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshAfterSentNewAnnouncement)
                                                     name:@"SentNewAnnouncement"
                                                   object:nil];
        
    } else {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
                            [NSArray arrayWithObjects:LocalizedString(@"All"), LocalizedString(@"Unread"),
                             nil]];
        segmentedControl.frame = CGRectMake(0, 0, 140, 30);
        [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
        [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
        
        [segmentedControl setSelectedSegmentIndex:0];
        
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.titleView = segmentedControl;
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    if (announceArray == nil) {
        announceArray = [[NSMutableArray alloc] init];
    }
    
    if (unreadAnnouncementsArray == nil) {
        unreadAnnouncementsArray = [[NSMutableArray alloc] init];
    }
    
    if (sentAnnouncementsArray == nil) {
        sentAnnouncementsArray = [[NSMutableArray alloc] init];
    }

    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadDataFromServer) forControlEvents:UIControlEventValueChanged];
    [announcementTableView addSubview:refreshControl];
    
    //Load data
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAfterUpdateFlag)
                                                 name:@"RefreshAfterUpdateFlag"
                                               object:nil];
    
    //for test
#if 0
    AnnouncementObject *announcementObj = [[AnnouncementObject alloc] init];
    
    announcementObj.announcementID = @"1";
    announcementObj.subject = @"Thong bao 1";
    announcementObj.content = @"Con học dốt như bò";
    announcementObj.senderUser = @"Giao vien chu nhiem";
    announcementObj.unreadFlag = YES;
    announcementObj.importanceType = ImportanceNormal;
    announcementObj.dateTime = @"2016-03-20 16:00";
    
    PhotoObject *phototObj = [[PhotoObject alloc] init];
    phototObj.caption = @"image 1";
    phototObj.filePath = @"https://lh3.googleusercontent.com/-mm4BmO6_yxY/VoD8n3O-ztI/AAAAAAAATYw/q_wBVhUNDdA/s640/gai-ngoan-khoe-hang-18.jpg";
    
    [announcementObj.imgArray addObject:phototObj];
    
    PhotoObject *phototObj2 = [[PhotoObject alloc] init];
    phototObj2.caption = @"image 2";
    phototObj2.filePath = @"https://lh3.googleusercontent.com/-mm4BmO6_yxY/VoD8n3O-ztI/AAAAAAAATYw/q_wBVhUNDdA/s640/gai-ngoan-khoe-hang-18.jpg";
    
    [announcementObj.imgArray addObject:phototObj2];
    
    [announceArray addObject:announcementObj];
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

- (BOOL)isReachToBottom:(NSInteger)row {
    BOOL res = NO;
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        if (row == [announceArray count] - 1) {
            res = YES;
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        if (row == [unreadAnnouncementsArray count] - 1) {
            res = YES;
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        if (row == [sentAnnouncementsArray count] - 1) {
            res = YES;
        }
        
    }
    
    return res;
}

- (IBAction)segmentAction:(id)sender {
    isReachToEnd = NO;
    [announcementTableView reloadData];
    [self loadData];
}


- (void)addNewAnnouncement {
    CreatePostViewController *composeViewController = nil;
    
    composeViewController = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (void)refreshAfterUpdateFlag {
    [announcementTableView reloadData];
}

- (void)refreshAfterSentNewAnnouncement {
    [self loadDataFromServer];
}

- (void)loadData {
    [SVProgressHUD show];
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        //load data from local coredata
        [self loadAnnouncementsFromCoredata];
        
        [self loadNewAnnouncementFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        //load data from local coredata
        [self loadUnreadAnnouncementsFromCoredata];
        
        [self loadUnreadAnnouncementsFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        //load data from local coredata
        [self loadSentAnnouncementsFromCoredata];
        
        [self loadSentAnnouncementsFromServer];
        
    }
}

- (void)loadDataFromCoredata {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        //load data from local coredata
        [self loadAnnouncementsFromCoredata];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        //load data from local coredata
        [self loadUnreadAnnouncementsFromCoredata];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        //load data from local coredata
        [self loadSentAnnouncementsFromCoredata];
    }
    
    [announcementTableView reloadData];
}

- (void)loadDataFromServer {
    [SVProgressHUD show];
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [self loadNewAnnouncementFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [self loadUnreadAnnouncementsFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [self loadSentAnnouncementsFromServer];
        
    }
}

#pragma mark load all message
- (void)loadAnnouncementsFromCoredata {
    AnnouncementObject *lastAnnouncement = nil;
    NSArray *newData = nil;
    
    if ([announceArray count] > 0) {
        lastAnnouncement = [announceArray lastObject];   //last object is the oldest message in this array
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadAllAnnouncementsFromID:lastAnnouncement.announcementID toUserID:[[ShareData sharedShareData] userObj].userID];
        
        [announceArray addObjectsFromArray:newData];
        
    } else {
        newData = [[CoreDataUtil sharedCoreDataUtil] loadAllAnnouncementsFromID:0 toUserID:[[ShareData sharedShareData] userObj].userID];
        [announceArray addObjectsFromArray:newData];
        
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortAnnouncementsArrayByID:announceArray];

}

- (void)loadNewAnnouncementFromServer {
    AnnouncementObject *lastAnnouncement = nil;
    
    if ([announceArray count] > 0) {
        lastAnnouncement = [announceArray firstObject];  //the first object is the newest message in this array
        [requestToServer getAnnouncementsListToUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:lastAnnouncement.announcementID];
        
    } else {
        [requestToServer getAnnouncementsListToUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:0];
    }
}

#pragma mark load unread message
- (void)loadUnreadAnnouncementsFromCoredata {
    AnnouncementObject *lastAnnouncement = nil;
    NSArray *newData = nil;
    
    if ([unreadAnnouncementsArray count] > 0) {
        lastAnnouncement = [unreadAnnouncementsArray lastObject];
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadUnreadAnnouncementsFromID:lastAnnouncement.announcementID toUserID:[[ShareData sharedShareData] userObj].userID];
        [unreadAnnouncementsArray addObjectsFromArray:newData];
        
    } else {
        newData = [[CoreDataUtil sharedCoreDataUtil] loadUnreadAnnouncementsFromID:0 toUserID:[[ShareData sharedShareData] userObj].userID];
        [unreadAnnouncementsArray addObjectsFromArray:newData];
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortAnnouncementsArrayByID:unreadAnnouncementsArray];
}

- (void)loadUnreadAnnouncementsFromServer {
    //get last message
    AnnouncementObject *lastAnnouncement = nil;
    
    if ([unreadAnnouncementsArray count] > 0) {
        lastAnnouncement = [unreadAnnouncementsArray firstObject];
        [requestToServer getUnreadAnnouncementsListToUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:lastAnnouncement.announcementID];
        
    } else {
        [requestToServer getUnreadAnnouncementsListToUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:0];
    }
}

#pragma mark load all message
- (void)loadSentAnnouncementsFromCoredata {
    AnnouncementObject *lastAnnouncement = nil;
    NSArray *newData = nil;
    
    if ([sentAnnouncementsArray count] > 0) {
        lastAnnouncement = [sentAnnouncementsArray lastObject];
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadSentAnnouncementsFromID:lastAnnouncement.announcementID fromUserID:[[ShareData sharedShareData] userObj].userID];
        [sentAnnouncementsArray addObjectsFromArray:newData];
        
    } else {
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadSentAnnouncementsFromID:0 fromUserID:[[ShareData sharedShareData] userObj].userID];
        [sentAnnouncementsArray addObjectsFromArray:newData];
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortAnnouncementsArrayByID:sentAnnouncementsArray];
}

- (void)loadSentAnnouncementsFromServer {
    AnnouncementObject *lastAnnouncement = nil;
    
    if ([sentAnnouncementsArray count] > 0) {
        lastAnnouncement = [sentAnnouncementsArray firstObject];
        [requestToServer getSentAnnouncementsListFromUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:lastAnnouncement.announcementID];
        
    } else {
        [requestToServer getSentAnnouncementsListFromUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:0];
    }
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//
//    return @"";
//}

//- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
//
//    header.textLabel.textColor = [UIColor whiteColor];
//    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
//    CGRect headerFrame = header.frame;
//    header.textLabel.frame = headerFrame;
//    header.textLabel.textAlignment = NSTextAlignmentLeft;
//
//    header.backgroundView.backgroundColor = [UIColor darkGrayColor];
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [announceArray count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *announcementCellIdentifier = @"AnnouncementCellIdentifier";
    
    AnnouncementTableViewCell *cell = [announcementTableView dequeueReusableCellWithIdentifier:announcementCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnnouncementTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.delegate = (id)self;
    
    AnnouncementObject *announcementObjectObj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        announcementObjectObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        announcementObjectObj = [announceArray objectAtIndex:indexPath.row];
    }
    
    //    [dataDic setObject:wordObj forKey:wordObj.question];
    
    cell.tag = announcementObjectObj.announcementID;
    cell.lbSubject.text = announcementObjectObj.subject;
    cell.lbBriefContent.text = announcementObjectObj.content;
    cell.lbTime.text = announcementObjectObj.dateTime;
    cell.lbSenderName.text = announcementObjectObj.fromUsername;
    
    if (announcementObjectObj.importanceType == ImportanceHigh) {
        [cell.btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [cell.btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    
    if (announcementObjectObj.unreadFlag) {
        [cell.contentView setBackgroundColor:UNREAD_COLOR];
        [cell setBackgroundColor:UNREAD_COLOR];
    } else {
        [cell.contentView setBackgroundColor:READ_COLOR];
        [cell setBackgroundColor:READ_COLOR];
    }
    
    if (isReachToEnd == NO && [self isReachToBottom:indexPath.row]) {
        [self loadDataFromCoredata];
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AnnouncementObject *announcementObjectObj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        announcementObjectObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        announcementObjectObj = [announceArray objectAtIndex:indexPath.row];
    }
    
    CreatePostViewController *announcementDetailViewController = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
    announcementDetailViewController.isViewDetail = YES;
    announcementDetailViewController.announcementObject = announcementObjectObj;
    
    [self.navigationController pushViewController:announcementDetailViewController animated:YES];
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchString == nil || searchString.length == 0) {
        self->searchResults = [announceArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@", searchString];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [announceArray filteredArrayUsingPredicate:filterPredicate];
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

#pragma mark cell delegate
- (void)btnFlagClick:(id)sender {
    AnnouncementTableViewCell *cell = (AnnouncementTableViewCell *)sender;
    
    NSIndexPath *indexPath = [announcementTableView indexPathForCell:cell];
    AnnouncementObject *announcementObj = [announceArray objectAtIndex:indexPath.row];
    
    if (announcementObj.importanceType == ImportanceNormal) {
        announcementObj.importanceType = ImportanceHigh;
        
    } else {
        announcementObj.importanceType = ImportanceNormal;
    }
    
    [announcementTableView beginUpdates];
    [announcementTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [announcementTableView endUpdates];
}

- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    NSArray *announcements = [jsonObj objectForKey:@"list"];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    /*
     {
     channel = 1;
     "class_id" = 1;
     content = "test notify";
     "file_path" = "funny5.jpg";
     "file_url" = "http://192.168.0.202:9090/eschool_content/funny5.jpg";
     "file_zip" = "<null>";
     "from_usr_id" = 1;
     id = 5;
     "imp_flg" = 0;
     "is_read" = 1;
     "is_sent" = 1;
     other = nothing;
     "read_dt" = "2016-03-25 00:00:00.0";
     "school_id" = 1;
     "sent_dt" = "2016-03-25 00:00:00.0";
     "to_usr_id" = 2;
     },*/

    if (announcements != (id)[NSNull null]) {

        for (NSDictionary *announcementDict in announcements) {
            AnnouncementObject *announcementObj = [[AnnouncementObject alloc] init];
            
            if ([announcementDict valueForKey:@"id"] != (id)[NSNull null]) {
                announcementObj.announcementID = [[announcementDict valueForKey:@"id"] integerValue];
            }
            
            if ([announcementDict valueForKey:@"title"] != (id)[NSNull null]) {
                announcementObj.subject = [announcementDict valueForKey:@"title"];
            }
            
            if ([announcementDict valueForKey:@"content"] != (id)[NSNull null]) {
                announcementObj.content = [announcementDict valueForKey:@"content"];
            }

            if ([announcementDict valueForKey:@"from_usr_id"] != (id)[NSNull null]) {
                announcementObj.fromID = [NSString stringWithFormat:@"%@", [announcementDict valueForKey:@"from_usr_id"]];
            }
            
            if ([announcementDict valueForKey:@"from_user_name"] != (id)[NSNull null]) {
                announcementObj.fromUsername = [announcementDict valueForKey:@"from_user_name"];
            }
            
            if ([announcementDict valueForKey:@"to_usr_id"] != (id)[NSNull null]) {
                announcementObj.toID = [NSString stringWithFormat:@"%@", [announcementDict valueForKey:@"to_usr_id"]];
            }
            
            if ([announcementDict valueForKey:@"to_user_name"] != (id)[NSNull null]) {
                announcementObj.toUsername = [announcementDict valueForKey:@"to_user_name"];
            }
            
            if ([announcementDict valueForKey:@"is_read"] != (id)[NSNull null]) {
                announcementObj.unreadFlag = ![[announcementDict valueForKey:@"is_read"] boolValue];
            }
            
            if ([announcementDict valueForKey:@"imp_flg"] != (id)[NSNull null]) {
                if ([[announcementDict valueForKey:@"imp_flg"] boolValue] == YES) {
                    announcementObj.importanceType = ImportanceHigh;
                    
                } else {
                    announcementObj.importanceType = ImportanceNormal;
                }
            }
            
            if ([announcementDict valueForKey:@"sent_dt"] != (id)[NSNull null]) {
                announcementObj.dateTime = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:[announcementDict valueForKey:@"sent_dt" ] withFormat:@"dd-MM HH:mm"];
            }
            
            if ([announcementDict valueForKey:@"notifyImages"] != (id)[NSNull null]) {
                NSArray *photoArr = [announcementDict objectForKey:@"notifyImages"];
                
                if (photoArr && [photoArr count] > 0) {
                    for (NSDictionary *photoDict in photoArr) {
                        PhotoObject *phototObj = [[PhotoObject alloc] init];
                        
                        if ([photoDict valueForKey:@"id"] != (id)[NSNull null]) {
                            phototObj.photoID = [[photoDict valueForKey:@"id"] integerValue];
                        }
                        
                        if ([photoDict valueForKey:@"idx"] != (id)[NSNull null]) {
                            phototObj.order = [[photoDict valueForKey:@"idx"] integerValue];
                        }
                        
                        if ([photoDict valueForKey:@"caption"] != (id)[NSNull null]) {
                            phototObj.caption = [photoDict valueForKey:@"caption" ];
                        }
                        
                        if ([photoDict valueForKey:@"file_url"] != (id)[NSNull null]) {
                            phototObj.filePath = [photoDict valueForKey:@"file_url" ];
                        }
                        
                        [announcementObj.imgArray addObject:phototObj];
                    }
                    
                    [self sortPhotosArrayByID:announcementObj.imgArray];
                }
                
            }
            
            [newArr addObject:announcementObj];
        }
        
        if ([newArr count] > 0) {
            [self insertArrayToArray:newArr];
            
            dispatch_async([CoreDataUtil getDispatch], ^(){
                
                [[CoreDataUtil sharedCoreDataUtil] insertAnnouncementsArray:newArr];
            });
        }
        
        [self sortAnnouncementsArrayByID];
    }
    
    [announcementTableView reloadData];
}

- (void)insertArrayToArray:(NSArray *)arr {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [announceArray addObjectsFromArray:arr];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [unreadAnnouncementsArray addObjectsFromArray:arr];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [sentAnnouncementsArray addObjectsFromArray:arr];
        
    }
}

- (void)sortAnnouncementsArrayByID {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [self sortAnnouncementsArrayByID:announceArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [self sortAnnouncementsArrayByID:unreadAnnouncementsArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [self sortAnnouncementsArrayByID:sentAnnouncementsArray];
        
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

- (void)sortAnnouncementsArrayByID:(NSMutableArray *)announcementArr {
    NSSortDescriptor *announcementID = [NSSortDescriptor sortDescriptorWithKey:@"announcementID" ascending:NO];
    NSArray *resultArr = [announcementArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:announcementID, nil]];
    
    [announcementArr removeAllObjects];
    [announcementArr addObjectsFromArray:resultArr];
}

- (void)sortPhotosArrayByID:(NSMutableArray *)photoArr {
    NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *resultArr = [photoArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:orderSort, nil]];
    
    [photoArr removeAllObjects];
    [photoArr addObjectsFromArray:resultArr];
}
@end
