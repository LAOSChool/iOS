//
//  ScoreCell.h
//  LazzyBee
//
//  Created by HuKhong on 11/9/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreCell : UIView
{
    
    IBOutlet UILabel *lbMonth;
    IBOutlet UILabel *lbScore;
    
}

@property (strong, nonatomic) IBOutlet UIView *view;


@property (strong, nonatomic) NSString *month;
@property (assign, nonatomic) NSString *score;

@end
