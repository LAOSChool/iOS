//
//  ComposeViewController.m
//  Laos School
//
//  Created by HuKhong on 2/29/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "ComposeViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "StudentsListViewController.h"

#import "LocalizeHelper.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"New Message")];
    
    [self.navigationController setNavigationColor];
    
    UIBarButtonItem *btnSend = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(sendNewMessage)];
    
    self.navigationItem.rightBarButtonItems = @[btnSend];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SentNewMessage" object:nil];
}

#pragma mark teacher view
- (IBAction)btnAddClick:(id)sender {
    StudentsListViewController *studentsList = [[StudentsListViewController alloc] initWithNibName:@"StudentsListViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:studentsList];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnPriorityFlagClick:(id)sender {
}
@end
