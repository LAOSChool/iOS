//
//  MessagesViewController.m
//  Laos School
//
//  Created by HuKhong on 2/29/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "MessagesViewController.h"
#import "MessageObject.h"
#import "MessageTableViewCell.h"
#import "MessageDetailViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "ComposeViewController.h"
#import "MessagesConversationViewController.h"

#import "LocalizeHelper.h"
#import "SVProgressHUD.h"
#import "RequestToServer.h"

#import "ShareData.h"
#import "Common.h"
#import "CoreDataUtil.h"

@interface MessagesViewController ()
{
    NSMutableArray *messagesArray;
    NSMutableArray *unreadMessagesArray;
    NSMutableArray *sentMessagesArray;
    NSMutableArray *searchResults;
    
    RequestToServer *requestToServer;
    
    UISegmentedControl *segmentedControl;
    
    BOOL isReachToEnd;
    BOOL isNoMoreFromServer;
    UIRefreshControl *refreshControl;
    NSIndexPath *selectedIndex;
}

@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:LocalizedString(@"Messages")];
    [self.navigationController setNavigationColor];
//    self.edgesForExtendedLayout = UIRectEdgeNone;

//    [self.searchDisplayController.searchBar setPlaceholder:LocalizedString(@"Search")];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = (id)self;

    self.searchController.searchBar.delegate = (id)self;
    self.searchController.delegate = (id)self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    
    messagesTableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    [self.searchController.searchBar sizeToFit];
    [self.searchController.searchBar setPlaceholder:LocalizedString(@"Search")];
    
    isReachToEnd = NO;
    isNoMoreFromServer = NO;
    selectedIndex = nil;
    
    if (([ShareData sharedShareData].userObj.permission & Permission_SendMessage) == Permission_SendMessage) {
        
        UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeNewMessage)];
        
        self.navigationItem.rightBarButtonItems = @[composeButton];
    }
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:LocalizedString(@"All"), LocalizedString(@"Unread"), LocalizedString(@"Sent"),
                                             nil]];
    segmentedControl.frame = CGRectMake(0, 0, 210, 30);
    [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:2];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segmentedControl;
    
    if (searchResults == nil) {
        searchResults = [[NSMutableArray alloc] init];
    }
    
    if (messagesArray == nil) {
        messagesArray = [[NSMutableArray alloc] init];
    }
    
    if (unreadMessagesArray == nil) {
        unreadMessagesArray = [[NSMutableArray alloc] init];
    }
    
    if (sentMessagesArray == nil) {
        sentMessagesArray = [[NSMutableArray alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadDataFromServer) forControlEvents:UIControlEventValueChanged];
    [messagesTableView addSubview:refreshControl];
    
    //Load data
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAfterSentNewMessage)
                                                 name:@"SentNewMessage"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAfterUpdateFlag:)
                                                 name:@"RefreshMessageAfterUpdateFlag"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshAfterSentNewMessage)
                                                 name:@"DidReceiveRemoteNotification"
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

- (void)refreshAfterUpdateFlag:(NSNotification *)notification {
    MessageObject *messageObj = (MessageObject *)notification.object;
    
    [self updateMessageArrayWithObject:messageObj];
    [messagesTableView reloadData];
}

- (void)updateMessageArrayWithObject:(MessageObject *)messageObj {
    for (MessageObject *m in messagesArray) {
        if (m.messageID == messageObj.messageID) {
            m.unreadFlag = messageObj.unreadFlag;
            m.importanceType = messageObj.importanceType;
            break;
        }
    }
    
    for (MessageObject *m in unreadMessagesArray) {
        if (m.messageID == messageObj.messageID) {
            m.unreadFlag = messageObj.unreadFlag;
            m.importanceType = messageObj.importanceType;
            
            if (m.unreadFlag == 0) {
                [unreadMessagesArray removeObject:m];
            }
            break;
        }
    }
    
    for (MessageObject *m in sentMessagesArray) {
        if (m.messageID == messageObj.messageID) {
            m.unreadFlag = messageObj.unreadFlag;
            m.importanceType = messageObj.importanceType;
            break;
        }
    }
}

- (void)refreshAfterSentNewMessage {
    [self loadDataFromServer];
}

- (void)loadData {
    [SVProgressHUD show];
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        //load data from local coredata
        [self loadMessagesFromCoredata];
        
        [self loadNewMessageFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        //load data from local coredata
        [self loadUnreadMessagesFromCoredata];
        
        [self loadUnreadMessageFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        //load data from local coredata
        [self loadSentMessagesFromCoredata];
        
        [self loadSentMessageFromServer];
        
    }
}

- (BOOL)isReachToBottom:(NSInteger)row {
    BOOL res = NO;
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        if (row == [messagesArray count] - 1) {
            res = YES;
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        if (row == [unreadMessagesArray count] - 1) {
            res = YES;
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        if (row == [sentMessagesArray count] - 1) {
            res = YES;
        }
        
    }
    
    return res;
}

//load from coredata with the limitation 30 per time
- (void)loadDataFromCoredata {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        //load data from local coredata
        [self loadMessagesFromCoredata];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        //load data from local coredata
        [self loadUnreadMessagesFromCoredata];

    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        //load data from local coredata
        [self loadSentMessagesFromCoredata];
    }
    
    [messagesTableView reloadData];
}

- (void)loadDataFromServer {
    [SVProgressHUD show];
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [self loadNewMessageFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [self loadUnreadMessageFromServer];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [self loadSentMessageFromServer];
        
    }
}

- (MessageObject *)getLastMessageFromArray:(NSArray *)messArr {
    if ([messArr count] > 0) {
        NSMutableArray *tmps = [[NSMutableArray alloc] initWithArray:messArr];
        
        NSSortDescriptor *messageID = [NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:NO];
        [tmps sortUsingDescriptors:[NSArray arrayWithObjects:messageID, nil]];
        
        return [tmps firstObject];
    }

    return nil;
}

#pragma mark load all message
- (void)loadMessagesFromCoredata {
    MessageObject *lastMessage = nil;
    NSArray *newData = nil;
    
    if ([messagesArray count] > 0) {
        lastMessage = [messagesArray lastObject];   //last object is the oldest message in this array
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadAllMessagesFromID:lastMessage.messageID toUserID:[[ShareData sharedShareData] userObj].userID];
        
        [messagesArray addObjectsFromArray:newData];
        
    } else {
        newData = [[CoreDataUtil sharedCoreDataUtil] loadAllMessagesFromID:0 toUserID:[[ShareData sharedShareData] userObj].userID];
        [messagesArray addObjectsFromArray:newData];

    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortMessagesArrayByDateTime:messagesArray];
}

- (void)loadNewMessageFromServer {
    //get last message
    MessageObject *lastMessage = nil;
    
    if ([messagesArray count] > 0) {
        lastMessage = [self getLastMessageFromArray:messagesArray];  //the first object is the newest message in this array
        
        if (lastMessage) {
            [requestToServer getMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:lastMessage.messageID];
            
        } else {
            [SVProgressHUD dismiss];
        }
        
    } else {
        [requestToServer getMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:0];
    }
}

#pragma mark load unread message
- (void)loadUnreadMessagesFromCoredata {
    MessageObject *lastMessage = nil;
    NSArray *newData = nil;
    
    if ([unreadMessagesArray count] > 0) {
        lastMessage = [unreadMessagesArray lastObject];
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadUnreadMessagesFromID:lastMessage.messageID toUserID:[[ShareData sharedShareData] userObj].userID];
        [unreadMessagesArray addObjectsFromArray:newData];
        
    } else {
        newData = [[CoreDataUtil sharedCoreDataUtil] loadUnreadMessagesFromID:0 toUserID:[[ShareData sharedShareData] userObj].userID];
        [unreadMessagesArray addObjectsFromArray:newData];
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortMessagesArrayByDateTime:unreadMessagesArray];
}

- (void)loadUnreadMessageFromServer {
    //get last message
    MessageObject *lastMessage = nil;
    
    if ([unreadMessagesArray count] > 0) {
        lastMessage = [self getLastMessageFromArray:unreadMessagesArray];  //the first object is the newest message in this array
        
        if (lastMessage) {
            [requestToServer getUnreadMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:lastMessage.messageID];
            
        } else {
            [SVProgressHUD dismiss];
        }
        
    } else {
        [requestToServer getUnreadMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:0];
    }
}

#pragma mark load sent message
- (void)loadSentMessagesFromCoredata {
    MessageObject *lastMessage = nil;
    NSArray *newData = nil;
    
    if ([sentMessagesArray count] > 0) {
        lastMessage = [sentMessagesArray lastObject];
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadSentMessagesFromID:lastMessage.messageID fromUserID:[[ShareData sharedShareData] userObj].userID];
        [sentMessagesArray addObjectsFromArray:newData];
        
    } else {
        
        newData = [[CoreDataUtil sharedCoreDataUtil] loadSentMessagesFromID:0 fromUserID:[[ShareData sharedShareData] userObj].userID];
        [sentMessagesArray addObjectsFromArray:newData];
    }
    
    if ([newData count] == 0) {
        isReachToEnd = YES;
    }
    
    [self sortMessagesArrayByDateTime:sentMessagesArray];
}

- (void)loadSentMessageFromServer {
    //get last message
    MessageObject *lastMessage = nil;
    
    if ([sentMessagesArray count] > 0) {
        lastMessage = [self getLastMessageFromArray:sentMessagesArray];  //the first object is the newest message in this array
        
        if (lastMessage) {
            [requestToServer getSentMessageListFromUser:[[ShareData sharedShareData] userObj].userID fromMessageID:lastMessage.messageID];
            
        } else {
            [SVProgressHUD dismiss];
        }
        
    } else {
        [requestToServer getSentMessageListFromUser:[[ShareData sharedShareData] userObj].userID fromMessageID:0];
    }
}

- (IBAction)segmentAction:(id)sender {
    isReachToEnd = NO;
    [messagesTableView reloadData];
    [self loadData];
}

- (void)composeNewMessage {
    ComposeViewController *composeViewController = nil;
    
    if ([ShareData sharedShareData].userObj.userRole == UserRole_Student) {
        composeViewController = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
        composeViewController.isTeacherForm = NO;
        composeViewController.composeType = MessageCompose_Normal;
        
    } else {
        composeViewController = [[ComposeViewController alloc] initWithNibName:@"TeacherComposeViewController" bundle:nil];
        composeViewController.isTeacherForm = YES;
        composeViewController.composeType = MessageCompose_Normal;
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

    return @"";
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;

    header.textLabel.textColor = [UIColor whiteColor];
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
    CGRect headerFrame = header.frame;
    header.textLabel.frame = headerFrame;
    header.textLabel.textAlignment = NSTextAlignmentLeft;

    header.backgroundView.backgroundColor = [UIColor darkGrayColor];
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    if (self.searchController.active && self.searchController.searchBar.text.length > 0 ) {
        return [searchResults count];
        
    } else {
        return [self getCountMessages];
    }
}

- (NSInteger)getCountMessages {
    NSInteger res = 0;
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        res = [messagesArray count];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        res = [unreadMessagesArray count];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        res = [sentMessagesArray count];
        
    }
    
    return res;
}

- (MessageObject *)getMessageObjectAtIndex:(NSInteger)index {
    MessageObject *messageObj = nil;
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        if ([messagesArray count] > 0) {
            messageObj = [messagesArray objectAtIndex:index];
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        if ([unreadMessagesArray count] > 0) {
            messageObj = [unreadMessagesArray objectAtIndex:index];
        }
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        if ([sentMessagesArray count] > 0) {
            messageObj = [sentMessagesArray objectAtIndex:index];
        }
    }
    
    return messageObj;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *messageCellIdentifier = @"MessageTableViewCell";
    
    MessageTableViewCell *cell = [messagesTableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.delegate = (id)self;
    [cell.lbSubject setTextColor:TITLE_COLOR];
    [cell.lbSenderName setTextColor:TITLE_COLOR];
    
    MessageObject *messageObj = nil;
    if ([searchResults count] > 0) {
        messageObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        messageObj = [self getMessageObjectAtIndex:indexPath.row];
    }
    
    //    [dataDic setObject:wordObj forKey:wordObj.question];
    
    if (messageObj.messageID) {
        cell.tag = messageObj.messageID;
    }
    
    if (messageObj.subject) {
        cell.lbSubject.text = messageObj.subject;
    }
    
    if (messageObj.content) {
        cell.lbBriefContent.text = [NSString stringWithFormat:@"%@\n", messageObj.content];
    }
    
    //for test
  //  cell.lbBriefContent.text = @"Solo cùng Bolero đã quay trở lại, quy mô hơn, hoành tráng hơn, sân khấu sang trọng trang nhã, được đầu tư kỹ lưỡng về âm thanh, ánh sáng. Hãy cùng chờ đón không gian âm nhạc sang trọng và trữ tình của Solo cùng Bolero lúc 21h thứ sáu hàng tuần trên kênh THVL 1";
    
    if (messageObj.dateTime && messageObj.dateTime.length > 0) {
        //messageObj.dateTime
        cell.lbTime.text = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:messageObj.dateTime withFormat:@"dd-MM HH:mm"];
    }
    //for test
//    cell.lbTime.text = @"05-25 15:27";
    
    if (messageObj.fromUsername) {
        if (segmentedControl.selectedSegmentIndex == 2) {   //sent tab
            cell.lbSenderName.text = messageObj.toUsername;
        } else {
            cell.lbSenderName.text = messageObj.fromUsername;
        }
    }
    
    //set message type icon and importance icon
    
    if (messageObj.messageTypeIcon) {
    //    cell.imgMesseageType.image = [[Common sharedCommon] imageFromText:messageObj.messageTypeIcon withColor:GREEN_COLOR];
    }
    
    if (messageObj.importanceType == ImportanceHigh) {
        [cell.btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [cell.btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    cell.imgMesseageType.image = [UIImage imageNamed:@"ic_user_gray.png"];
    
    if (segmentedControl.selectedSegmentIndex == 2) {   //sent tab
        
        if (messageObj.receiverAvatar && messageObj.receiverAvatar.length > 0) {
            //cancel loading previous image for cell
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgMesseageType];
            
            //load the image
            cell.imgMesseageType.imageURL = [NSURL URLWithString:messageObj.receiverAvatar];
            
        } else {
            cell.imgMesseageType.image = [UIImage imageNamed:@"ic_user_gray.png"];
        }
        
        [cell.contentView setBackgroundColor:READ_COLOR];
        [cell setBackgroundColor:READ_COLOR];
        
    } else {
        
        if (messageObj.unreadFlag) {
            [cell.contentView setBackgroundColor:UNREAD_COLOR];
            [cell setBackgroundColor:UNREAD_COLOR];
        } else {
            [cell.contentView setBackgroundColor:READ_COLOR];
            [cell setBackgroundColor:READ_COLOR];
        }
        
        if (messageObj.senderAvatar && messageObj.senderAvatar.length > 0) {
            //cancel loading previous image for cell
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:cell.imgMesseageType];
            
            //load the image
            cell.imgMesseageType.imageURL = [NSURL URLWithString:messageObj.senderAvatar];
            
        } else {
            cell.imgMesseageType.image = [UIImage imageNamed:@"ic_user_gray.png"];
        }
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
    
    MessageObject *messageObj = nil;
    if ([searchResults count] > 0) {
        messageObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        messageObj = [self getMessageObjectAtIndex:indexPath.row];
    }
    
    if (segmentedControl.selectedSegmentIndex != 2) {   //# sent tab
        if (messageObj.unreadFlag == YES) {
            [[CoreDataUtil sharedCoreDataUtil] updateMessageRead:messageObj.messageID withFlag:YES];
            [requestToServer updateMessageRead:messageObj.messageID withFlag:YES];
            
            messageObj.unreadFlag = NO;
            
            if (segmentedControl.selectedSegmentIndex != 1) { //unread tab
                [messagesTableView beginUpdates];
                [messagesTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [messagesTableView endUpdates];
            }
        }
    }
    
    [self updateMessageArrayWithObject:messageObj];
    
    //not good but it's the easiest way to fix bug
    if (segmentedControl.selectedSegmentIndex == 1) { //unread tab
        [messagesTableView beginUpdates];
        [messagesTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [messagesTableView endUpdates];
    }
    
    [self showDetailView:messageObj];
    
//    MessagesConversationViewController *vc = [MessagesConversationViewController messagesViewController];
//    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)showDetailView:(MessageObject *)messageObj {
    MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewController" bundle:nil];
    messageDetailViewController.messageObject = messageObj;
    if (segmentedControl.selectedSegmentIndex == 2) {
        messageDetailViewController.isIncomeMessage = NO;
        
    } else {
        messageDetailViewController.isIncomeMessage = YES;
    }
    
    if (IS_IPAD) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:messageDetailViewController];
        [self showDetailViewController:nav sender:self];
        
    } else {
        [self.navigationController pushViewController:messageDetailViewController animated:YES];
    }
}

/*
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
*/
#pragma mark cell delegate
- (void)btnFlagClick:(id)sender {
    MessageTableViewCell *cell = (MessageTableViewCell *)sender;
    
    NSIndexPath *indexPath = [messagesTableView indexPathForCell:cell];
    MessageObject *messageObj = [self getMessageObjectAtIndex:indexPath.row];
    
    if (messageObj.importanceType == ImportanceNormal) {
        messageObj.importanceType = ImportanceHigh;
        [[CoreDataUtil sharedCoreDataUtil] updateMessageImportance:messageObj.messageID withFlag:YES];
        [requestToServer updateMessageImportance:messageObj.messageID withFlag:YES];
        
    } else {
        messageObj.importanceType = ImportanceNormal;
        [[CoreDataUtil sharedCoreDataUtil] updateMessageImportance:messageObj.messageID withFlag:NO];
        [requestToServer updateMessageImportance:messageObj.messageID withFlag:NO];
    }
    
    [messagesTableView beginUpdates];
    [messagesTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [messagesTableView endUpdates];
    
    [self updateMessageArrayWithObject:messageObj];
}


#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if (url && [url rangeOfString:API_NAME_UPDATEMESSAGE].location != NSNotFound) {
        return;
    }
    
    NSArray *messages = [jsonObj objectForKey:@"list"];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    /*
     {
     channel = 1;
     "class_id" = 1;
     content = "test message";
     "from_user_name" = NamNT1;
     "from_user_id" = 1;
     id = 1;
     "imp_flg" = 1;
     "is_read" = 1;
     "is_sent" = 1;
     messageType = NX;
     "msg_type_id" = 1;
     other = "ko co gi quan trong";
     "read_dt" = "2016-03-24 00:00:00.0";
     schoolName = "Truong Tieu Hoc Thanh Xuan Trung";
     "school_id" = 1;
     "sent_dt" = "2016-03-24 00:00:00.0";
     title = title;
     "to_user_name" = Hue1;
     "to_user_id" = 2;
     }
     
     },*/

    if (messages != (id)[NSNull null]) {

        for (NSDictionary *messageDict in messages) {
            MessageObject *messObj = [[MessageObject alloc] init];
            
            if ([messageDict valueForKey:@"id"] != (id)[NSNull null]) {
                messObj.messageID = [[messageDict valueForKey:@"id"] integerValue];
            }
            
            if ([messageDict valueForKey:@"title"] != (id)[NSNull null]) {
                messObj.subject = [messageDict valueForKey:@"title"];
            }
            
            if ([messageDict valueForKey:@"content"] != (id)[NSNull null]) {
                NSString *mystring = [messageDict valueForKey:@"content"];
                
                NSData *newdata = [mystring dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                
                mystring = [[NSString alloc] initWithData:newdata encoding:NSNonLossyASCIIStringEncoding];
                
                if (mystring) {
                    messObj.content = mystring;
                    
                } else {
                    messObj.content = [messageDict valueForKey:@"content"];
                }
            }
            
            if ([messageDict valueForKey:@"from_user_id"] != (id)[NSNull null]) {
                messObj.fromID = [NSString stringWithFormat:@"%@", [messageDict valueForKey:@"from_user_id"]];
            }
            
            if ([messageDict valueForKey:@"from_user_name"] != (id)[NSNull null]) {
                messObj.fromUsername = [messageDict valueForKey:@"from_user_name"];
            }
            
            if ([messageDict valueForKey:@"to_user_id"] != (id)[NSNull null]) {
                messObj.toID = [NSString stringWithFormat:@"%@", [messageDict valueForKey:@"to_user_id"]];
            }
            
            if ([messageDict valueForKey:@"to_user_name"] != (id)[NSNull null]) {
                messObj.toUsername = [messageDict valueForKey:@"to_user_name"];
            }
            
            if ([messageDict valueForKey:@"is_read"] != (id)[NSNull null]) {
                messObj.unreadFlag = ![[messageDict valueForKey:@"is_read"] boolValue];
            }
            
            if ([messageDict valueForKey:@"imp_flg"] != (id)[NSNull null]) {
                if ([[messageDict valueForKey:@"imp_flg"] boolValue] == YES) {
                    messObj.importanceType = ImportanceHigh;
                    
                } else {
                    messObj.importanceType = ImportanceNormal;
                }
            }
            
            messObj.messageTypeIcon = MT_COMMENT;
            
            if ([messageDict valueForKey:@"messageType"] != (id)[NSNull null]) {
                messObj.messageType = (MESSAGE_TYPE)[[messageDict valueForKey:@"messageType"] integerValue];
            }
            
            if ([messageDict valueForKey:@"sent_dt"] != (id)[NSNull null]) {
                messObj.dateTime = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:[messageDict valueForKey:@"sent_dt" ] withFormat:@"dd-MM-yyyy HH:mm:ss.SSS"];
            }
            
            if ([messageDict valueForKey:@"frm_user_photo"] != (id)[NSNull null]) {
                messObj.senderAvatar = [messageDict valueForKey:@"frm_user_photo"];
            }
            
            if ([messageDict valueForKey:@"to_user_photo"] != (id)[NSNull null]) {
                messObj.receiverAvatar = [messageDict valueForKey:@"to_user_photo"];
            }
            
            [newArr addObject:messObj];
        }
        
        if ([newArr count] > 0) {
            isNoMoreFromServer = NO;
            [self insertArrayToArray:newArr];
            
            dispatch_async([CoreDataUtil getDispatch], ^(){
                
                [[CoreDataUtil sharedCoreDataUtil] insertMessagesArray:newArr];
            });
        } else {
            isNoMoreFromServer = YES;
        }
        
        [self sortMessagesArrayByDateTime];
        
        if (isNoMoreFromServer == NO) {
            [self loadDataFromServer];
            
        }
        
    } else {
        isNoMoreFromServer = YES;
    }
    
    if (IS_IPAD) {
        if (selectedIndex == nil) {
            MessageObject *messageObj = [self getMessageObjectAtIndex:0];
            if (messageObj) {
                [self showDetailView:messageObj];
                
                selectedIndex = [NSIndexPath indexPathForItem:0 inSection:0];
            }
        }
    }
    
    [messagesTableView reloadData];
}

- (void)insertObjectToArray:(MessageObject *)messObj {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [messagesArray addObject:messObj];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [unreadMessagesArray addObject:messObj];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [sentMessagesArray addObject:messObj];
        
    }
}

- (void)insertArrayToArray:(NSArray *)arr {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [messagesArray addObjectsFromArray:arr];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [unreadMessagesArray addObjectsFromArray:arr];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [sentMessagesArray addObjectsFromArray:arr];
        
    }
}

- (void)sortMessagesArrayByDateTime {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [self sortMessagesArrayByDateTime:messagesArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [self sortMessagesArrayByDateTime:unreadMessagesArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [self sortMessagesArrayByDateTime:sentMessagesArray];
        
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

- (void)sortMessagesArrayByDateTime:(NSMutableArray *)messArr {
    NSSortDescriptor *messageDateTime = [NSSortDescriptor sortDescriptorWithKey:@"sortByDateTime" ascending:NO];
    NSSortDescriptor *messageID = [NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:NO];
    NSArray *resultArr = [messArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:messageDateTime, messageID, nil]];
    
    [messArr removeAllObjects];
    [messArr addObjectsFromArray:resultArr];
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
    NSArray *currentArr = [self currentMessageArray];
    
    if (searchString == nil || searchString.length == 0) {
        self->searchResults = [currentArr mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@ OR fromUsername CONTAINS[cd] %@ OR toUsername CONTAINS[cd] %@", searchString, searchString, searchString];

        NSArray *filterKeys = [currentArr filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    
    [messagesTableView reloadData];
}


- (NSArray *)currentMessageArray {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        return messagesArray;
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        return unreadMessagesArray;
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        return sentMessagesArray;
        
    }
    
    return [[NSMutableArray alloc] init];
}
@end
