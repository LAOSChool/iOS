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
    
    for (ScoreObject *score in _userScore.scoreArray) {
        if ([score.scoreTypeObj.scoreKey isEqualToString:_scoreKey]) {
            
            score.score = textField.text;
            break;
        }
    }
    
    [self.delegate txtScoreChanged:sender];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([self isNumeric:string] == NO) {
        return NO;
    }
    
    if ([textField.text rangeOfString:@"."].location != NSNotFound &&
        [string isEqualToString:@"."]) {
        return NO;
    }
    
    float score = [[textField.text stringByReplacingCharactersInRange:range withString:string] floatValue];
    if (score < 0 || score > 10) {
        return NO;
    }
    
    return YES;
}

- (BOOL)isNumeric:(NSString*)inputString{
    BOOL isValid = NO;
    NSCharacterSet *alphaNumbersSet = [NSCharacterSet characterSetWithCharactersInString:@".0123456789"];
    NSCharacterSet *stringSet = [NSCharacterSet characterSetWithCharactersInString:inputString];
    isValid = [alphaNumbersSet isSupersetOfSet:stringSet];
    return isValid;
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
