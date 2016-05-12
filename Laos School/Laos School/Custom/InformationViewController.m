//
//  InformationViewController.m
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "InformationViewController.h"

#import "TagManagerHelper.h"
#import "LocalizeHelper.h"

@interface InformationViewController ()
{

}
@end

@implementation InformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TagManagerHelper pushOpenScreenEvent:@"iAttendanceInfomation"];
    // Do any additional setup after loading the view from its nib.


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
- (IBAction)tapGestureHandle:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)cancelBtnClick:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (void)loadInformation {
    lbDate.text = _attObj.dateTime;
    
    if ([_attObj.detailSession count] > 0) {
        NSString *session = _attObj.session;
        NSString *subject = _attObj.subject;
        
        if (session && session.length > 0) {
            if (subject && subject.length > 0) {
                session = [NSString stringWithFormat:@"%@ - %@", session, subject];
            }
        } else {
            if (subject && subject.length > 0) {
                session = subject;
            }
        }
        
        lbSession.text = session;
        
    } else {
        lbSession.text = LocalizedString(@"Full day");
    }
    
    if (_attObj.hasRequest) {
        txtContent.text = _attObj.reason;
        txtContent.textColor = [UIColor blackColor];
    } else {
        txtContent.text = LocalizedString(@"No reason");
        txtContent.textColor = [UIColor redColor];
    }
}
@end
