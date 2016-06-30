//
//  ScoreDetailViewController.h
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserScore.h"

@interface ScoreDetailViewController : UIViewController
{
    IBOutlet UILabel *lbSubject;
    IBOutlet UILabel *lbScoreMonth;
    IBOutlet UILabel *lbScore;
    IBOutlet UILabel *lbComment;
    IBOutlet UILabel *lbTeacherName;
    IBOutlet UILabel *lbDateTime;

    IBOutlet UIView *viewContainer;
}

@property(nonatomic, strong) UserScore *userScoreObj;
@property(nonatomic, strong) ScoreObject *scoreObj;

- (void)loadInformation;
@end
