//
//  CreatePermissionViewController.m
//  Laos School
//
//  Created by HuKhong on 3/3/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "CreatePermissionViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"

@interface CreatePermissionViewController ()

@end

@implementation CreatePermissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Create permission")];
    
    [self.navigationController setNavigationColor];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(sendNewMessage)];
    
    self.navigationItem.rightBarButtonItems = @[btnSend];
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
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}
@end
