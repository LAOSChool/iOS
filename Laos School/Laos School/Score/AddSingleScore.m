//
//  AddSingleScore.m
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "AddSingleScore.h"
#import "ScoreObject.h"
#import "TagManagerHelper.h"
#import "LocalizeHelper.h"
#import "DateTimeHelper.h"
#import "CommonDefine.h"
#import "ShareData.h"
#import "RequestToServer.h"

#import "SVProgressHUD.h"

#define TEXT_PLACEHOLDER LocalizedString(@"Comment")

@interface AddSingleScore ()
{
    RequestToServer *requestToServer;
}
@end

@implementation AddSingleScore

- (void)viewDidLoad {
    [super viewDidLoad];
    [TagManagerHelper pushOpenScreenEvent:@"iAddSingleScore"];
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
    
    if (_userScoreObj) {
        ScoreObject *scoreObj = [_userScoreObj.scoreArray objectAtIndex:0];
        
        lbStudentName.text = _userScoreObj.username;
        lbAdditionalInfo.text = _userScoreObj.additionalInfo;
        lbSubject.text = scoreObj.subject;
//        lbScoreMonth.text = scoreObj.scoreName;
        
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
        
        [txtScore becomeFirstResponder];
        
        if (scoreObj.comment == nil || scoreObj.comment.length == 0) {
            txtComment.text = TEXT_PLACEHOLDER;
            
            txtComment.textColor = [UIColor lightGrayColor];
            
        } else {
            txtComment.text = scoreObj.comment;
            txtComment.textColor = [UIColor darkGrayColor];
        }
        
        txtScore.enabled = _editFlag;
        txtComment.editable = _editFlag;
        btnSubmit.enabled = _editFlag;
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
     
     },*//*
    if ([_userScoreObj.scoreArray count] > 0) {
        ScoreObject *scoreObj = [_userScoreObj.scoreArray objectAtIndex:0];
        
        [scoreDict setValue:[[ShareData sharedShareData] userObj].shoolID forKey:@"school_id"];
        [scoreDict setValue:[[ShareData sharedShareData] userObj].classObj.classID forKey:@"class_id"];
        [scoreDict setValue:txtScore.text forKey:@"sresult"];
        [scoreDict setValue:_userScoreObj.userID forKey:@"student_id"];
        [scoreDict setValue:scoreObj.subjectID forKey:@"subject_id"];
        [scoreDict setValue:scoreObj.examID forKey:@"exam_id"];
        [scoreDict setValue:scoreObj.termID forKey:@"term_id"];
        [scoreDict setValue:txtComment.text forKey:@"notice"];
        
        [requestToServer submitScoreWithObject:scoreDict];
    }*/
}


- (void)setUserScoreObj:(UserScore *)userScoreObj {
    [btnSubmit setTitle:LocalizedString(@"Submit") forState:UIControlStateNormal];
    btnSubmit.enabled = NO;
    
    _userScoreObj = userScoreObj;
    
    ScoreObject *scoreObj = [_userScoreObj.scoreArray objectAtIndex:0];
    
    lbStudentName.text = _userScoreObj.username;
    lbAdditionalInfo.text = _userScoreObj.additionalInfo;
    lbSubject.text = scoreObj.subject;
 //   lbScoreMonth.text = scoreObj.scoreName;
    
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
    /*messageObject =     {
     "class_id" = 1;
     "exam_dt" = "2016-06-14 15:03:17";
     "exam_id" = 2;
     "exam_month" = "<null>";
     "exam_name" = "<null>";
     "exam_type" = "<null>";
     "exam_year" = 2016;
     id = 2;
     notice = "Nam test";
     "sch_year_id" = 1;
     "school_id" = 1;
     sresult = 10;
     "std_nickname" = "Student 10";
     "std_photo" = "http://192.168.0.202:9090/eschool_content/avatar/student1.png";
     "student_id" = 10;
     "student_name" = 00000010;
     subject = "<null>";
     "subject_id" = 1;
     teacher = "<null>";
     "teacher_id" = 5;
     term = "HK 1";
     "term_id" = 1;
     "term_val" = 1;
     };*/
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
