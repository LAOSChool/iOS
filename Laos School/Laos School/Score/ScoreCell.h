//
//  ScoreCell.h
//  LazzyBee
//
//  Created by HuKhong on 11/9/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreObject.h"

@protocol ScoreCellDelegate <NSObject>

@optional // Delegate protocols

- (void)tapGestureHandle:(id)sender;

@end

@interface ScoreCell : UIView
{
    
    IBOutlet UILabel *lbMonth;
    IBOutlet UILabel *lbScore;
    IBOutlet UIView *viewMonth;
    
}

@property (strong, nonatomic) IBOutlet UIView *view;

/*these properties are used for teacher account */
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, strong) NSString *avatarLink;

@property (assign, nonatomic) ScoreObject *scoreObj;

@property (strong, nonatomic) id<ScoreCellDelegate> delegate;

@end
