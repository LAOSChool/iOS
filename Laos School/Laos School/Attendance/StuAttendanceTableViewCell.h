//
//  StuAttendanceTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 3/3/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AttendanceCellDelegate <NSObject>

@optional // Delegate protocols

- (void)longpressGestureHandle:(id)sender;

@end

@interface StuAttendanceTableViewCell : UITableViewCell
{
    
}

@property (strong, nonatomic) IBOutlet UILabel *lbReason;
@property (strong, nonatomic) IBOutlet UILabel *lbDate;
@property (strong, nonatomic) IBOutlet UILabel *lbSession;
@property (strong, nonatomic) IBOutlet UIImageView *imgArrow;

@property (strong, nonatomic) id<AttendanceCellDelegate> delegate;

@end
