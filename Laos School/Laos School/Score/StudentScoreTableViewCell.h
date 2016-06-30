//
//  StudentScoreTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 5/12/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserScore.h"

@interface StudentScoreTableViewCell : UITableViewCell
{
    IBOutlet UIView *viewScorePanel;
    
}
@property (strong, nonatomic) IBOutlet UILabel *lbSubject;

@property (nonatomic, strong) UserScore *userScoreObj;
@property (nonatomic, strong) NSString *curTerm;

@end
