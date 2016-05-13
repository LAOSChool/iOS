//
//  ScoreCell.m
//  LazzyBee
//
//  Created by HuKhong on 11/9/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import "ScoreCell.h"
#import "CommonDefine.h"

// Our conversion definition
#define DEGREES_TO_RADIANS(angle) (angle / 180.0 * M_PI)

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
        
        viewMonth.backgroundColor = GREEN_COLOR;

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
        lbMonth.text = [self convertMonthFromInt:[_scoreObj.month integerValue]];
        lbScore.text = _scoreObj.score;
    }
}

- (NSString *)convertMonthFromInt:(NSInteger)month {
    NSString *res = @"";
    
    switch (month) {
        case 1:
            res = @"Jan";
            break;
            
        case 2:
            res = @"Feb";
            break;
        case 3:
            res = @"Mar";
            break;
        case 4:
            res = @"Apr";
            break;
        case 5:
            res = @"May";
            break;
        case 6:
            res = @"Jun";
            break;
        case 7:
            res = @"Jul";
            break;
        case 8:
            res = @"Aug";
            break;
        case 9:
            res = @"Sep";
            break;
        case 10:
            res = @"Oct";
            break;
        case 11:
            res = @"Nov";
            break;
        case 12:
            res = @"Dec";
            break;
            
        default:
            break;
    }
    
    return res;
}
@end
