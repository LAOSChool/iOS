//
//  ReasonViewController.m
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "ReasonViewController.h"
#import "Common.h"
#import "TagManagerHelper.h"

@interface ReasonViewController ()
{
    NSMutableDictionary *levelsDictionary;
    NSMutableArray *wordList;
    NSArray *keyArr;
}
@end

@implementation ReasonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TagManagerHelper pushOpenScreenEvent:@"iReasonViewController"];
    // Do any additional setup after loading the view from its nib.
    levelsDictionary = [[NSMutableDictionary alloc] init];
    wordList = [[NSMutableArray alloc] init];

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
- (IBAction)tapGestureHandle:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)cancelBtnClick:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)loadInformation {
    [wordList removeAllObjects];
    [levelsDictionary removeAllObjects];
    
    [wordList addObjectsFromArray:[[CommonSqlite sharedCommonSqlite] getStudiedList]];
    
    for (WordObject *wordObj in wordList) {
        NSMutableArray *arr = [levelsDictionary objectForKey:wordObj.level];
        
        if (arr == nil) {
            arr = [[NSMutableArray alloc] init];
        }
        [arr addObject:wordObj];
        
        [levelsDictionary setObject:arr forKey:wordObj.level];
    }
    
    keyArr = [levelsDictionary allKeys];
    
    //display info
    lbTotalValue.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[wordList count]];
    lbLevel1Value.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[[levelsDictionary objectForKey:@"1"] count]];
    lbLevel2Value.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[[levelsDictionary objectForKey:@"2"] count]];
    lbLevel3Value.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[[levelsDictionary objectForKey:@"3"] count]];
    lbLevel4Value.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[[levelsDictionary objectForKey:@"4"] count]];
    lbLevel5Value.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[[levelsDictionary objectForKey:@"5"] count]];
    lbLevel6Value.text = [NSString stringWithFormat:@"%lu word(s)", (unsigned long)[[levelsDictionary objectForKey:@"6"] count]];
    
    //temporary use level 7 for streak
    NSInteger countStreak = [[Common sharedCommon] getCountOfStreak];
    lbLevel7Title.text = @"Streak:";
    
    lbLevel7Value.text = [NSString stringWithFormat:@"%lu day(s)", (unsigned long)countStreak];
}
@end
