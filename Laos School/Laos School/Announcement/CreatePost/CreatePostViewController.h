//
//  CreatePostViewController.h
//  Born2Go
//
//  Created by itpro on 5/12/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnouncementObject.h"

@interface CreatePostViewController : UIViewController
{
    IBOutlet UIScrollView *mainScrollView;
    IBOutlet UITextView *textViewTitle;
    IBOutlet UITextView *textViewPost;
    IBOutlet UIBarButtonItem *btnCamera;
    
    IBOutlet UIToolbar *toolbar;
}

@property(nonatomic, strong) AnnouncementObject *announcementObject;
@property(nonatomic, assign) BOOL isViewDetail;
@end
