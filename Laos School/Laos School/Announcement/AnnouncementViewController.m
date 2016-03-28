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

@interface AnnouncementViewController ()
{
    NSMutableArray *announceArray;
    NSMutableArray *searchResults;
}
@end

@implementation AnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Announcements")];
    
    [self.navigationController setNavigationColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    if (([ShareData sharedShareData].userObj.permission & Permission_SendMessage) == Permission_SendMessage) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAnnouncement)];
        
        self.navigationItem.rightBarButtonItems = @[addButton];
    }
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
    
    //for test
    if (announceArray == nil) {
        announceArray = [[NSMutableArray alloc] init];
    }
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

- (void)addNewAnnouncement {
    CreatePostViewController *composeViewController = nil;
    
    composeViewController = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
    
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
    
    cell.tag = [announcementObjectObj.announcementID integerValue];
    cell.lbSubject.text = announcementObjectObj.subject;
    cell.lbBriefContent.text = announcementObjectObj.content;
    cell.lbTime.text = announcementObjectObj.dateTime;
    cell.lbSenderName.text = announcementObjectObj.senderUser;
    
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
@end
