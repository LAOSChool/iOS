//
//  MessageDetailViewController.h
//  Laos School
//
//  Created by HuKhong on 3/1/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageObject.h"
#import "AsyncImageView.h"

@interface MessageDetailViewController : UIViewController
{
    IBOutlet AsyncImageView *imgAvatar;
    IBOutlet UIButton *btnImportanceFlag;
    IBOutlet UILabel *lbFromUsername;
    IBOutlet UILabel *lbDateTime;
    IBOutlet UILabel *lbSubject;
    IBOutlet UITextView *txtContent;
    
}

@property (nonatomic, strong) MessageObject *messageObject;
@property (nonatomic, assign) BOOL isIncomeMessage;
@end
