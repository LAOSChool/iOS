//
//  AddSingleScore.m
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "AddSingleScore.h"
#import "ScoreObject.h"
#import "LocalizeHelper.h"
#import "DateTimeHelper.h"
#import "CommonDefine.h"
#import "ShareData.h"
#import "RequestToServer.h"

#import "SVProgressHUD.h"

@import FirebaseAnalytics;

#define TEXT_PLACEHOLDER LocalizedString(@"Comment")

@interface AddSingleScore ()
{
    RequestToServer *requestToServer;
    CGRect reserveRect;
}
@end

@implementation AddSingleScore

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    viewContainer.layer.borderColor = [UIColor darkGrayColor].CGColor;
    viewContainer.layer.borderWidth = 1.0f;
    viewContainer.layer.cornerRadius = 5.0f;
    viewContainer.clipsToBounds = YES;
    
    viewContainer.layer.masksToBounds = NO;
    viewContainer.layer.shadowOffset = CGSizeMake(-5, 10);
    viewContainer.layer.shadowRadius = 5;
    viewContainer.layer.shadowOpacity = 0.5;
    
    txtComment.layer.borderColor = [UIColor lightGrayColor].CGColor;
    txtComment.layer.borderWidth = 0.3f;
    txtComment.layer.cornerRadius = 5.0f;
    txtComment.clipsToBounds = YES;
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if (_userScoreObj && _scoreObj) {
        
        lbStudentName.text = _userScoreObj.username;
        lbAdditionalInfo.text = _userScoreObj.additionalInfo;
        lbSubject.text = _userScoreObj.subject;
        lbScoreMonth.text = _scoreObj.scoreTypeObj.scoreShortName;
        
        imgAvatar.image = [UIImage imageNamed:@"ic_user_gray.png"];
        
        if (_userScoreObj.avatarLink && _userScoreObj.avatarLink.length > 0) {
            //cancel loading previous image for cell
            [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgAvatar];
            
            //load the image
            imgAvatar.imageURL = [NSURL URLWithString:_userScoreObj.avatarLink];
            
        } else {
            imgAvatar.image = [UIImage imageNamed:@"ic_user_gray.png"];
        }
        
        if (_scoreObj.score.length > 0) {
            txtScore.text = _scoreObj.score;
        } else {
            txtScore.text = @"";
        }
        
        [txtScore becomeFirstResponder];
        
        if (_scoreObj.comment == nil || _scoreObj.comment.length == 0) {
            txtComment.text = TEXT_PLACEHOLDER;
            
            txtComment.textColor = [UIColor lightGrayColor];
            
        } else {
            txtComment.text = _scoreObj.comment;
            txtComment.textColor = [UIColor darkGrayColor];
        }
        
        txtScore.enabled = _editFlag;
        txtComment.editable = _editFlag;
        btnSubmit.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidAppear:(BOOL)animated {
    if (reserveRect.size.height == 0) {
        reserveRect = viewContainer.frame;
    }
}

- (void)resetPosition {
    if (reserveRect.size.height != 0) {
        [viewContainer setFrame:reserveRect];
    }
}

- (IBAction)tapGestureHandle:(id)sender {
    [txtScore resignFirstResponder];
    [txtComment resignFirstResponder];
}

- (IBAction)cancelBtnClick:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)btnSubmitClick:(id)sender {
    [FIRAnalytics logEventWithName:@"submit_single_score" parameters:@{
                                                                         kFIRParameterValue:@(1)
                                                                         }];
    
    NSMutableDictionary *scoreDict = [[NSMutableDictionary alloc] init];
    //create message json
    /*
     {
     jsonObject.addProperty("school_id", school_id);
     jsonObject.addProperty("class_id", class_id);
     jsonObject.addProperty("sresult", sresult);
     
     jsonObject.addProperty("student_id", student_id);
     jsonObject.addProperty("subject_id", subject_id);
     
     jsonObject.addProperty("exam_id", exam_id);
     jsonObject.addProperty("teacher_id", teacher_id);
     jsonObject.addProperty("term_id", term_id);
     jsonObject.addProperty("notice", notice);
     }
     
     },*/
    if (_userScoreObj && _scoreObj) {
        [scoreDict setValue:[[ShareData sharedShareData] userObj].shoolID forKey:@"school_id"];
        [scoreDict setValue:[[ShareData sharedShareData] userObj].classObj.classID forKey:@"class_id"];
        [scoreDict setValue:_userScoreObj.userID forKey:@"student_id"];
        [scoreDict setValue:_userScoreObj.subjectID forKey:@"subject_id"];

        NSMutableDictionary *scoreValueDict = [[NSMutableDictionary alloc] init];
        NSString *comment = txtComment.text;
        if ([txtComment.text isEqualToString:TEXT_PLACEHOLDER]) {
            comment = @"";
        }
        
        [scoreValueDict setValue:comment forKey:@"notice"];
        [scoreValueDict setValue:txtScore.text forKey:@"sresult"];
        
        NSString *dateTime = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeWithFormat:COMMON_DATE_FORMATE];
        [scoreValueDict setValue:dateTime forKey:@"exam_dt"];
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:scoreValueDict options:0 error:nil];
        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [scoreDict setValue:myString forKey:_scoreObj.scoreTypeObj.scoreKey];
        
        [SVProgressHUD show];
        [requestToServer submitScoreWithObject:scoreDict];
    }
}


- (void)setUserScoreObj:(UserScore *)userScoreObj {
    [btnSubmit setTitle:LocalizedString(@"Submit") forState:UIControlStateNormal];
    btnSubmit.enabled = NO;
    
    _userScoreObj = userScoreObj;
    
    ScoreObject *scoreObj = _scoreObj;
    
    lbStudentName.text = _userScoreObj.username;
    lbAdditionalInfo.text = _userScoreObj.additionalInfo;
    lbSubject.text = _userScoreObj.subject;
    lbScoreMonth.text = scoreObj.scoreTypeObj.scoreShortName;
    
    imgAvatar.image = [UIImage imageNamed:@"ic_user_gray.png"];
    
    if (_userScoreObj.avatarLink && _userScoreObj.avatarLink.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgAvatar];
        
        //load the image
        imgAvatar.imageURL = [NSURL URLWithString:_userScoreObj.avatarLink];
        
    } else {
        imgAvatar.image = [UIImage imageNamed:@"ic_user_gray.png"];
    }
    
    if (scoreObj.score.length > 0) {
        txtScore.text = scoreObj.score;
    } else {
        txtScore.text = @"";
    }
    
    if (scoreObj.comment == nil || scoreObj.comment.length == 0) {
        txtComment.text = TEXT_PLACEHOLDER;
        
        txtComment.textColor = [UIColor lightGrayColor];
        
    } else {
        txtComment.text = scoreObj.comment;
        txtComment.textColor = [UIColor darkGrayColor];
    }
}

- (void)setEditFlag:(BOOL)editFlag {
    _editFlag = editFlag;
    
    txtScore.enabled = _editFlag;
    txtComment.editable = _editFlag;
    btnSubmit.enabled = NO;
    
    if (_editFlag) {
        [txtScore becomeFirstResponder];
    }
}

- (IBAction)panGestureHandle:(id)sender {
    CGPoint translation = [(UIPanGestureRecognizer*)sender translationInView:viewContainer.superview];
    [viewContainer setCenter:CGPointMake([viewContainer center].x + translation.x,
                                [viewContainer center].y + translation.y)];
    [(UIPanGestureRecognizer*)sender setTranslation:CGPointMake(0, 0) inView:viewContainer];
    
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect rect = viewContainer.frame;
            
            if (rect.origin.y < 0) {
                rect.origin.y = 0;
            }
            
            if (rect.origin.y > self.view.frame.size.height/2 - 50) {
                rect.origin.y = self.view.frame.size.height/2 - 50;
            }
            
            if (rect.origin.x < 0) {
                rect.origin.x = 0;
            }
            
            if (rect.origin.x + rect.size.width > self.view.frame.size.width) {
                rect.origin.x = self.view.frame.size.width - rect.size.width;
            }
            
            [viewContainer setFrame:rect];
            
        } completion:nil];
    }
    
}

#pragma mark text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //set placeholder, because it's not support by default
    if ([txtComment.text isEqualToString:TEXT_PLACEHOLDER]) {
        txtComment.text = @"";
        txtComment.textColor = [UIColor darkGrayColor]; //optional
    }
    
    [txtComment becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    if ([txtComment.text isEqualToString:@""]) {
        txtComment.text = TEXT_PLACEHOLDER;
        
        txtComment.textColor = [UIColor lightGrayColor];
    }
    
    [textView resignFirstResponder];
}


- (void)textViewDidChange:(UITextView *)textView {
    ScoreObject *scoreObj = [_userScoreObj.scoreArray objectAtIndex:0];
    
    if (![txtComment.text isEqualToString:scoreObj.comment]) {
        btnSubmit.enabled = YES;
    }
}


- (IBAction)textFieldEditChanged:(id)sender {
    ScoreObject *scoreObj = [_userScoreObj.scoreArray objectAtIndex:0];
    
    if (![txtScore.text isEqualToString:scoreObj.score]) {
        btnSubmit.enabled = YES;
    }
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

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD dismiss];
    NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    /**/
    if (statusCode == HttpOK) {
        [SVProgressHUD showSuccessWithStatus:@"Successfully"];
        [UIView animateWithDuration:0.3 animations:^(void) {
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
        }];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SubmitSingleScoreSuccessfully" object:nil];

    } else {
        [self submitScoreFailed];
        
        
    }
    
}

- (void)failToConnectToServer {
    [SVProgressHUD dismiss];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
    [self showAlertAccountLoginByOtherDevice];
}

#pragma mark alert
- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}


- (void)submitScoreFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while submitting score. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
}
@end
