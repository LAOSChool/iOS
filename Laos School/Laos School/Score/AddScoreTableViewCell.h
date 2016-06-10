//
//  AddScoreTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 6/10/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
#import "UserScore.h"


@protocol AddScoreTableViewCellDelegate <NSObject>

@optional // Delegate protocols

- (void)inputScoreTo:(id)sender withValueReturned:(NSString *)value;

@end

@interface AddScoreTableViewCell : UITableViewCell
{
    
}

@property (strong, nonatomic) IBOutlet AsyncImageView *imgAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lbStudentName;
@property (strong, nonatomic) IBOutlet UILabel *lbAdditionalInfo;

@property (strong, nonatomic) IBOutlet UITextField *txtScore;

@property (strong, nonatomic) UserScore *userScore;

@property(nonatomic, readwrite) id <AddScoreTableViewCellDelegate> delegate;

@end
