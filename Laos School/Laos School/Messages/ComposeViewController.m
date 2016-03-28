//
//  ComposeViewController.m
//  Laos School
//
//  Created by HuKhong on 2/29/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ComposeViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "StudentsListViewController.h"

#import "LocalizeHelper.h"
#import "UserObject.h"
#import "CommonDefine.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"New Message")];
    
    [self.navigationController setNavigationColor];
    
    if (_receiverArray == nil) {
        _receiverArray = [[NSMutableArray alloc] init];
    }
    
    if (_messageObject == nil) {
        _messageObject = [[MessageObject alloc] init];
    }
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(sendNewMessage)];
    
    self.navigationItem.rightBarButtonItems = @[btnSend];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectReceiverCompletedHandle)
                                                 name:@"SelectReceiverCompleted"
                                               object:nil];
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

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendNewMessage {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SentNewMessage" object:nil];
}

#pragma mark teacher view
- (IBAction)btnAddClick:(id)sender {
    StudentsListViewController *studentsList = [[StudentsListViewController alloc] initWithNibName:@"StudentsListViewController" bundle:nil];
    studentsList.selectedArray = _receiverArray;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:studentsList];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnPriorityFlagClick:(id)sender {
    if (_messageObject.importanceType == ImportanceNormal) {
        _messageObject.importanceType = ImportanceHigh;
        
    } else {
        _messageObject.importanceType = ImportanceNormal;
    }
    
    if (_messageObject.importanceType == ImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
}


- (void)selectReceiverCompletedHandle {
    NSString *receiverString = @"";
    
    if ([_receiverArray count] > 0) {
        for (UserObject *userObj in _receiverArray) {
            receiverString = [receiverString stringByAppendingFormat:@"%@, ", userObj.nickName];
        }
        
//        if ([_receiverArray count] == 1) {
//            receiverString = [receiverString stringByAppendingFormat:@"...(%lu)\n", (unsigned long)[_receiverArray count]];
//            
//        } else {
//            receiverString = [receiverString stringByAppendingFormat:@"...(%lu)\n", (unsigned long)[_receiverArray count]];
//        }
        
        receiverString = [receiverString stringByAppendingString:@"\n"];
    }
    
    lbTeacherReceiverList.text = receiverString;
}
@end
