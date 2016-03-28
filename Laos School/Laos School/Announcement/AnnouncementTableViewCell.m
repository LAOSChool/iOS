//
//  AnnouncementTableViewCell.m
//  Laos School
//
//  Created by HuKhong on 3/28/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "AnnouncementTableViewCell.h"

@implementation AnnouncementTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)btnFlagClick:(id)sender {
    [self.delegate btnFlagClick:self];
}

@end
