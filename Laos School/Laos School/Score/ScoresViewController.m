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
#import "ScoreObject.h"
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
    
    NSMutableArray *scoresArray;
    NSMutableDictionary *scoresStore;
    NSMutableDictionary *groupBySubject;
    
    ScoreDetailViewController *scoreDetailView;
}
@end

@implementation ScoresViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.navigationController setNavigationColor];
    
    segmentedControl = [[UISegmentedControl alloc] initWithItems:
                                            [NSArray arrayWithObjects:LocalizedString(@"Term I"), LocalizedString(@"Term II"),                                             nil]];
    segmentedControl.frame = CGRectMake(0, 0, 140, 30);
    [segmentedControl setWidth:70.0 forSegmentAtIndex:0];
    [segmentedControl setWidth:70.0 forSegmentAtIndex:1];
    
    [segmentedControl setSelectedSegmentIndex:0];
    
    [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = segmentedControl;
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (scoresArray == nil) {
        scoresArray = [[NSMutableArray alloc] init];
    }
    
    if (scoresStore == nil) {
        scoresStore = [[NSMutableDictionary alloc] init];
    }
    
    if (groupBySubject == nil) {
        groupBySubject = [[NSMutableDictionary alloc] init];
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadScoreData) forControlEvents:UIControlEventValueChanged];
    [scoresTableView addSubview:refreshControl];
    
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showScoreDetail:)
                                                 name:@"TapOnScoreCell"
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
    [self prepareDataForSegment:segmentedControl.selectedSegmentIndex];
    [self groupDataBySubject];
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
    ScoreObject *scoreObj = (ScoreObject *)notification.object;
    
    if (scoreObj && scoreObj.score.length > 0) {
        if (scoreDetailView == nil) {
            scoreDetailView = [[ScoreDetailViewController alloc] initWithNibName:@"ScoreDetailViewController" bundle:nil];
        }
        
        scoreDetailView.scoreObj = scoreObj;
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


#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return [[groupBySubject allKeys] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 94.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *studentScoreCellIdentifier = @"StudentScoreTableViewCell";
    
    StudentScoreTableViewCell *cell = [scoresTableView dequeueReusableCellWithIdentifier:studentScoreCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentScoreTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSArray *keyArr = [groupBySubject allKeys];
    
    if (indexPath.row < [keyArr count]) {
        NSString *subject  = [keyArr objectAtIndex:indexPath.row];
        NSArray *arr = [groupBySubject objectForKey:subject];
        
        cell.scoresArray = [self sortScoresArrayByMonth:arr];
        cell.lbSubject.text = subject;
        
        cell.lbSubject.textColor = BLUE_COLOR;
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {

    [scoresArray removeAllObjects];
    [scoresStore removeAllObjects];
    [groupBySubject removeAllObjects];
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    NSArray *scores = [jsonObj objectForKey:@"messageObject"];
    
    if (scores != (id)[NSNull null]) {
        
        for (NSDictionary *scoreDict in scores) {
            ScoreObject *scoreObj = [[ScoreObject alloc] init];
            /*
             {
             "class_id" = 2;
             "exam_dt" = "2016-10-12 09:40:27.0";
             "exam_id" = 1;
             "exam_month" = 9;
             "exam_name" = "Normal exam";
             "exam_type" = 1;
             "exam_year" = 2016;
             id = 7;
             notice = Good;
             "sch_year_id" = 1;
             "school_id" = 1;
             sresult = 666;
             "std_nickname" = "Student 10";
             "std_photo" = "http://192.168.0.202:9090/eschool_content/avatar/student1.png";
             "student_id" = 10;
             "student_name" = 00000010;
             subject = Toan;
             "subject_id" = 1;
             teacher = "Teacher class 2";
             "teacher_id" = 6;
             term = "HK 1";
             "term_id" = 1;
             "term_val" = 1;
             }
             */
            /*
             @property (nonatomic, strong) NSString *scoreID;
             @property (nonatomic, strong) NSString *score;
             @property (nonatomic, strong) NSString *subject;
             @property (nonatomic, strong) NSString *dateTime;
             @property (nonatomic, assign) SCORE_TYPE scoreType;
             @property (nonatomic, strong) NSString *month;
             @property (nonatomic, assign) NSInteger weight;
             @property (nonatomic, strong) NSString *teacherName;
             @property (nonatomic, strong) NSString *comment;
             @property (nonatomic, strong) NSString *termID;
             @property (nonatomic, strong) NSString *term;
             */
            if ([scoreDict valueForKey:@"id"] != (id)[NSNull null]) {
                scoreObj.scoreID = [scoreDict valueForKey:@"id"];
            }
            
            if ([scoreDict valueForKey:@"sresult"] != (id)[NSNull null]) {
                scoreObj.score = [scoreDict valueForKey:@"sresult"];
            }
            
            if ([scoreDict valueForKey:@"subject"] != (id)[NSNull null]) {
                scoreObj.subject = [scoreDict valueForKey:@"subject"];
            }
            
            if ([scoreDict valueForKey:@"exam_dt"] != (id)[NSNull null]) {
                scoreObj.dateTime = [scoreDict valueForKey:@"exam_dt"];
            }
            
            if ([scoreDict valueForKey:@"exam_type"] != (id)[NSNull null]) {
                NSInteger type = [[scoreDict valueForKey:@"exam_type"] integerValue];
                
                if (type == 1) {
                    scoreObj.scoreType = ScoreType_Normal;
                    
                } else if (type == 2) {
                    scoreObj.scoreType = ScoreType_Exam;
                    
                } else if (type == 3) {
                    scoreObj.scoreType = ScoreType_Average;
                    
                } else if (type == 4) {
                    scoreObj.scoreType = ScoreType_Final;
                    
                } else if (type == 5) {
                    scoreObj.scoreType = ScoreType_YearFinal;
                    
                } else if (type == 6) {
                    scoreObj.scoreType = ScoreType_ExamAgain;
                    
                } else if (type == 7) {
                    scoreObj.scoreType = ScoreType_Graduate;
                }
            }
            
            if ([scoreDict valueForKey:@"exam_month"] != (id)[NSNull null]) {
                scoreObj.month = [[scoreDict valueForKey:@"exam_month"] integerValue];
            }
            
            if ([scoreDict valueForKey:@"exam_year"] != (id)[NSNull null]) {
                scoreObj.year = [[scoreDict valueForKey:@"exam_year"] integerValue];
            }
            
            if ([scoreDict valueForKey:@"teacher"] != (id)[NSNull null]) {
                scoreObj.teacherName = [scoreDict valueForKey:@"teacher"];
            }
            
            if ([scoreDict valueForKey:@"notice"] != (id)[NSNull null]) {
                scoreObj.comment = [scoreDict valueForKey:@"notice"];
            }
            
            if ([scoreDict valueForKey:@"term_id"] != (id)[NSNull null]) {
                scoreObj.termID = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"term_id"]];
            }
            
            if ([scoreDict valueForKey:@"term"] != (id)[NSNull null]) {
                scoreObj.term = [scoreDict valueForKey:@"term"];
            }

            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[scoresStore objectForKey:scoreObj.termID]];
            
            [arr addObject:scoreObj];
            [scoresStore setObject:arr forKey:scoreObj.termID];
        }
    }
    
    /*if ([[scoresStore allKeys] count] > 0) {
     NSArray *keyArr = [scoresStore allKeys];
     NSMutableArray *segmentArr = [[NSMutableArray alloc] init];
     float length = SEGMENT_LENGTH * [keyArr count];
     
     for (NSString *key in keyArr) {
     NSString *segmentName = [NSString stringWithFormat:@"%@ %@", LocalizedString(@"Term"), key];
     [segmentArr addObject:segmentName];
     }
     
     segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentArr];
     segmentedControl.frame = CGRectMake(0, 0, length, 30);
     
     for (int i = 0; i < [keyArr count]; i++) {
     [segmentedControl setWidth:SEGMENT_LENGTH forSegmentAtIndex:i];
     }
     
     [segmentedControl setSelectedSegmentIndex:0];
     
     [segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
     
     self.navigationItem.titleView = segmentedControl;
     }*/
    
    [self prepareDataForSegment:segmentedControl.selectedSegmentIndex];
    [self groupDataBySubject];
    [scoresTableView reloadData];
}

//group data by term
- (void)prepareDataForSegment:(NSInteger)segmentID {
    [scoresArray removeAllObjects];
    NSArray *keyArr = [scoresStore allKeys];
    
    if ([keyArr count] > 1) {
        [keyArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            if ([obj1 intValue]==[obj2 intValue])
                return NSOrderedSame;
            
            else if ([obj1 intValue]<[obj2 intValue])
                return NSOrderedAscending;
            else
                return NSOrderedDescending;
            
        }];
    }
    
    if ([keyArr count] > segmentID) {
        [scoresArray addObjectsFromArray:[scoresStore objectForKey:[keyArr objectAtIndex:segmentID]]];
    }
}

- (void)groupDataBySubject {
    [groupBySubject removeAllObjects];
    
    if ([scoresArray count] > 0) {
        for (ScoreObject *scoreObj in scoresArray) {
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[groupBySubject objectForKey:scoreObj.subject]];
            
            [arr addObject:scoreObj];

            [groupBySubject setObject:arr forKey:scoreObj.subject];
        }
    }
}

- (NSArray *)sortScoresArrayByMonth:(NSArray *)scores {
    NSSortDescriptor *sortMonthDes = [NSSortDescriptor sortDescriptorWithKey:@"month" ascending:YES];
    NSSortDescriptor *sortTypeDes = [NSSortDescriptor sortDescriptorWithKey:@"scoreType" ascending:YES];
    NSArray *resultArr = [scores sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortTypeDes, sortMonthDes, nil]];
    
    return resultArr;
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
