//
//  TeacherScoreTableViewCell.m
//  Laos School
//
//  Created by HuKhong on 6/8/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "TeacherScoreTableViewCell.h"
#import "ScoreCell.h"
#import "ScoreObject.h"
#import "CommonDefine.h"

#define CELL_OFFSET 5
#define CELL_SIZE_WIDTH 50
#define CELL_SIZE_HEIGHT 50

#define CELL_SIZE_WIDTH_IPAD 60
#define CELL_SIZE_HEIGHT_IPAD 60

@implementation TeacherScoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setUserScoreObj:(UserScore *)userScoreObj {
    _userScoreObj = userScoreObj;

    NSInteger count = 0;
    NSInteger row = 0;
    NSInteger col = 0;
    BOOL found = NO;
    
    //remove all old subviews
    for (UIView *view in viewScorePanel.subviews) {
        [view removeFromSuperview];
    }
    
    NSInteger widthConst = CELL_SIZE_WIDTH;
    NSInteger heightConst = CELL_SIZE_HEIGHT;
    
    if (IS_IPAD) {
        widthConst = CELL_SIZE_WIDTH_IPAD;
        heightConst = CELL_SIZE_HEIGHT_IPAD;
    }
    
    for (ScoreObject *scoreObj in _userScoreObj.scoreArray) {
        if ([_curTerm isEqualToString:TERM_VALUE_1]) {
            if (!([scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_SEP] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_OCT] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_NOV] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_DEC] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_AVE4M1] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_TERM_EXAM1] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_AVE_TERM1])) {
                
                continue;
            }
        } else if ([_curTerm isEqualToString:TERM_VALUE_2]) {
            if (!([scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_FEB] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_MAR] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_APR] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_MAY] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_AVE4M2] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_TERM_EXAM2] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_AVE_TERM2] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_OVERALL] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_RETEST] ||
                  [scoreObj.scoreTypeObj.scoreKey isEqualToString:SCORE_KEY_GRADUATION])) {
                
                continue;
            }
        } else {
            break;
        }
        
        count ++;
        CGRect rect;
        rect.size.width = widthConst;
        rect.size.height = heightConst;
        
        if (found == NO && scoreObj.scoreTypeObj.scoreType != ScoreType_Normal) {
            if (col > 0) {
                row++;
                col = 0;
            }
            
            found = YES;
            rect.origin.x = (widthConst + CELL_OFFSET) * col;
            rect.origin.y = CELL_OFFSET + (heightConst + CELL_OFFSET) * row;
            
            col ++;
            
        } else {
            rect.origin.x = (widthConst + CELL_OFFSET) * col;
            rect.origin.y = CELL_OFFSET + (heightConst + CELL_OFFSET) * row;
            
            col ++;
            
            if (((widthConst + CELL_OFFSET) * (col + 1)) > viewScorePanel.frame.size.width) {
                col = 0;
                row ++;
            }
        }
        
        ScoreCell *scoreCell = [[ScoreCell alloc] initWithFrame:rect];
        scoreCell.scoreObj = scoreObj;  //set scoreObj before userScoreObj
        scoreCell.userScoreObj = userScoreObj;
        scoreCell.userID = _userScoreObj.userID;
        scoreCell.username = _userScoreObj.displayName;
        scoreCell.additionalInfo = _userScoreObj.additionalInfo;
        scoreCell.avatarLink = _userScoreObj.avatarLink;
        
        [viewScorePanel addSubview:scoreCell];
    }
}
@end
