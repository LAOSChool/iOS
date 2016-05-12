//
//  ScoresViewController.m
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ScoresViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "ScoreObject.h"

#import "SVProgressHUD.h"

@interface ScoresViewController ()
{
    UISegmentedControl *segmentedControl;
    RequestToServer *requestToServer;
    UIRefreshControl *refreshControl;
    
    NSMutableArray *scoresArray;
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
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(reloadScoreData) forControlEvents:UIControlEventValueChanged];
    [scoresTableView addSubview:refreshControl];
    
    [self loadData];
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

- (void)reloadScoreData {
    [self loadData];
}

- (void)loadData {
    [SVProgressHUD show];
    if (segmentedControl.selectedSegmentIndex == 0) {  //term 1
        [requestToServer getMyScoreList];
        
    } else if(segmentedControl.selectedSegmentIndex == 1) {    //term 2
        
        
    } else if(segmentedControl.selectedSegmentIndex == 2) {    //year
        
        
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
    return [scoresArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {

    [scoresArray removeAllObjects];
    
    [SVProgressHUD dismiss];
    [refreshControl endRefreshing];
    NSArray *scores = [jsonObj objectForKey:@"list"];
    
    if (scores != (id)[NSNull null]) {
        
        for (NSDictionary *scoreDict in scores) {
            ScoreObject *scoreObj = [[ScoreObject alloc] init];
            /*
             {
             "class_id" = 1;
             "exam_dt" = "2016-05-12 14:18:54.0";
             "exam_month" = 1;
             "exam_type" = 1; 1: normal :: 2: final
             "exam_year" = 2016;
             fresult = 1;
             id = 30;
             iresult = 8;
             notice = Good;
             "result_type_id" = 1;
             "school_id" = 1;
             sresult = OK;
             "student_id" = 10;
             "student_name" = "Student 10";
             subject = Toan;
             "subject_id" = 1;
             teacher = "Teacher class 1";
             "teacher_id" = 5;
             term = "Hoc Ky 1 - 2016";
             "term_id" = 1;
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
                scoreObj.scoreID = [scoreDict valueForKey:@"sresult"];
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
                    scoreObj.scoreType = ScoreType_Final;
                }
            }
            
            if ([scoreDict valueForKey:@"month"] != (id)[NSNull null]) {
                scoreObj.month = [NSString stringWithFormat:@"%@", [scoreDict valueForKey:@"month"]];
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

            [scoresArray addObject:scoreObj];
        }
    }
    
    [scoresTableView reloadData];
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
