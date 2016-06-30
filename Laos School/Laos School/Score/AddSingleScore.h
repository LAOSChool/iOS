//
//  AddSingleScore.h
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserScore.h"
#import "AsyncImageView.h"

@interface AddSingleScore : UIViewController
{
    IBOutlet AsyncImageView *imgAvatar;
    IBOutlet UILabel *lbStudentName;
    
    IBOutlet UILabel *lbAdditionalInfo;
    
    IBOutlet UILabel *lbSubject;
    IBOutlet UILabel *lbScoreMonth;
    IBOutlet UILabel *lbScore;
    IBOutlet UILabel *lbComment;
    IBOutlet UITextField *txtScore;
    IBOutlet UITextView *txtComment;

    IBOutlet UIButton *btnSubmit;

    IBOutlet UIView *viewContainer;
}

@property (nonatomic, strong) UserScore *userScoreObj;
@property (nonatomic, strong) ScoreObject *scoreObj;
@property (nonatomic, assign) BOOL editFlag;

@end
