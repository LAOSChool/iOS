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

#define CELL_OFFSET 5
#define CELL_SIZE_WIDTH 50
#define CELL_SIZE_HEIGHT 50

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
    
    for (ScoreObject *scoreObj in _userScoreObj.scoreArray) {
        count ++;
        CGRect rect;
        rect.size.width = CELL_SIZE_WIDTH;
        rect.size.height = CELL_SIZE_HEIGHT;
        
        if (found == NO && scoreObj.scoreType != ScoreType_Normal) {
            if (col > 0) {
                row++;
                col = 0;
            }
            found = YES;
            rect.origin.x = (CELL_SIZE_WIDTH + CELL_OFFSET) * col;
            rect.origin.y = CELL_OFFSET + (CELL_SIZE_HEIGHT + CELL_OFFSET) * row;
            
            col ++;
            
        } else {
            rect.origin.x = (CELL_SIZE_WIDTH + CELL_OFFSET) * col;
            rect.origin.y = CELL_OFFSET + (CELL_SIZE_HEIGHT + CELL_OFFSET) * row;
            
            col ++;
            
            if (((CELL_SIZE_WIDTH + CELL_OFFSET) * (col + 1)) > viewScorePanel.frame.size.width) {
                col = 0;
                row ++;
            }
        }
        
        ScoreCell *scoreCell = [[ScoreCell alloc] initWithFrame:rect];
        scoreCell.scoreObj = scoreObj;
        scoreCell.userID = _userScoreObj.userID;
        scoreCell.username = _userScoreObj.username;
        scoreCell.additionalInfo = _userScoreObj.additionalInfo;
        scoreCell.avatarLink = _userScoreObj.avatarLink;
        
        [viewScorePanel addSubview:scoreCell];
    }
}
@end