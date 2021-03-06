//
//  AddCommentView.h
//  LazzyBee
//
//  Created by HuKhong on 10/15/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserScore.h"
#import "AsyncImageView.h"

@protocol AddCommentDelegate <NSObject>

@optional // Delegate protocols

- (void)btnCloseClick;
- (void)btnSaveClick;

@end

@interface AddCommentView : UIView
{
    IBOutlet UIView *viewHeader;
    IBOutlet UILabel *lbTitle;

    IBOutlet UITextView *txtComment;
    IBOutlet AsyncImageView *imgAvatar;
    IBOutlet UILabel *lbStudentName;
    IBOutlet UILabel *lbAdditionalInfo;
    
    IBOutlet UIButton *btnSave;
    
    
}
@property (strong, nonatomic) IBOutlet UIView *view;

@property (strong, nonatomic) UserScore *userScore;
@property (strong, nonatomic) NSString *scoreKey;

@property(nonatomic, readwrite) id <AddCommentDelegate> delegate;

@property (nonatomic, assign) BOOL isShowing;

@end
