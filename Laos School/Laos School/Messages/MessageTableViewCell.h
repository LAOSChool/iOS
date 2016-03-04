//
//  MessageTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 3/1/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageCellDelegate <NSObject>

@optional // Delegate protocols

- (void)btnFlagClick:(id)sender;

@end

@interface MessageTableViewCell : UITableViewCell
{
    
    
}

@property (nonatomic, strong) IBOutlet UIImageView *imgMesseageType;
@property (nonatomic, strong) IBOutlet UILabel *lbSubject;
@property (nonatomic, strong) IBOutlet UILabel *lbBriefContent;
@property (nonatomic, strong) IBOutlet UILabel *lbTime;
@property (strong, nonatomic) IBOutlet UIButton *btnImportanceFlag;

@property(nonatomic, readwrite) id <MessageCellDelegate> delegate;

@end
