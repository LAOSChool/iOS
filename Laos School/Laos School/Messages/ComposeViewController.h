//
//  ComposeViewController.h
//  Laos School
//
//  Created by HuKhong on 2/29/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageObject.h"

typedef enum {
    MessageCompose_Normal = 0,
    MessageCompose_Attendance,
    MessageCompose_Inform,
    MessageCompose_Max
} MESSAGE_COMPOSE_TYPE;

@interface ComposeViewController : UIViewController
{
    IBOutlet UILabel *lbTeacherReceiverList;
    
    IBOutlet UILabel *lbTo;
    IBOutlet UIButton *btnAdd;
    IBOutlet UITextView *txtContent;
    IBOutlet UITextField *txtSubject;
    IBOutlet UIButton *btnImportanceFlag;
    
    IBOutlet UILabel *lbSMS;
    IBOutlet UIButton *btnCheck;
    
    
    IBOutlet UIView *viewSampleMessage;
    
    IBOutlet UITableView *tableViewSampleMessage;
    IBOutlet UIButton *btnSampleMessage;
}

@property (nonatomic, strong) NSMutableArray *receiverArray;    //must be NSMutableArray because this array maybe changed
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) MessageObject *messageObject;

@property (nonatomic, assign) BOOL isTeacherForm;

@property (nonatomic, assign) MESSAGE_COMPOSE_TYPE composeType;

@end
