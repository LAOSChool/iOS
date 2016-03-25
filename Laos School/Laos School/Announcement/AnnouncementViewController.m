//
//  AnnouncementViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "AnnouncementViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "CreatePostViewController.h"

#import "LocalizeHelper.h"
#import "ShareData.h"

@interface AnnouncementViewController ()

@end

@implementation AnnouncementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Announcements")];
    
    [self.navigationController setNavigationColor];
    
    if (([ShareData sharedShareData].userObj.permission & Permission_SendMessage) == Permission_SendMessage) {
        
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewAnnouncement)];
        
        self.navigationItem.rightBarButtonItems = @[addButton];
    }
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

- (void)addNewAnnouncement {
    CreatePostViewController *composeViewController = nil;
    
    composeViewController = [[CreatePostViewController alloc] initWithNibName:@"CreatePostViewController" bundle:nil];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
}

@end
