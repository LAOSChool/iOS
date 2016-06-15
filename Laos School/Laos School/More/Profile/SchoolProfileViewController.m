//
//  SchoolProfileViewController.m
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "SchoolProfileViewController.h"
#import "SchoolRecordTableViewCell.h"
#import "LevelPickerViewController.h"
#import "LocalizeHelper.h"
#import "UINavigationController+CustomNavigation.h"
#import "CommonDefine.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "TagManagerHelper.h"

#import "TermObject.h"

#import "SVProgressHUD.h"

@interface SchoolProfileViewController ()
{
    //overal data
    NSString *className;
    NSString *averageTermOne;
    NSString *averageTermSecond;
    NSString *overalYear;
    NSString *comment;
    NSString *additionalInfo;
    NSInteger rank;
    NSString *grade;
    
    NSMutableArray *averageMonthArr;
    NSString *average4Months;
    NSString *averageExams;
    NSMutableArray *gradeMonthArr;
    NSMutableArray *rankMonthArr;
    
    //subject data
    NSMutableArray *scoresArray;
    NSMutableDictionary *scoresStore;
    NSMutableDictionary *groupBySubject;
    
    NSMutableArray *termsArray;
    TermObject *selectedTerm;
    
    LevelPickerViewController *termPicker;
    
    RequestToServer *requestToServer;
}
@end

@implementation SchoolProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [TagManagerHelper pushOpenScreenEvent:@"iSchoolRecords"];
    [self setTitle:LocalizedString(@"School records")];
    
    [self.navigationController setNavigationColor];
    
    [viewHeaderContainer setBackgroundColor:GREEN_COLOR];
    [viewTerm setBackgroundColor:GREEN_COLOR];
    
    lbClass.text = LocalizedString(@"Class:");
    lbAverage1.text = LocalizedString(@"Average of tern I:");
    lbAverage2.text = LocalizedString(@"Average of tern II:");
    lbAverageYear.text = LocalizedString(@"Average of year:");
    
    [btnShow setBackgroundImage:[UIImage imageNamed:@"btn_165_30.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadSchoolProfileData)];
    
    self.navigationItem.rightBarButtonItems = @[refreshButton];
    
    btnMoreInfo.enabled = NO;   //enable after got the information
    
    if (termsArray == nil) {
        termsArray = [[NSMutableArray alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    lbSchoolYear.text = LocalizedString(@"Select a year");
    [lbSchoolYear setTextColor:[UIColor lightGrayColor]];

    [self loadTermList];
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

- (void)reloadSchoolProfileData {
    if (termPicker && termPicker.view.alpha == 1) {
        [UIView animateWithDuration:0.3 animations:^(void) {
            termPicker.view.alpha = 0;
        } completion:^(BOOL finished) {
            [termPicker.view removeFromSuperview];
        }];
    }
    [self loadTermList];
}

- (IBAction)showTermsListPicker:(id)sender {
    [self showLevelPicker];
}

- (void)showLevelPicker {
    if (termPicker == nil) {
        termPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    }
    
    termPicker.pickerType = Picker_Terms;
    termPicker.dataArray = termsArray;
    termPicker.selectedItem = selectedTerm;
    termPicker.view.alpha = 0;
    
    termPicker.delegate = (id)self;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [termPicker.view setFrame:rect];
    
    [self.view addSubview:termPicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        termPicker.view.alpha = 1;
    }];
}

- (void)btnDoneClick:(id)sender withObjectReturned:(id)returnedObj {
    if (returnedObj) {
        [lbSchoolYear setTextColor:[UIColor whiteColor]];
        TermObject *termObj = (TermObject *)returnedObj;
        lbSchoolYear.text = termObj.termName;
        selectedTerm = termObj;
        
        [self loadSchoolRecordForYear:termObj.termID];
    }
}

- (void)loadTermList {
    [SVProgressHUD show];
    [requestToServer getStudentTermList];
}

- (void)loadSchoolRecordForYear:(NSString *)termID {
    [SVProgressHUD show];
    [requestToServer getSchoolRecordForYear:termID];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    
    NSString *url = [jsonObj objectForKey:@"url"];
    
    if ([url rangeOfString:API_NAME_STU_TERMS_LIST].location != NSNotFound) {
        [termsArray removeAllObjects];
        
        NSArray *terms = [jsonObj objectForKey:@"messageObject"];
        
        if (terms != (id)[NSNull null]) {
            for (NSDictionary *termDict in terms) {
                TermObject *termObj = [[TermObject alloc] init];
                
                if ([termDict valueForKey:@"id"] != (id)[NSNull null]) {
                    termObj.termID = [NSString stringWithFormat:@"%@", [termDict valueForKey:@"id"]];
                }
                
                if ([termDict valueForKey:@"years"] != (id)[NSNull null]) {
                    termObj.termName = [termDict valueForKey:@"years"];
                }
                
                [termsArray addObject:termObj];
            }
        }
        
    } else if ([url rangeOfString:API_NAME_STU_SCHOOL_RECORDS].location != NSNotFound) {
        
    }
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];

}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];

    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}
@end
