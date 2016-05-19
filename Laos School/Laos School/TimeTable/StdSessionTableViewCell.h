//
//  StdSessionTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 5/18/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StdSessionTableViewCell : UITableViewCell
{
    
}
@property (strong, nonatomic) IBOutlet UILabel *lbSession;
@property (strong, nonatomic) IBOutlet UILabel *lbDuration;
@property (strong, nonatomic) IBOutlet UILabel *lbSubject;
@property (strong, nonatomic) IBOutlet UILabel *lbTeacherName;
@property (strong, nonatomic) IBOutlet UILabel *lbAddionalInfo;
@end
