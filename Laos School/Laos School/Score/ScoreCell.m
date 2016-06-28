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

- (void)setScoreObj:(ScoreObject *)scoreObj {
    _scoreObj = scoreObj;
    
    if (_scoreObj) {
//        lbMonth.text = [[DateTimeHelper sharedDateTimeHelper] convertMonthFromInt:_scoreObj.month];
        lbMonth.text = _scoreObj.scoreDisplayName;
        lbScore.text = _scoreObj.score;
        
        if (_scoreObj.scoreType == ScoreType_Normal) {
            viewMonth.backgroundColor = NORMAL_SCORE;
            
        } else if (_scoreObj.scoreType == ScoreType_Average) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                lbMonth.text = _scoreObj.scoreName;
            }

            viewMonth.backgroundColor = AVERAGE_SCORE;
            
        } else if (_scoreObj.scoreType == ScoreType_Exam) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                lbMonth.text = _scoreObj.scoreName;
            }
            viewMonth.backgroundColor = EXAM_SCORE;
            
        } else if (_scoreObj.scoreType == ScoreType_Final) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                lbMonth.text = _scoreObj.scoreName;
            }
            viewMonth.backgroundColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreType == ScoreType_YearFinal) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                lbMonth.text = _scoreObj.scoreName;
            }
            viewMonth.backgroundColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreType == ScoreType_ExamAgain) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                lbMonth.text = _scoreObj.scoreName;
            }
            viewMonth.backgroundColor = FINAL_SCORE;
            
        } else if (_scoreObj.scoreType == ScoreType_Graduate) {
            if (_scoreObj.scoreDisplayName.length == 0) {
                lbMonth.text = _scoreObj.scoreName;
            }
            viewMonth.backgroundColor = FINAL_SCORE;
        }
    }
}

- (IBAction)tapGestureHandle:(id)sender {
    if (_userID && _userID.length > 0) {
        UserScore *newUserScoreObj = [[UserScore alloc] init];
        
        newUserScoreObj.userID = _userID;
        newUserScoreObj.username = _username;
        newUserScoreObj.additionalInfo = _additionalInfo;
        newUserScoreObj.avatarLink = _avatarLink;
        
        [newUserScoreObj.scoreArray addObject:_scoreObj];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TapOnScoreCell" object:newUserScoreObj];
    } else {
        if (_scoreObj) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TapOnScoreCell" object:_scoreObj];
        }
    }
}
@end
