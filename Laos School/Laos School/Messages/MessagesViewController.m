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

#import "TagManagerHelper.h"
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
}
@end

@implementation MessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TagManagerHelper pushOpenScreenEvent:@"iMessagesViewController"];
    
//    [self setTitle:LocalizedString(@"Messages")];
    [self.searchDisplayController.searchBar setPlaceholder:LocalizedString(@"Search")];
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;

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
    
    //Load data
    [self loadData];
    
    //for test
    /*
    MessageObject *messObj = [[MessageObject alloc] init];
    
    messObj.messageID = @"1";
    messObj.subject = @"Nhận xét học tập";
    messObj.content = @"Con học dốt như bò";
    messObj.fromID = @"1";
    messObj.fromUsername = @"Phạm Phương Thảo";
    messObj.toID = @"2";
    messObj.toUsername = @"Nguyễn Huyền Trang";
    messObj.unreadFlag = YES;
    messObj.messageType = MessageComment;
    messObj.importanceType = ImportanceNormal;
    messObj.messageTypeIcon = MT_COMMENT;
    messObj.dateTime = @"2016-03-20 16:00";
    
    [messagesArray addObject:messObj];
    
    [SVProgressHUD show];
    dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    dispatch_async(taskQ, ^{
        
//        NSArray *sortDescriptionArr = [NSArray arrayWithObjects:sortWord, nil];
//        [wordsArray sortUsingDescriptors:sortDescriptionArr];
//        NSLog(@"All :: %lu", (unsigned long)[wordsArray count]);
        dispatch_sync(dispatch_get_main_queue(), ^{
            [messagesTableView reloadData];
            [SVProgressHUD dismiss];
        });
    });
     */
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

- (void)loadData {
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

#pragma mark load all message
- (void)loadMessagesFromCoredata {
    MessageObject *lastMessage = nil;
    
    if ([messagesArray count] > 0) {
        lastMessage = [messagesArray lastObject];   //last object is the oldest message in this array
        [messagesArray addObjectsFromArray:[[CoreDataUtil sharedCoreDataUtil] loadAllMessagesFromID:lastMessage.messageID toUserID:[[ShareData sharedShareData] userObj].userID]];
        
    } else {
        [messagesArray addObjectsFromArray:[[CoreDataUtil sharedCoreDataUtil] loadAllMessagesFromID:nil toUserID:[[ShareData sharedShareData] userObj].userID]];
    }
    
    [self sortMessagesArrayByID:messagesArray];
    NSLog(@"first");
}

- (void)loadNewMessageFromServer {
    //get last message
    MessageObject *lastMessage = nil;
    
    if ([messagesArray count] > 0) {
        lastMessage = [messagesArray firstObject];
        [requestToServer getMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:lastMessage.messageID];
        
    } else {
        [requestToServer getMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:0];
    }
}

#pragma mark load unread message
- (void)loadUnreadMessagesFromCoredata {
    MessageObject *lastMessage = nil;
    
    if ([unreadMessagesArray count] > 0) {
        lastMessage = [unreadMessagesArray lastObject];
        [unreadMessagesArray addObjectsFromArray:[[CoreDataUtil sharedCoreDataUtil] loadUnreadMessagesFromID:lastMessage.messageID toUserID:[[ShareData sharedShareData] userObj].userID]];
        
    } else {
        [unreadMessagesArray addObjectsFromArray:[[CoreDataUtil sharedCoreDataUtil] loadUnreadMessagesFromID:nil toUserID:[[ShareData sharedShareData] userObj].userID]];
    }
    
    [self sortMessagesArrayByID:unreadMessagesArray];
}

- (void)loadUnreadMessageFromServer {
    //get last message
    MessageObject *lastMessage = nil;
    
    if ([unreadMessagesArray count] > 0) {
        lastMessage = [unreadMessagesArray firstObject];
        [requestToServer getUnreadMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:lastMessage.messageID];
        
    } else {
        [requestToServer getUnreadMessageListToUser:[[ShareData sharedShareData] userObj].userID fromMessageID:0];
    }
}

#pragma mark load all message
- (void)loadSentMessagesFromCoredata {
    MessageObject *lastMessage = nil;
    
    if ([sentMessagesArray count] > 0) {
        lastMessage = [sentMessagesArray lastObject];
        [sentMessagesArray addObjectsFromArray:[[CoreDataUtil sharedCoreDataUtil] loadSentMessagesFromID:lastMessage.messageID fromUserID:[[ShareData sharedShareData] userObj].userID]];
        
    } else {
        [sentMessagesArray addObjectsFromArray:[[CoreDataUtil sharedCoreDataUtil] loadSentMessagesFromID:nil fromUserID:[[ShareData sharedShareData] userObj].userID]];
    }
    
    [self sortMessagesArrayByID:sentMessagesArray];
}

- (void)loadSentMessageFromServer {
    //get last message
    MessageObject *lastMessage = nil;
    
    if ([sentMessagesArray count] > 0) {
        lastMessage = [sentMessagesArray firstObject];
        [requestToServer getSentMessageListFromUser:[[ShareData sharedShareData] userObj].userID fromMessageID:lastMessage.messageID];
        
    } else {
        [requestToServer getSentMessageListFromUser:[[ShareData sharedShareData] userObj].userID fromMessageID:0];
    }
}

- (IBAction)segmentAction:(id)sender {
    [self loadData];
}

- (void)composeNewMessage {
    ComposeViewController *composeViewController = nil;
    
    if ([ShareData sharedShareData].userObj.userRole == UserRole_Student) {
        composeViewController = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" bundle:nil];
        
    } else {
        composeViewController = [[ComposeViewController alloc] initWithNibName:@"TeacherComposeViewController" bundle:nil];
    }
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
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
        messageObj = [messagesArray objectAtIndex:index];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        messageObj = [unreadMessagesArray objectAtIndex:index];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        messageObj = [sentMessagesArray objectAtIndex:index];
        
    }
    
    return messageObj;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *messageCellIdentifier = @"MessageCellIdentifier";
    
    MessageTableViewCell *cell = [messagesTableView dequeueReusableCellWithIdentifier:messageCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MessageTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.delegate = (id)self;
    [cell.lbSubject setTextColor:TITLE_COLOR];
    
    MessageObject *messageObj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        messageObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        messageObj = [self getMessageObjectAtIndex:indexPath.row];
    }
    
    //    [dataDic setObject:wordObj forKey:wordObj.question];
    
    if (messageObj.messageID) {
        cell.tag = [messageObj.messageID integerValue];
    }
    
    if (messageObj.subject) {
        cell.lbSubject.text = messageObj.subject;
    }
    
    if (messageObj.content) {
        cell.lbBriefContent.text = messageObj.content;
    }
    
    if (messageObj.dateTime) {
        cell.lbTime.text = messageObj.dateTime;
    }
    
    if (messageObj.fromUsername) {
        if (segmentedControl.selectedSegmentIndex == 2) {
            cell.lbSenderName.text = messageObj.toUsername;
        } else {
            cell.lbSenderName.text = messageObj.fromUsername;
        }
    }
    
    //set message type icon and importance icon
    
    if (messageObj.messageTypeIcon) {
        cell.imgMesseageType.image = [[Common sharedCommon] imageFromText:messageObj.messageTypeIcon withColor:GREEN_COLOR];
    }
    
    if (messageObj.importanceType == ImportanceHigh) {
        [cell.btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [cell.btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    
    if (messageObj.unreadFlag) {
        [cell.contentView setBackgroundColor:UNREAD_COLOR];
        [cell setBackgroundColor:UNREAD_COLOR];
    } else {
        [cell.contentView setBackgroundColor:READ_COLOR];
        [cell setBackgroundColor:READ_COLOR];
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageObject *messageObj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        messageObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        messageObj = [self getMessageObjectAtIndex:indexPath.row];
    }
    
    MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewController" bundle:nil];
    messageDetailViewController.messageObject = messageObj;
    
    [self.navigationController pushViewController:messageDetailViewController animated:YES];
    
//    MessagesConversationViewController *vc = [MessagesConversationViewController messagesViewController];
//    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    NSArray *currentArr = [self currentMessageArray];
    if (searchString == nil || searchString.length == 0) {
        self->searchResults = [currentArr mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@", searchString];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [currentArr filteredArrayUsingPredicate:filterPredicate];
        self->searchResults = [NSMutableArray arrayWithArray:filterKeys];
    }
    // Return YES to cause the search result table view to be reloaded.
    return YES;
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
    MessageTableViewCell *cell = (MessageTableViewCell *)sender;
    
    NSIndexPath *indexPath = [messagesTableView indexPathForCell:cell];
    MessageObject *messageObj = [self getMessageObjectAtIndex:indexPath.row];
    
    if (messageObj.importanceType == ImportanceNormal) {
        messageObj.importanceType = ImportanceHigh;
        
    } else {
        messageObj.importanceType = ImportanceNormal;
    }
    
    [messagesTableView beginUpdates];
    [messagesTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [messagesTableView endUpdates];
}


#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    NSArray *messages = [jsonObj objectForKey:@"list"];
    NSMutableArray *newArr = [[NSMutableArray alloc] init];
    /*
     {
     channel = 1;
     "class_id" = 1;
     content = "test message";
     "from_user_name" = NamNT1;
     "from_usr_id" = 1;
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
     "to_usr_id" = 2;
     }
     
     },*/
    NSLog(@"second");
    if (messages != (id)[NSNull null]) {
        for (NSDictionary *messageDict in messages) {
            MessageObject *messObj = [[MessageObject alloc] init];
            
            if ([messageDict valueForKey:@"id"] != (id)[NSNull null]) {
                messObj.messageID = [messageDict valueForKey:@"id"];
            }
            
            if ([messageDict valueForKey:@"title"] != (id)[NSNull null]) {
                messObj.subject = [messageDict valueForKey:@"title"];
            }
            
            if ([messageDict valueForKey:@"content"] != (id)[NSNull null]) {
                messObj.content = [messageDict valueForKey:@"content"];
            }
            
            if ([messageDict valueForKey:@"from_usr_id"] != (id)[NSNull null]) {
                messObj.fromID = [NSString stringWithFormat:@"%@", [messageDict valueForKey:@"from_usr_id"]];
            }
            
            if ([messageDict valueForKey:@"from_user_name"] != (id)[NSNull null]) {
                messObj.fromUsername = [messageDict valueForKey:@"from_user_name"];
            }
            
            if ([messageDict valueForKey:@"to_usr_id"] != (id)[NSNull null]) {
                messObj.toID = [NSString stringWithFormat:@"%@", [messageDict valueForKey:@"to_usr_id"]];
            }
            
            if ([messageDict valueForKey:@"to_user_name"] != (id)[NSNull null]) {
                messObj.toUsername = [messageDict valueForKey:@"to_user_name"];
            }
            
            if ([messageDict valueForKey:@"is_read"] != (id)[NSNull null]) {
                messObj.unreadFlag = [[messageDict valueForKey:@"is_read"] boolValue];
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
                messObj.dateTime = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:[messageDict valueForKey:@"sent_dt" ] withFormat:@"dd-MM HH:mm"];
            }
            
            [newArr addObject:messObj];
        }
        
        if ([newArr count] > 0) {
            [self insertArrayToArray:newArr];
            
            dispatch_async([CoreDataUtil getDispatch], ^(){
                
                [[CoreDataUtil sharedCoreDataUtil] insertMessagesArray:newArr];
                //
                //        dispatch_async(dispatch_get_main_queue(), ^(){
                //
                //        });
            });
        }
        
        [self sortMessagesArrayByID];
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

- (void)sortMessagesArrayByID {
    if (segmentedControl.selectedSegmentIndex == 0) {  //All
        [self sortMessagesArrayByID:messagesArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //Unread
        [self sortMessagesArrayByID:unreadMessagesArray];
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //Sent
        [self sortMessagesArrayByID:sentMessagesArray];
        
    }
}

- (void)failToConnectToServer {

}

- (void)sendPostRequestFailedWithUnknownError {

}

- (void)sendPostRequestSuccessfully {

}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)sortMessagesArrayByID:(NSMutableArray *)messArr {
    NSSortDescriptor *messageID = [NSSortDescriptor sortDescriptorWithKey:@"messageID" ascending:NO];
    NSArray *resultArr = [messArr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:messageID, nil]];
    
    [messArr removeAllObjects];
    [messArr addObjectsFromArray:resultArr];
}

@end
