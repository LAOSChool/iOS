//
//  ScoreCell.m
//  LazzyBee
//
//  Created by HuKhong on 11/9/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import "ScoreCell.h"
#import "CommonDefine.h"
#import "UserScore.h"
#import "Common.h"
#import "LocalizeHelper.h"

@implementation ScoreCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"ScoreCell" owner:self options:nil];
        CGRect rect = self.view.frame;
        rect.size.height = frame.size.height;
        rect.size.width = frame.size.width;
        rect.origin.x = 0;
        rect.origin.y = 0;
        [self.view setFrame:rect];
        [self addSubview:self.view];
        self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.view.layer.borderWidth = 1.0f;
        rect = self.frame;
        self.view.layer.cornerRadius = 5.0f;
        self.view.clipsToBounds = YES;

        /*
        self.view.layer.masksToBounds = NO;
        self.view.layer.shadowOffset = CGSizeMake(-5, 10);
        self.view.layer.shadowRadius = 5;
        self.view.layer.shadowOpacity = 0.5;*/
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setUserScoreObj:(UserScore *)userScoreObj {
    _userScoreObj = userScoreObj;

    if (_userScoreObj) {
        lbMonth.text = _scoreObj.scoreTypeObj.scoreShortName;
        lbScore.text = _scoreObj.score;
        
        if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Normal) {
            viewMonth.backgroundColor = NORMAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Average) {
            viewMonth.backgroundColor = AVERAGE_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Exam) {
            viewMonth.backgroundColor = EXAM_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_TermFinal) {
            viewMonth.backgroundColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_YearFinal) {
            viewMonth.backgroundColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_ExamAgain) {
            viewMonth.backgroundColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreTypeObj.scoreType == ScoreType_Graduate) {
            viewMonth.backgroundColor = FINAL_SCORE;
        }
    }
}

- (IBAction)tapGestureHandle:(id)sender {
    NSMutableDictionary *passedObj = [[NSMutableDictionary alloc] init];
    
    [passedObj setObject:_userScoreObj forKey:@"UserScoreObj"];
    [passedObj setObject:_scoreObj forKey:@"ScoreObj"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapOnScoreCell" object:passedObj];
}
@end
