//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//


// Import all the things
#import "JSQMessages.h"

#import "ConversationModelData.h"


@class MessagesConversationViewController;

@protocol JSQViewControllerDelegate <NSObject>

- (void)didDismissJSQViewController:(MessagesConversationViewController *)vc;

@end




@interface MessagesConversationViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (weak, nonatomic) id<JSQViewControllerDelegate> delegateModal;

@property (strong, nonatomic) ConversationModelData *demoData;

- (void)closePressed:(UIBarButtonItem *)sender;

@end
