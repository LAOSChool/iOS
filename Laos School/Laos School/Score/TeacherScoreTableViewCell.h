//
//  TeacherScoreTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 6/8/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface TeacherScoreTableViewCell : UITableViewCell
{
    IBOutlet UIView *viewScorePanel;
    
}
@property (strong, nonatomic) IBOutlet AsyncImageView *imgAvatar;
@property (strong, nonatomic) IBOutlet UILabel *lbStudentName;
@property (strong, nonatomic) IBOutlet UILabel *lbAdditionalInfo;

@property (nonatomic, strong) NSArray *scoresArray;
@end
