//
//  ScoreCell.h
//  LazzyBee
//
//  Created by HuKhong on 11/9/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreObject.h"

@interface ScoreCell : UIView
{
    
    IBOutlet UILabel *lbMonth;
    IBOutlet UILabel *lbScore;
    IBOutlet UIView *viewMonth;
    
}

@property (strong, nonatomic) IBOutlet UIView *view;


@property (assign, nonatomic) ScoreObject *scoreObj;

@end
