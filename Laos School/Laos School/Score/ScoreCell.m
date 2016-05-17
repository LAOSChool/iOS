//
//  ScoreCell.m
//  LazzyBee
//
//  Created by HuKhong on 11/9/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import "ScoreCell.h"
#import "CommonDefine.h"
#import "Common.h"
#import "LocalizeHelper.h"

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
        lbMonth.text = [[DateTimeHelper sharedDateTimeHelper] convertMonthFromInt:_scoreObj.month];
        lbScore.text = _scoreObj.score;
        
        if (_scoreObj.scoreType == ScoreType_Normal) {
            viewMonth.backgroundColor = GREEN_COLOR;
            
        } else if (_scoreObj.scoreType == ScoreType_Final) {
            lbMonth.text = LocalizedString(@"Final");
            viewMonth.backgroundColor = [UIColor redColor];
        }
    }
}


- (IBAction)tapGestureHandle:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TapOnScoreCell" object:_scoreObj];
}
@end
