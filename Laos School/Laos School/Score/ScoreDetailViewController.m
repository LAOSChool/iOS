//
//  ScoreDetailViewController.m
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "ScoreDetailViewController.h"

#import "TagManagerHelper.h"
#import "LocalizeHelper.h"
#import "DateTimeHelper.h"
#import "CommonDefine.h"

@interface ScoreDetailViewController ()
{

}
@end

@implementation ScoreDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TagManagerHelper pushOpenScreenEvent:@"iScoreDetail"];
    // Do any additional setup after loading the view from its nib.
    [lbSubject setTextColor:BLUE_COLOR];
    [lbScore setTextColor:[UIColor redColor]];
    [lbComment setTextColor:GREEN_COLOR];


    viewContainer.layer.borderColor = [UIColor darkGrayColor].CGColor;
    viewContainer.layer.borderWidth = 1.0f;
    viewContainer.layer.cornerRadius = 1.0f;
    viewContainer.clipsToBounds = YES;
    
    viewContainer.layer.masksToBounds = NO;
    viewContainer.layer.shadowOffset = CGSizeMake(-5, 10);
    viewContainer.layer.shadowRadius = 5;
    viewContainer.layer.shadowOpacity = 0.5;
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

- (void)loadInformation {/*
    NSString *scoreName = @"";
    if (_scoreObj) {
        scoreName = _scoreObj.scoreDisplayName;
        lbScore.text = _scoreObj.score;
        
        if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Normal) {
            lbScoreMonth.textColor = NORMAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Average) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                scoreName = _scoreObj.scoreName;
            }
            
            lbScoreMonth.textColor = AVERAGE_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Exam) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                scoreName = _scoreObj.scoreName;
            }
            lbScoreMonth.textColor = EXAM_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Final) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                scoreName = _scoreObj.scoreName;
            }
            lbScoreMonth.textColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_YearFinal) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                scoreName = _scoreObj.scoreName;
            }
            lbScoreMonth.textColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_ExamAgain) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                scoreName = _scoreObj.scoreName;
            }
            lbScoreMonth.textColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Graduate) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                scoreName = _scoreObj.scoreName;
            }
            lbScoreMonth.textColor = FINAL_SCORE;
        }
    }
    
    lbSubject.text = _scoreObj.subject;
    lbScoreMonth.text = [NSString stringWithFormat:@"%@ - %@", _scoreObj.term , scoreName];    
    
    lbScore.text = _scoreObj.score;
    
    lbComment.text = _scoreObj.comment;
    lbTeacherName.text = _scoreObj.teacherName;
    lbDateTime.text = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:_scoreObj.dateTime withFormat:@"yyyy-MM-dd"];
    */
}
@end
