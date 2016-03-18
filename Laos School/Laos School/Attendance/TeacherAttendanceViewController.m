//
//  TeacherAttendanceViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherAttendanceViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "TeacherAttendanceTableViewCell.h"

#import "MGSwipeTableCell.h"
#import "CommonDefine.h"

@interface TeacherAttendanceViewController ()
{
    BOOL isShowingViewInfo;
}
@end

@implementation TeacherAttendanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    
    [self setTitle:LocalizedString(@"Attendance")];
    
    UIBarButtonItem *btnAction = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(actionButtonClick:)];
    
    self.navigationItem.rightBarButtonItems = @[btnAction];
    
    isShowingViewInfo = YES;
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

- (IBAction)actionButtonClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:(id)self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"xxx"), LocalizedString(@"yyy"), nil];
    
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if (IS_IPAD) {
        [actionSheet showFromBarButtonItem:sender animated:YES];
    } else {
        [actionSheet showInView:self.view];
    }
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
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    static NSString *studentsListCellIdentifier = @"StudentsListCellIdentifier";
//    
//    StudentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsListCellIdentifier];
//    if (cell == nil) {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentsListTableViewCell" owner:nil options:nil];
//        cell = [nib objectAtIndex:0];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    }
//    
    return nil;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

#pragma mark button click
- (IBAction)btnExpandClick:(id)sender {
    isShowingViewInfo = !isShowingViewInfo;
    [self showHideInfoView:isShowingViewInfo];
    
    
}

- (void)showHideInfoView:(BOOL)showHideFlag {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        CGRect rectViewTerm = viewTerm.frame;
        CGRect rectViewInfo = viewInfo.frame;
        CGRect rectViewTableView = viewTableView.frame;
        
        if (showHideFlag) {
            rectViewInfo.origin.y = rectViewTerm.size.height;
            
            [viewInfo setFrame:rectViewInfo];
            
            rectViewTableView.origin.y = rectViewInfo.origin.y + rectViewInfo.size.height;
            rectViewTableView.size.height = self.view.frame.size.height - rectViewTableView.origin.y;
            
            [viewTableView setFrame:rectViewTableView];
            
        } else {
            rectViewInfo.origin.y = rectViewTerm.size.height - rectViewInfo.size.height;
            
            [viewInfo setFrame:rectViewInfo];
            
            rectViewTableView.origin.y = rectViewTerm.origin.y + rectViewTerm.size.height;
            rectViewTableView.size.height = self.view.frame.size.height - rectViewTableView.origin.y;
            
            [viewTableView setFrame:rectViewTableView];
            
        }
    }];
}

#pragma mark actions sheet handle
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            
        }
    }
    
}

#pragma mark swipe delegate
//-(BOOL) swipeTableCell:(MGSwipeTableCell*) cell canSwipe:(MGSwipeDirection) direction;
//{
//    if (_screenType == MyAlbumScreen) {
//        return NO;
//
//    } else {
//        return YES;
//    }
//}

//-(NSArray*) swipeTableCell:(StudiedTableViewCell*) cell swipeButtonsForDirection:(MGSwipeDirection)direction
//             swipeSettings:(MGSwipeSettings*) swipeSettings expansionSettings:(MGSwipeExpansionSettings*) expansionSettings
//{

//        swipeSettings.transition = MGSwipeTransitionStatic;
//        
//        if (direction == MGSwipeDirectionRightToLeft) {
//            expansionSettings.fillOnTrigger = NO;
//            expansionSettings.threshold = 1.1;
//            
//            MGSwipeButton *btnDone = nil;
//            
//            btnDone = [MGSwipeButton buttonWithTitle:LocalizedString(@"Done") backgroundColor:BLUE_COLOR padding:20 callback:^BOOL(MGSwipeTableCell *sender) {
//                
//                return NO;
//            }];
//            
//            MGSwipeButton *btnIgnore = nil;
//            
//            btnIgnore = [MGSwipeButton buttonWithTitle:LocalizedString(@"Ignore") backgroundColor:[UIColor lightGrayColor] padding:20 callback:^BOOL(MGSwipeTableCell *sender) {
//                
//                return NO;
//            }];
//            
//            return @[btnDone, btnIgnore];
//        }
    
//    return nil;
//}

//-(BOOL) swipeTableCell:(StudiedTableViewCell*) cell tappedButtonAtIndex:(NSInteger) index direction:(MGSwipeDirection)direction fromExpansion:(BOOL) fromExpansion
//{
//    if (_screenType == List_Incoming) {
//        WordObject *wordObj = nil;
//        NSIndexPath *indexPath = [wordsTableView indexPathForCell:cell];
//        if (direction == MGSwipeDirectionRightToLeft && index == 0) {   //Done
//            NSLog(@"Done");
//            //update queue value in DB
//            indexPath = [wordsTableView indexPathForCell:cell];
//            wordObj = [wordList objectAtIndex:indexPath.row];
//            
//            wordObj.queue = [NSString stringWithFormat:@"%d", QUEUE_DONE];
//            
//        } else if (direction == MGSwipeDirectionRightToLeft && index == 1) {   //Ignore
//            NSLog(@"Ignore");
//            //update queue value in DB
//            indexPath = [wordsTableView indexPathForCell:cell];
//            wordObj = [wordList objectAtIndex:indexPath.row];
//            
//            wordObj.queue = [NSString stringWithFormat:@"%d", QUEUE_SUSPENDED];
//        }
//        
//        if (wordList) {
//            [[CommonSqlite sharedCommonSqlite] updateWord:wordObj];
//            
//            //remove from buffer
//            [[CommonSqlite sharedCommonSqlite] removeWordFromBuffer:wordObj];
//            
//            [wordList removeObject:wordObj];
//            
//            lbHeaderInfo.text = [NSString stringWithFormat:@"%@: %lu", LocalizedString(@"Total"), (unsigned long)[wordList count]];
//            [wordsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        }
//        
//    } else if (_screenType == List_SearchResult ||
//               _screenType == List_SearchHint ||
//               _screenType == List_SearchHintHome) {
//        NSLog(@"Add to learn");
//        WordObject *wordObj = nil;
//        NSIndexPath *indexPath = [wordsTableView indexPathForCell:cell];
//        
//        indexPath = [wordsTableView indexPathForCell:cell];
//        wordObj = [wordList objectAtIndex:indexPath.row];
//        
//        //update queue value to 3 to consider this word as a new word in DB
//        wordObj.queue = [NSString stringWithFormat:@"%d", QUEUE_NEW_WORD];
//        
//        if (wordObj.isFromServer) {
//            [[CommonSqlite sharedCommonSqlite] insertWordToDatabase:wordObj];
//            
//            //because word-id is blank so need to get again after insert it into db
//            wordObj = [[CommonSqlite sharedCommonSqlite] getWordInformation:wordObj.question];
//            
//            [[CommonSqlite sharedCommonSqlite] addAWordToStydyingQueue:wordObj];
//            
//        } else {
//            [[CommonSqlite sharedCommonSqlite] addAWordToStydyingQueue:wordObj];
//            
//            //remove from buffer
//            [[CommonSqlite sharedCommonSqlite] removeWordFromBuffer:wordObj];
//            
//            [[CommonSqlite sharedCommonSqlite] updateWord:wordObj];
//        }
//        
//        [SVProgressHUD showSuccessWithStatus:LocalizedString(@"Added")];
//        
//        return YES;
//    }
//    
//    return NO;  //Don't autohide
//}
@end
