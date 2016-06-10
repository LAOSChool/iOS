//
//  AddScoreTableViewCell.m
//  Laos School
//
//  Created by HuKhong on 6/10/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "AddScoreTableViewCell.h"

@implementation AddScoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.txtScore.delegate = (id)self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)txtScoreChanged:(id)sender {
    UITextField *textField = (UITextField *)sender;
    [self.delegate inputScoreTo:self withValueReturned:textField.text];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}
@end
