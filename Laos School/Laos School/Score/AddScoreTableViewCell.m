//
//  AddScoreTableViewCell.m
//  Laos School
//
//  Created by HuKhong on 6/10/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "AddScoreTableViewCell.h"
#import "ScoreObject.h"

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
//    [self.delegate inputScoreTo:self withValueReturned:textField.text];
    ScoreObject *scoreObj = [_userScore.scoreArray objectAtIndex:0];
    scoreObj.score = textField.text;
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.txtScore resignFirstResponder];
    
    return YES;
}

- (IBAction)textFieldDidBegin:(id)sender {
    [self.delegate textFieldDidBegin:self];
    
}


- (IBAction)btnCommentClick:(id)sender {
    [self.delegate btnCommentClick:self];
}
@end
