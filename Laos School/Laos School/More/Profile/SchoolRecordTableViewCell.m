//
//  SchoolRecordTableViewCell.m
//  Laos School
//
//  Created by HuKhong on 5/12/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "SchoolRecordTableViewCell.h"
#import "ScoreCell.h"
#import "ScoreObject.h"

#define CELL_OFFSET 5
#define CELL_SIZE 40

@implementation SchoolRecordTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setScoresArray:(NSArray *)scoresArray {
    _scoresArray = scoresArray;
    NSInteger count = 0;
    NSInteger row = 0;
    NSInteger col = 0;
    for (ScoreObject *scoreObj in scoresArray) {
        count ++;
        CGRect rect;
        rect.size.width = CELL_SIZE;
        rect.size.height = CELL_SIZE;
        
        rect.origin.x = (CELL_SIZE + CELL_OFFSET) * col;
        rect.origin.y = CELL_OFFSET + (CELL_SIZE + CELL_OFFSET) * row;
        
        col ++;
        
        if (((CELL_SIZE + CELL_OFFSET) * (col + 1)) > viewScorePanel.frame.size.width) {
            col = 0;
            row ++;
        }
        
        ScoreCell *scoreCell = [[ScoreCell alloc] initWithFrame:rect];
        scoreCell.scoreObj = scoreObj;
        
        [viewScorePanel addSubview:scoreCell];
    }
}
@end
