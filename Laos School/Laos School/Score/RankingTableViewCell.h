//
//  RankingTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 7/6/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RankingTableViewCell : UITableViewCell
{
    
}

@property (strong, nonatomic) IBOutlet UILabel *lbScoreType;
@property (strong, nonatomic) IBOutlet UILabel *lbAverage;
@property (strong, nonatomic) IBOutlet UILabel *lbGrade;
@property (strong, nonatomic) IBOutlet UILabel *lbRanking;
@property (strong, nonatomic) IBOutlet UILabel *lbAverageValue;
@property (strong, nonatomic) IBOutlet UILabel *lbGradeValue;
@property (strong, nonatomic) IBOutlet UILabel *lbRankValue;

@end
