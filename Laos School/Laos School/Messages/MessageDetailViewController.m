//
//  MessageDetailViewController.m
//  Laos School
//
//  Created by HuKhong on 3/1/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "UINavigationController+CustomNavigation.h"

@interface MessageDetailViewController ()

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
    lbFromUsername.text = _messageObject.fromUsername;
    lbDateTime.text = _messageObject.dateTime;
    lbSubject.text = _messageObject.subject;
    txtContent.text = _messageObject.content;
    
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
        
    } else {
        _messageObject.importanceType = ImportanceNormal;
    }
    
    if (_messageObject.importanceType == ImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
}


@end
