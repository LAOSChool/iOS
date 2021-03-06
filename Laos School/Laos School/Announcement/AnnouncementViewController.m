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
    BOOL isNoMoreFromServer;
    UIRefreshControl *refreshControl;
    NSIndexPath *selectedIndex;
}
@end

@implementation AnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationColor];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setTitle:LocalizedString(@"Announcements")];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = (id)self;
    
    self.searchController.searchBar.delegate = (id)self;
    self.searchController.delegate = (id)self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    
    announcementTableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    [self.searchController.searchBar setPlaceholder:LocalizedString(@"Search")];
    
    isReachToEnd = NO;
    isNoMoreFromServer = NO;
    selectedIndex = nil;
    
    if (([ShareData sharedShareData].userObj.permission & Permission_SendAnnouncement) == Permission_SendAnnouncement) {
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(addNewAnnouncement)];
        
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
                                             selector:@selector(refreshAfterUpdateFlag:)
                                                 name:@"RefreshAnnouncementAfterUpdateFlag"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadDataFromServer)
                                                 name:@"DidReceiveRemoteNotification"
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
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

- (void)refreshAfterUpdateFlag:(NSNotification *)notification {
    AnnouncementObject *announcementObj = (AnnouncementObject *)notification.object;
    
    [self updateAnnouncementArrayWithObject:announcementObj];
    
    [announcementTableView reloadData];
}

- (void)updateAnnouncementArrayWithObject:(AnnouncementObject *)announcementObj {
    for (AnnouncementObject *ann in announceArray) {
        if (ann.announcementID == announcementObj.announcementID) {
            ann.unreadFlag = announcementObj.unreadFlag;
            ann.importanceType = announcementObj.importanceType;
            break;
        }
    }
    
    for (AnnouncementObject *ann in unreadAnnouncementsArray) {
        if (ann.announcementID == announcementObj.announcementID) {
            ann.unreadFlag = announcementObj.unreadFlag;
            ann.importanceType = announcementObj.importanceType;
            
            if (ann.unreadFlag == 0) {
                [unreadAnnouncementsArray removeObject:ann];
            }
            break;
        }
    }
    
    for (AnnouncementObject *ann in sentAnnouncementsArray) {
        if (ann.announcementID == announcementObj.announcementID) {
            ann.unreadFlag = announcementObj.unreadFlag;
            ann.importanceType = announcementObj.importanceType;
            break;
        }
    }
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

- (AnnouncementObject *)getLastAnnouncementFromArray:(NSArray *)announcementArr {
    if ([announcementArr count] > 0) {
        NSMutableArray *tmps = [[NSMutableArray alloc] initWithArray:announcementArr];
        
        NSSortDescriptor *announcementID = [NSSortDescriptor sortDescriptorWithKey:@"announcementID" ascending:NO];
        [tmps sortUsingDescriptors:[NSArray arrayWithObjects:announcementID, nil]];
        
        return [tmps firstObject];
    }
    
    return nil;
}

#pragma mark load all message
- (void)loadAnnouncementsFromCoredata {
    AnnouncementObject *lastAnnouncement = nil;
    NSArray *newData = nil;
    
    if ([announceArray count] > 0) {
        lastAnnouncement = [announceArray lastObject];   //last object is the oldest message in this array
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadAllAnnouncementsFromID:lastAnnouncement.announcementID toUserID:[[ShareData sharedShareData] userObj].userID];
        
        if (newData && [newData count] > 0) {
            [announceArray addObjectsFromArray:newData];
        }
        
    } else {
        newData = [[CoreDataUtil sharedCoreDataUtil] loadAllAnnouncementsFromID:0 toUserID:[[ShareData sharedShareData] userObj].userID];
        
        if (newData && [newData count] > 0) {
            [announceArray addObjectsFromArray:newData];
        }
        
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortAnnouncementsArrayByDateTime:announceArray];

}

- (void)loadNewAnnouncementFromServer {
    AnnouncementObject *lastAnnouncement = nil;
    
    if ([announceArray count] > 0) {
        lastAnnouncement = [self getLastAnnouncementFromArray:announceArray];  //the first object is the newest announcement in this array
        
        if (lastAnnouncement) {
            [requestToServer getAnnouncementsListToUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:lastAnnouncement.announcementID];
            
        } else {
            [SVProgressHUD dismiss];
        }
        
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
        
        if (newData && [newData count] > 0) {
            [unreadAnnouncementsArray addObjectsFromArray:newData];
        }
        
    } else {
        newData = [[CoreDataUtil sharedCoreDataUtil] loadUnreadAnnouncementsFromID:0 toUserID:[[ShareData sharedShareData] userObj].userID];
        
        if (newData && [newData count] > 0) {
            [unreadAnnouncementsArray addObjectsFromArray:newData];
        }
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortAnnouncementsArrayByDateTime:unreadAnnouncementsArray];
}

- (void)loadUnreadAnnouncementsFromServer {
    //get last message
    AnnouncementObject *lastAnnouncement = nil;
    
    if ([unreadAnnouncementsArray count] > 0) {
        lastAnnouncement = [self getLastAnnouncementFromArray:unreadAnnouncementsArray];  //the first object is the newest announcement in this array
        
        if (lastAnnouncement) {
            [requestToServer getUnreadAnnouncementsListToUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:lastAnnouncement.announcementID];
            
        } else {
            [SVProgressHUD dismiss];
        }
        
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
        
        if (newData && [newData count] > 0) {
            [sentAnnouncementsArray addObjectsFromArray:newData];
        }
        
    } else {
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadSentAnnouncementsFromID:0 fromUserID:[[ShareData sharedShareData] userObj].userID];
        
        if (newData && [newData count] > 0) {
            [sentAnnouncementsArray addObjectsFromArray:newData];
        }
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortAnnouncementsArrayByDateTime:sentAnnouncementsArray];
}

- (void)loadSentAnnouncementsFromServer {
    AnnouncementObject *lastAnnouncement = nil;
    
    if ([sentAnnouncementsArray count] > 0) {
        lastAnnouncement = [self getLastAnnouncementFromArray:sentAnnouncementsArray];  //the first object is the newest announcement in this array
        
        if (lastAnnouncement) {
            [requestToServer getSentAnnouncementsListFromUser:[[ShareData sharedShareData] userObj].userID fromAnnouncementID:lastAnnouncement.announcementID];
            
        } else {
            [SVProgressHUD dismiss];
        }
        
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
    
    if (self.searchController.active && self.searchController.searchBar.text.length > 0 ) {
        return [searchResults count];
        
    } else {
        return [self getCountAnnouncements];
    }
}

- (NSInteger)getCountAnnouncements {
    NSInteger res = 0;
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        res = [announceArray count];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        res = [unreadAnnouncementsArray count];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        res = [sentAnnouncementsArray count];
        
    }
    
    return res;
}

- (AnnouncementObject *)getAnnouncementObjectAtIndex:(NSInteger)index {
    AnnouncementObject *announcementObj = nil;
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        if ([announceArray count] > 0) {
            announcementObj = [announceArray objectAtIndex:index];
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        if ([unreadAnnouncementsArray count] > 0) {
            announcementObj = [unreadAnnouncementsArray objectAtIndex:index];
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        if ([sentAnnouncementsArray count] > 0) {
            announcementObj = [sentAnnouncementsArray objectAtIndex:index];
        }
    }
    
    return announcementObj;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *announcementCellIdentifier = @"AnnouncementTableViewCell";
    
    AnnouncementTableViewCell *cell = [announcementTableView dequeueReusableCellWithIdentifier:announcementCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"AnnouncementTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.delegate = (id)self;
    [cell.lbSubject setTextColor:TITLE_COLOR];
    
    AnnouncementObject *announcementObject = nil;
    if ([searchResults count] > 0) {
        announcementObject = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        announcementObject = [self getAnnouncementObjectAtIndex:indexPath.row];
    }
    
    //    [dataDic setObject:wordObj forKey:wordObj.question];
    
    cell.tag = announcementObject.announcementID;
    cell.lbSubject.text = announcementObject.subject;
    cell.lbBriefContent.text = announcementObject.content;
    
    if (announcementObject.dateTime && announcementObject.dateTime.length > 0) {
        cell.lbTime.text = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:announcementObject.dateTime withFormat:@"dd-MM HH:mm"];
    }
    
    cell.lbSenderName.text = announcementObject.fromUsername;
    
    if (announcementObject.importanceType == ImportanceHigh) {
        [cell.btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [cell.btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    
    if (announcementObject.unreadFlag) {
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
    
    if (!IS_IPAD) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    selectedIndex = indexPath;
    
    AnnouncementObject *announcementObject = nil;
    if ([searchResults count] > 0) {
        announcementObject = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        announcementObject = [self getAnnouncementObjectAtIndex:indexPath.row];
    }
    
    if (announcementObject.unreadFlag == YES) {
        [[CoreDataUtil sharedCoreDataUtil] updateAnnouncementRead:announcementObject.announcementID withFlag:YES];
        [requestToServer updateAnnouncementRead:announcementObject.announcementID withFlag:YES];
        
        announcementObject.unreadFlag = NO;
        [announcementTableView beginUpdates];
        [announcementTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [announcementTableView endUpdates];
    }
    
    [self updateAnnouncementArrayWithObject:announcementObject];
    
    [self showDetailView:announcementObject];
    
}

#pragma mark cell delegate
- (void)btnFlagClick:(id)sender {
    AnnouncementTableViewCell *cell = (AnnouncementTableViewCell *)sender;
    
    NSIndexPath *indexPath = [announcementTableView indexPathForCell:cell];
    AnnouncementObject *announcementObj = [self getAnnouncementObjectAtIndex:indexPath.row];
    
    if (announcementObj.importanceType == ImportanceNormal) {
        announcementObj.importanceType = ImportanceHigh;
        [[CoreDataUtil sharedCoreDataUtil] updateAnnouncementImportance:announcementObj.announcementID withFlag:YES];
        [requestToServer updateAnnouncementImportance:announcementObj.announcementID withFlag:YES];
        
    } else {
        announcementObj.importanceType = ImportanceNormal;
        [[CoreDataUtil sharedCoreDataUtil] updateAnnouncementImportance:announcementObj.announcementID withFlag:NO];
        [requestToServer updateAnnouncementImportance:announcementObj.announcementID withFlag:NO];
        
    }
    
    [announcementTableView beginUpdates];
    [announcementTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [announcementTableView endUpdates];
    
    [self updateAnnouncementArrayWithObject:announcementObj];
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
     "from_user_id" = 1;
     id = 5;
     "imp_flg" = 0;
     "is_read" = 1;
     "is_sent" = 1;
     other = nothing;
     "read_dt" = "2016-03-25 00:00:00.0";
     "school_id" = 1;
     "sent_dt" = "2016-03-25 00:00:00.0";
     "to_user_id" = 2;
     },*/

    if (announcements != (id)[NSNull null]) {

        for (NSDictionary *announcementDict in announcements) {
            AnnouncementObject *announcementObj = [[AnnouncementObject alloc] init];
            
            if ([announcementDict valueForKey:@"id"] != (id)[NSNull null]) {
                announcementObj.announcementID = [[announcementDict valueForKey:@"id"] integerValue];
            }
            
            if ([announcementDict valueForKey:@"title"] != (id)[NSNull null]) {
                announcementObj.subject = [self decodeString:[announcementDict valueForKey:@"title"]];
            }
            
            if ([announcementDict valueForKey:@"content"] != (id)[NSNull null]) {

                announcementObj.content = [self decodeString:[announcementDict valueForKey:@"content"]];
            }

            if ([announcementDict valueForKey:@"from_user_id"] != (id)[NSNull null]) {
                announcementObj.fromID = [NSString stringWithFormat:@"%@", [announcementDict valueForKey:@"from_user_id"]];
            }
            
            if ([announcementDict valueForKey:@"from_user_name"] != (id)[NSNull null]) {
                announcementObj.fromUsername = [announcementDict valueForKey:@"from_user_name"];
            }
            
            if ([announcementDict valueForKey:@"to_user_id"] != (id)[NSNull null]) {
                announcementObj.toID = [NSString stringWithFormat:@"%@", [announcementDict valueForKey:@"to_user_id"]];
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
                announcementObj.dateTime = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:[announcementDict valueForKey:@"sent_dt" ] withFormat:@"dd-MM-yyyy HH:mm:ss.SSS"];
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
                            phototObj.caption = [self decodeString:[photoDict valueForKey:@"caption"]];
                        }
                        
                        if ([photoDict valueForKey:@"file_url"] != (id)[NSNull null]) {
                            phototObj.filePath = [photoDict valueForKey:@"file_url" ];
                        }
                        
                        [announcementObj.imgArray addObject:phototObj];
                    }
                    
                    [self sortPhotosArrayByOrder:announcementObj.imgArray];
                }
                
            }
            
            [newArr addObject:announcementObj];
        }
        
        if ([newArr count] > 0) {
            isNoMoreFromServer = NO;
            [self insertArrayToArray:newArr];
            
            dispatch_async([CoreDataUtil getDispatch], ^(){
                
                [[CoreDataUtil sharedCoreDataUtil] insertAnnouncementsArray:newArr];
            });
            
        } else {
            isNoMoreFromServer = YES;
        }
        
        [self sortAnnouncementsArrayByDateTime];
        
        if (isNoMoreFromServer == NO) {
            [self loadDataFromServer];
            
        }
        
    } else {
        isNoMoreFromServer = YES;
    }
    
    if (IS_IPAD) {
        if (selectedIndex == nil) {
            AnnouncementObject *announcementObject = [self getAnnouncementObjectAtIndex:0];
            if (announcementObject) {
                [self showDetailView:announcementObject];
                
                selectedIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            }
        }
    }
    
    [announcementTableView reloadData];
}

- (void)showDetailView:(AnnouncementObject *)announcementObject {
    CreatePostViewController *announcementDetailViewController = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
    announcementDetailViewController.isViewDetail = YES;
    announcementDetailViewController.announcementObject = announcementObject;
    
    if (IS_IPAD) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:announcementDetailViewController];
        [self showDetailViewController:nav sender:self];
        
    } else {
        [self.navigationController pushViewController:announcementDetailViewController animated:YES];
    }
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

- (void)sortAnnouncementsArrayByDateTime {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [self sortAnnouncementsArrayByDateTime:announceArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [self sortAnnouncementsArrayByDateTime:unreadAnnouncementsArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [self sortAnnouncementsArrayByDateTime:sentAnnouncementsArray];
        
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

- (void)sortAnnouncementsArrayByDateTime:(NSMutableArray *)announcementArr {
    NSSortDescriptor *announcementDateTime = [NSSortDescriptor sortDescriptorWithKey:@"sortByDateTime" ascending:NO];
    NSSortDescriptor *announcementID = [NSSortDescriptor sortDescriptorWithKey:@"announcementID" ascending:NO];
    
    NSArray *resultArr = [announcementArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:announcementDateTime, announcementID, nil]];
    
    [announcementArr removeAllObjects];
    [announcementArr addObjectsFromArray:resultArr];
}

- (void)sortPhotosArrayByOrder:(NSMutableArray *)photoArr {
    NSSortDescriptor *orderSort = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];
    NSArray *resultArr = [photoArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:orderSort, nil]];
    
    [photoArr removeAllObjects];
    [photoArr addObjectsFromArray:resultArr];
}

- (NSString *)decodeString:(NSString *)myString {
    NSData *newdata = [myString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSString *res = [[NSString alloc] initWithData:newdata encoding:NSNonLossyASCIIStringEncoding];
    
    if (res == nil) {
        res = myString;
    }
    
    return res;
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}


#pragma mark - UISearchControllerDelegate

// Called after the search controller's search bar has agreed to begin editing or when
// 'active' is set to YES.
// If you choose not to present the controller yourself or do not implement this method,
// a default presentation is performed on your behalf.
//
// Implement this method if the default presentation is not adequate for your purposes.
//
- (void)presentSearchController:(UISearchController *)searchController {
    
}

- (void)willPresentSearchController:(UISearchController *)searchController {
    // do something before the search controller is presented
    searchController.searchBar.showsCancelButton = YES;
    
    for (UIView *subView in searchController.searchBar.subviews){
        for (UIView *subView2 in subView.subviews){
            if([subView2 isKindOfClass:[UIButton class]]){
                [(UIButton*)subView2 setTitle:LocalizedString(@"Cancel") forState:UIControlStateNormal];
            }
        }
    }
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    // do something after the search controller is presented
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    // do something after the search controller is dismissed
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchString = self.searchController.searchBar.text;
    
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    NSArray *currentArr = [self currentAnnouncementArray];
    
    if (searchString == nil || searchString.length == 0) {
        self->searchResults = [currentArr mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@ OR fromUsername CONTAINS[cd] %@ OR toUsername CONTAINS[cd] %@", searchString, searchString, searchString];

        NSArray *filterKeys = [currentArr filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    [announcementTableView reloadData];
}


- (NSArray *)currentAnnouncementArray {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        return announceArray;
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        return unreadAnnouncementsArray;
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        return sentAnnouncementsArray;
        
    }
    
    return [[NSMutableArray alloc] init];
}

@end
