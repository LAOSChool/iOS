//
//  ComposeViewController.h
//  Laos School
//
//  Created by HuKhong on 2/29/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageObject.h"

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
    
}

@property (nonatomic, strong) NSMutableArray *receiverArray;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) MessageObject *messageObject;

@property (nonatomic, assign) BOOL isTeacherForm;
@end
