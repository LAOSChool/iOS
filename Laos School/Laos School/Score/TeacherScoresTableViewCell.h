//
//  TeacherScoresTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 3/31/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface TeacherScoresTableViewCell : UITableViewCell
{
    
}
@property (strong, nonatomic) IBOutlet AsyncImageView *imgAvatar;

@property (strong, nonatomic) IBOutlet UILabel *lbFullname;
@property (strong, nonatomic) IBOutlet UILabel *lbAdditionalInfo;

@property (strong, nonatomic) IBOutlet UILabel *lbScore1;
@property (strong, nonatomic) IBOutlet UILabel *lbScore2;
@property (strong, nonatomic) IBOutlet UILabel *lbScoreFinalTest;
@property (strong, nonatomic) IBOutlet UILabel *lbAverage;
@end
