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

#import "TagManagerHelper.h"
#import "LocalizeHelper.h"
#import "SVProgressHUD.h"
#import "RequestToServer.h"

#import "ShareData.h"
#import "Common.h"

@interface MessagesViewController ()
{
    NSMutableArray *messagesArray;
    NSMutableArray *searchResults;
    
    RequestToServer *requestToServer;
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
    
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:
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
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    [requestToServer getMessageListToUser:[[ShareData sharedShareData] userObj].userID];
    
    //for test
    /*
    MessageObject *messObj = [[MessageObject alloc] init];
    
    messObj.messsageID = @"1";
    messObj.subject = @"Nhận xét học tập";
    messObj.content = @"Con học dốt như bò";
    messObj.fromID = @"1";
    messObj.fromUsername = @"Phạm Phương Thảo";
    messObj.toID = @"2";
    messObj.toUsername = @"Nguyễn Huyền Trang";
    messObj.unreadFlag = YES;
    messObj.incomeOutgoType = MessageIncome;
    messObj.messageType = MessageComment;
    messObj.importanceType = ImportanceNormal;
    messObj.messageTypeIcon = MT_COMMENT;
    messObj.importanceTypeIcon = @"";
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

- (IBAction)segmentAction:(id)sender {

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
        return [messagesArray count];
    }
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
    
    MessageObject *messageObj = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        messageObj = [searchResults objectAtIndex:indexPath.row];
        
    } else {
        messageObj = [messagesArray objectAtIndex:indexPath.row];
    }
    
    //    [dataDic setObject:wordObj forKey:wordObj.question];
    
    cell.tag = [messageObj.messsageID integerValue];
    cell.lbSubject.text = messageObj.subject;
    cell.lbBriefContent.text = messageObj.content;
    cell.lbTime.text = messageObj.dateTime;
    cell.lbSenderName.text = messageObj.fromUsername;
    
    //set message type icon and importance icon
    cell.imgMesseageType.image = [[Common sharedCommon] imageFromText:messageObj.messageTypeIcon withColor:[UIColor blueColor]];
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
        messageObj = [messagesArray objectAtIndex:indexPath.row];
    }
    
    MessageDetailViewController *messageDetailViewController = [[MessageDetailViewController alloc] initWithNibName:@"MessageDetailViewController" bundle:nil];
    messageDetailViewController.messageObject = messageObj;
    
    [self.navigationController pushViewController:messageDetailViewController animated:YES];
    
}

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self->searchResults removeAllObjects]; // First clear the filtered array.
    
    if (searchString == nil || searchString.length == 0) {
        self->searchResults = [messagesArray mutableCopy];
        
    } else {
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"content CONTAINS[cd] %@", searchString];
        //        NSArray *keys = [dataDic allKeys];
        //        NSArray *filterKeys = [keys filteredArrayUsingPredicate:filterPredicate];
        //        self->searchResults = [NSMutableArray arrayWithArray:[dataDic objectsForKeys:filterKeys notFoundMarker:[NSNull null]]];
        NSArray *filterKeys = [messagesArray filteredArrayUsingPredicate:filterPredicate];
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
    MessageTableViewCell *cell = (MessageTableViewCell *)sender;
    
    NSIndexPath *indexPath = [messagesTableView indexPathForCell:cell];
    MessageObject *messageObj = [messagesArray objectAtIndex:indexPath.row];
    
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
- (void)didReceiveData:(NSDictionary *)jsonObj {
    NSArray *messagesArray = [jsonObj objectForKey:@"list"];
    /*
     {
     
     channel = 1;
     
     "class_id" = 1;
     
     content = "test message";
     
     "from_usr_id" = 1;
     
     id = 1;
     
     "imp_flg" = 1;
     
     "is_read" = 1;
     
     "is_sent" = 1;
     
     other = "ko co gi quan trong";
     
     "read_dt" = "2016-03-24 00:00:00.0";
     
     "school_id" = 1;
     
     "sent_dt" = "2016-03-24 00:00:00.0";
     
     "to_usr_id" = 2;
     
     },*/
    for (NSDictionary *messageDict in messagesArray) {
        MessageObject *messObj = [[MessageObject alloc] init];
        
        messObj.messsageID = [messageDict valueForKey:@"id"];
        messObj.subject = [messageDict valueForKey:@"id"];
        messObj.content = [messageDict valueForKey:@"content"];
        messObj.fromID = @"1";
        messObj.fromUsername = @"Phạm Phương Thảo";
        messObj.toID = @"2";
        messObj.toUsername = @"Nguyễn Huyền Trang";
        messObj.unreadFlag = YES;
        messObj.incomeOutgoType = MessageIncome;
        messObj.messageType = MessageComment;
        messObj.importanceType = ImportanceNormal;
        messObj.messageTypeIcon = MT_COMMENT;
        messObj.importanceTypeIcon = @"";
        messObj.dateTime = @"2016-03-20 16:00";
        
        [messagesArray addObject:messObj];
    }
}

- (void)failToConnectToServer {

}

- (void)sendPostRequestFailedWithUnknownError {

}

- (void)sendPostRequestSuccessfully {

}
@end
