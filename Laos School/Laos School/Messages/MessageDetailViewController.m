//
//  MessageDetailViewController.m
//  Laos School
//
//  Created by HuKhong on 3/1/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "CommonDefine.h"
#import "RequestToServer.h"
#import "CoreDataUtil.h"
#import "LocalizeHelper.h"

@interface MessageDetailViewController ()
{
    RequestToServer *requestToServer;
}
@end

@implementation MessageDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:_messageObject.subject];
    
    /*
     IBOutlet UIImageView *imgAvatar;
     IBOutlet UIButton *btnImportanceFlag;
     IBOutlet UILabel *lbFromUsername;
     IBOutlet UILabel *lbDateTime;
     IBOutlet UILabel *lbSubject;
     IBOutlet UITextView *txtContent;
     */
    if (_messageObject.importanceType == ImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }

    if (_messageObject.subject != (id)[NSNull null]) {
        lbSubject.text = _messageObject.subject;
    }
    
    if (_messageObject.content != (id)[NSNull null]) {
        txtContent.text = _messageObject.content;
    }
    
    if (_messageObject.dateTime != (id)[NSNull null]) {
        lbDateTime.text = _messageObject.dateTime;
    }
    
    if (_messageObject.fromUsername != (id)[NSNull null]) {
        lbFromUsername.text = _messageObject.fromUsername;
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.navigationController setNavigationColor];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnImportanceFlagClick:(id)sender {
    
    if (_messageObject.importanceType == ImportanceNormal) {
        _messageObject.importanceType = ImportanceHigh;
        [[CoreDataUtil sharedCoreDataUtil] updateMessageImportance:_messageObject.messageID withFlag:YES];
        [requestToServer updateMessageImportance:_messageObject.messageID withFlag:YES];
        
    } else {
        _messageObject.importanceType = ImportanceNormal;
        [[CoreDataUtil sharedCoreDataUtil] updateMessageImportance:_messageObject.messageID withFlag:NO];
        [requestToServer updateMessageImportance:_messageObject.messageID withFlag:NO];
    }
    
    if (_messageObject.importanceType == ImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAfterUpdateFlag" object:nil];
}

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {

}

- (void)failToConnectToServer {

}

- (void)sendPostRequestFailedWithUnknownError {
    
}

- (void)accountLoginByOtherDevice {
    [self showAlertAccountLoginByOtherDevice];
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}
@end
