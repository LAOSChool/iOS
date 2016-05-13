//
//  CreatePostViewController.h
//  Born2Go
//
//  Created by itpro on 5/12/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnouncementObject.h"
#import "FSImageViewerViewController.h"

@interface CreatePostViewController : UIViewController<FSImageViewerViewControllerDelegate>
{
    IBOutlet UILabel *lbDateTime;
    IBOutlet UILabel *lbTo;
    IBOutlet UILabel *lbReceiverList;
    IBOutlet UIScrollView *mainScrollView;

    IBOutlet UITextField *textViewTitle;
    IBOutlet UITextView *textViewPost;
    IBOutlet UIBarButtonItem *btnCamera;
    IBOutlet UIButton *btnImportanceFlag;
    
    IBOutlet UIToolbar *toolbar;
}

@property(nonatomic, strong) AnnouncementObject *announcementObject;
@property(nonatomic, assign) BOOL isViewDetail;

@property(strong, nonatomic) FSImageViewerViewController *imageViewController;
@end
