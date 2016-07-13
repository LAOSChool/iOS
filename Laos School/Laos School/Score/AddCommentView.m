//
//  AddCommentView.m
//  LazzyBee
//
//  Created by HuKhong on 10/15/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import "AddCommentView.h"
#import "LocalizeHelper.h"
#import "ScoreObject.h"
#import "CommonDefine.h"

#define TEXT_PLACEHOLDER LocalizedString(@"Comment")

@implementation AddCommentView
{
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"AddCommentView" owner:self options:nil];
        CGRect rect = self.view.frame;
        rect.size.height = frame.size.height;
        rect.size.width = frame.size.width;
        [self.view setFrame:rect];
        
        [self addSubview:self.view];
        
        self.view.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.view.layer.borderWidth = 1.0f;
        
//        self.view.layer.cornerRadius = 5.0f;
//        self.view.clipsToBounds = YES;
        
        self.view.layer.masksToBounds = NO;
        self.view.layer.shadowOffset = CGSizeMake(-5, 10);
        self.view.layer.shadowRadius = 5;
        self.view.layer.shadowOpacity = 0.5;

        btnSave.enabled = NO;
        [txtComment becomeFirstResponder];
        
        [viewHeader setBackgroundColor:COMMON_COLOR];
        
        lbTitle.text = LocalizedString(@"Comment");
        
        _isShowing = YES;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

- (void)setUserScore:(UserScore *)userScore {
    [viewHeader setBackgroundColor:COMMON_COLOR];
    
    lbTitle.text = LocalizedString(@"Comment");
    [btnSave setTitle:LocalizedString(@"Save") forState:UIControlStateNormal];
    
    _userScore = userScore;
    ScoreObject *scoreObj = [userScore.scoreArray objectAtIndex:0];
    
    lbStudentName.text = userScore.username;
    lbAdditionalInfo.text = userScore.additionalInfo;
    
    if (userScore.avatarLink && userScore.avatarLink.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgAvatar];
        
        //load the image
        imgAvatar.imageURL = [NSURL URLWithString:userScore.avatarLink];
        
    }
    
    if (scoreObj.comment != nil && scoreObj.comment.length == 0) {
        txtComment.text = scoreObj.comment;
        txtComment.textColor = [UIColor darkGrayColor];
    }
    
    btnSave.enabled = NO;
    [txtComment becomeFirstResponder];
}

- (IBAction)panGestureHandle:(id)sender {
    CGPoint translation = [(UIPanGestureRecognizer*)sender translationInView:self.superview];
    [self setCenter:CGPointMake([self center].x + translation.x,
                                [self center].y + translation.y)];
    [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0, 0) inView:self.view];
}

- (IBAction)btnSaveClick:(id)sender {
    
//    if ([txtComment.text isEqualToString:TEXT_PLACEHOLDER]) {
//        txtComment.text = @"";
//    }
    
    ScoreObject *scoreObj = [_userScore.scoreArray objectAtIndex:0];
    
    scoreObj.comment = txtComment.text;
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self setAlpha:0];
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self setAlpha:1];
    }];
    
    _isShowing = NO;
}


- (IBAction)btnCloseClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self setAlpha:0];
        
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self setAlpha:1];
    }];
    
    _isShowing = NO;
}

#pragma mark text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //set placeholder, because it's not support by default
//    if ([txtComment.text isEqualToString:TEXT_PLACEHOLDER]) {
//        txtComment.text = @"";
//        txtComment.textColor = [UIColor darkGrayColor]; //optional
//    }
    
    [txtComment becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{

    ScoreObject *scoreObj = [_userScore.scoreArray objectAtIndex:0];
    
    if (![txtComment.text isEqualToString:scoreObj.comment]) {
        btnSave.enabled = YES;
    } else {
        btnSave.enabled = NO;
    }
    
    [textView resignFirstResponder];
}

- (void)textViewDidChange:(UITextView *)textView {
    ScoreObject *scoreObj = [_userScore.scoreArray objectAtIndex:0];
    if (![txtComment.text isEqualToString:scoreObj.comment]) {
        btnSave.enabled = YES;
    } else {
        btnSave.enabled = NO;
    }
}

@end
