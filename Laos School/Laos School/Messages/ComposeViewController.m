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

#import "ShareData.h"
#import "RequestToServer.h"
#import "LocalizeHelper.h"
#import "UserObject.h"
#import "CommonDefine.h"
#import "SVProgressHUD.h"
#import "CoreDataUtil.h"

@interface ComposeViewController ()
{
    RequestToServer *requestToServer;
}
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
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    if ([[ShareData sharedShareData] userObj].userRole == UserRole_Student) {
        lbTeacherReceiverList.text = [[ShareData sharedShareData] userObj].classObj.teacherName;
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
    if ([_receiverArray count] == 0 && [[ShareData sharedShareData] userObj].userRole == UserRole_Student) {
        [_receiverArray addObject:[[ShareData sharedShareData] userObj].classObj.teacherID];
    }
    
    NSMutableDictionary *messageDict = [[NSMutableDictionary alloc] init];
    //create message json
    /*
     {
     channel = 1;
     "class_id" = 1;
     content = "test message";
     "from_user_name" = NamNT1;
     "from_usr_id" = 1;
     id = 1;
     "imp_flg" = 1;
     "is_read" = 1;
     "is_sent" = 1;
     messageType = NX;
     "msg_type_id" = 1;
     other = "ko co gi quan trong";
     "read_dt" = "2016-03-24 00:00:00.0";
     schoolName = "Truong Tieu Hoc Thanh Xuan Trung";
     "school_id" = 1;
     "sent_dt" = "2016-03-24 00:00:00.0";
     title = title;
     "to_user_name" = Hue1;
     "to_usr_id" = "2,3,4,5,6";
     }
     
     },*/
    
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].userID forKey:@"from_usr_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].classObj.teacherID forKey:@"to_usr_id"];
    [messageDict setValue:[[ShareData sharedShareData] userObj].username forKey:@"from_user_name"];
    [messageDict setValue:txtSubject.text forKey:@"title"];
    [messageDict setValue:txtContent.text forKey:@"content"];
    
    if (_messageObject.importanceType == ImportanceHigh) {
        [messageDict setObject:[NSNumber numberWithInteger:1] forKey:@"imp_flg"];
        
    } else {
        [messageDict setObject:[NSNumber numberWithInteger:0] forKey:@"imp_flg"];
    }
    
    [requestToServer createMessageWithObject:messageDict];
    
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

#pragma mark RequestToServer delegate
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj {
    [SVProgressHUD showSuccessWithStatus:@"Sent"];
    
    MessageObject *messageObj = [[MessageObject alloc] initWithMessageDictionary:jsonObj];
    
    if (messageObj) {
        dispatch_async([CoreDataUtil getDispatch], ^(){
            
            [[CoreDataUtil sharedCoreDataUtil] insertNewMessage:messageObj];
            //
            //        dispatch_async(dispatch_get_main_queue(), ^(){
            //
            //        });
        });
    }
}

- (void)failToConnectToServer {
    
}

- (void)sendPostRequestFailedWithUnknownError {
    
}

- (void)sendPostRequestSuccessfully {
    
}
@end
