//
//  ScoresViewController.m
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ScoresViewController.h"
#import "StudentScoreTableViewCell.h"
#import "ScoreDetailViewController.h"
#import "AppDelegate.h"

#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "UserScore.h"
#import "CommonDefine.h"
#import "ShareData.h"
#import "UserObject.h"
#import "ClassObject.h"

#import "SVProgressHUD.h"

@interface ScoresViewController ()
{
    UISegmentedControl *segmentedControl;
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
    
    NSMutableDictionary *scoresStore;   //store all scores
    NSMutableDictionary *groupBySubject;
    
    ScoreDetailViewController *scoreDetailView;
    
    BOOL isVisible;
}
@end

@implementation ScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationColor];
    [self setTitle:LocalizedString(@"Scores")];
    
    if (_tableType == ScoreTable_Normal) {
        segmentedControl = [[UISegmentedControl alloc] initWithItems:
                            [NSArray arrayWithObjects:LocalizedString(@"Term I"), LocalizedString(@"Term II"),                                             nil]];
        segmentedControl.frame = CGRectMake(0, 0, 140, 30);
        [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
        [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
        
        [segmentedControl setSelectedSegmentIndex:0];
        
        [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
        
        self.navigationItem.titleView = segmentedControl;
    }
    
    isVisible = NO;
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (_scoresArray == nil) {
        _scoresArray = [[NSMutableArray alloc] init];
    }
    
    if (scoresStore == nil) {
        scoresStore = [[NSMutableDictionary alloc] init];
    }
    
    if (groupBySubject == nil) {
        groupBySubject = [[NSMutableDictionary alloc] init];
    }
    
    if (_tableType == ScoreTable_Normal) {
        refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(reloadScoreData) forControlEvents:UIControlEventValueChanged];
        [scoresTableView addSubview:refreshControl];
        
        [self loadData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showScoreDetail:)
                                                 name:@"TapOnScoreCell"
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    isVisible = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    isVisible = NO;
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
//    [self prepareDataForSegment:segmentedControl.selectedSegmentIndex];
//    [self groupDataBySubject];
    [scoresTableView reloadData];
}

- (void)reloadScoreData {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD show];
    
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    [requestToServer getMyScoreListInClass:classObj.classID];
}

- (void)showScoreDetail:(NSNotification *)notification {
    NSDictionary *passedObj = (NSDictionary *)notification.object;
    UserScore *userScoreObj = [passedObj objectForKey:@"UserScoreObj"];
    ScoreObject *scoreObj = [passedObj objectForKey:@"ScoreObj"];
    
    if (isVisible) {
        if (scoreObj && scoreObj.score.length > 0) {
            if (scoreDetailView == nil) {
                scoreDetailView = [[ScoreDetailViewController alloc] initWithNibName:@"ScoreDetailViewController" bundle:nil];
            }
            
            scoreDetailView.scoreObj = scoreObj;
            scoreDetailView.userScoreObj = userScoreObj;
            scoreDetailView.view.alpha = 0;
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            CGRect rect = appDelegate.window.frame;
            [scoreDetailView.view setFrame:rect];
            
            [appDelegate.window addSubview:scoreDetailView.view];
            
            [UIView animateWithDuration:0.3 animations:^(void) {
                scoreDetailView.view.alpha = 1;
            }];
            
            [scoreDetailView loadInformation];
        }
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
    return [_scoresArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPAD) {
        return 115.0;
    }
    
    if (segmentedControl.selectedSegmentIndex == 0) {
        return 115.0;
        
    } else {
        return 170.0;
    }
    
    return 170.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *studentScoreCellIdentifier = @"StudentScoreTableViewCell";
    
    StudentScoreTableViewCell *cell = [scoresTableView dequeueReusableCellWithIdentifier:studentScoreCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentScoreTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (IS_IPAD) {
        CGRect rect = cell.contentView.frame;
        rect.size.width = self.view.frame.size.width;
        
        [cell.contentView setFrame:rect];
    }
    if (_curTerm && _curTerm.length > 0) {
        cell.curTerm = _curTerm;
        
    } else {
        if (segmentedControl.selectedSegmentIndex == 0) {
            cell.curTerm = TERM_VALUE_1;
            
        } else {
            cell.curTerm = TERM_VALUE_2;
        }
    }
    
    UserScore *userScoreObject = nil;
    
    userScoreObject = [_scoresArray objectAtIndex:indexPath.row];
    cell.userScoreObj = userScoreObject;
    
    cell.lbSubject.textColor = BLUE_COLOR;
    cell.lbSubject.text = userScoreObject.subject;
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {

    [_scoresArray removeAllObjects];
    [scoresStore removeAllObjects];
    [groupBySubject removeAllObjects];
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    NSArray *scores = [jsonObj objectForKey:@"messageObject"];
    if (scores != (id)[NSNull null]) {
        for (NSDictionary *scoreDict in scores) {
            NSString *studentID = @"";
            NSString *studentName = @"";
            NSString *nickname = @"";
            NSString *fullname = @"";
            NSString *avatarLink = @"";
            NSString *subjectID = @"";
            NSString *subject = @"";
            
            if ([scoreDict valueForKey:@"student_id"] != (id)[NSNull null]) {
                studentID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"student_id"]];
            }
            
            if ([scoreDict valueForKey:@"student_name"] != (id)[NSNull null]) {
                studentName = [scoreDict valueForKey:@"student_name"];
            }
            
            if ([scoreDict valueForKey:@"std_nickname"] != (id)[NSNull null]) {
                nickname = [scoreDict valueForKey:@"std_nickname"];
            }
            
            if ([scoreDict valueForKey:@"std_fullname"] != (id)[NSNull null]) {
                fullname = [scoreDict valueForKey:@"std_fullname"];
            }
            
            if ([scoreDict valueForKey:@"std_photo"] != (id)[NSNull null]) {
                avatarLink = [scoreDict valueForKey:@"std_photo"];
            }
            
            if ([scoreDict valueForKey:@"subject_id"] != (id)[NSNull null]) {
                subjectID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"subject_id"]];
            }
            
            if ([scoreDict valueForKey:@"subject_name"] != (id)[NSNull null]) {
                subject = [scoreDict valueForKey:@"subject_name"];
            }
            
            UserScore *newUserScoreObj = [[UserScore alloc] init];
            
            newUserScoreObj.userID = studentID;
            newUserScoreObj.username = studentName;
            newUserScoreObj.additionalInfo = nickname;
            newUserScoreObj.displayName = fullname;
            newUserScoreObj.avatarLink = avatarLink;
            newUserScoreObj.subjectID = subjectID;
            newUserScoreObj.subject = subject;
            
            NSString *key = @"";
            for (int i = 1; i <= 20; i++) {
                key = [NSString stringWithFormat:@"m%d", i];
                NSString *stringScoreJson = [scoreDict objectForKey:key];
                
                if (stringScoreJson != (id)[NSNull null]) {
                    NSData *objectData = [stringScoreJson dataUsingEncoding:NSUTF8StringEncoding];
                    NSDictionary *score = [NSJSONSerialization JSONObjectWithData:objectData options:kNilOptions error:nil];
                    ScoreObject *scoreObj = [[ScoreObject alloc] init];
                    /*@property (nonatomic, strong) NSString *score;
                     @property (nonatomic, strong) NSString *dateTime;
                     @property (nonatomic, strong) ScoreTypeObject *scoreTypeObj;
                     @property (nonatomic, strong) NSString *comment;*/
                    
                    if ([score valueForKey:@"sresult"] != (id)[NSNull null]) {
                        scoreObj.score = [score valueForKey:@"sresult"];
                    }
                    
                    if ([score valueForKey:@"exam_dt"] != (id)[NSNull null]) {
                        scoreObj.dateTime = [score valueForKey:@"exam_dt"];
                    }
                    
                    ScoreTypeObject *typeObj = [[ScoreTypeObject alloc] init];
                    typeObj.scoreKey = key;
                    
                    scoreObj.scoreTypeObj = typeObj;
                    
                    if ([score valueForKey:@"notice"] != (id)[NSNull null]) {
                        scoreObj.comment = [score valueForKey:@"notice"];
                    }
                    
                    [newUserScoreObj.scoreArray addObject:scoreObj];
                } else {
                    
                    ScoreObject *scoreObj = [[ScoreObject alloc] init];
                    ScoreTypeObject *typeObj = [[ScoreTypeObject alloc] init];
                    typeObj.scoreKey = key;
                    scoreObj.scoreTypeObj = typeObj;
                    [newUserScoreObj.scoreArray addObject:scoreObj];
                }
            }
            
            NSSortDescriptor *sortByType = [NSSortDescriptor sortDescriptorWithKey:@"scoreType" ascending:YES];
            
            [newUserScoreObj.scoreArray sortUsingDescriptors:[NSArray arrayWithObjects:sortByType, nil]];
            
            [_scoresArray addObject:newUserScoreObj];
        }

    }
    
//    [self prepareDataForSegment:segmentedControl.selectedSegmentIndex];
//    [self groupDataBySubject];
    [scoresTableView reloadData];
}

- (void)setScoresArray:(NSMutableArray *)scoresArray {
    if (_scoresArray == nil) {
        _scoresArray = [[NSMutableArray alloc] init];
    } else {
        [_scoresArray removeAllObjects];
    }
    
    [_scoresArray addObjectsFromArray:scoresArray];
    
    [scoresTableView reloadData];
}

//- (NSArray *)sortScoresArrayByMonth:(NSArray *)scores {
//    NSSortDescriptor *sortMonthDes = [NSSortDescriptor sortDescriptorWithKey:@"month" ascending:YES];
//    NSSortDescriptor *sortTypeDes = [NSSortDescriptor sortDescriptorWithKey:@"scoreType" ascending:YES];
//    NSArray *resultArr = [scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortTypeDes, sortMonthDes, nil]];
//    
//    return resultArr;
//}

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

- (void)dealloc {
    requestToServer.delegate = nil;
}
@end
