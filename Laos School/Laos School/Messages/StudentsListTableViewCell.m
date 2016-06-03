//
//  StudentsListTableViewCell.m
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentsListTableViewCell.h"

@implementation StudentsListTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)longPressGestureHandle:(id)sender {
    UILongPressGestureRecognizer *gest = (UILongPressGestureRecognizer *)sender;
    
    if (gest.state == UIGestureRecognizerStateBegan){
        [self.delegate longpressGestureHandle:self];
    }
}
@end
