//
//  SchoolProfileViewController.m
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "SchoolProfileViewController.h"
#import "LevelPickerViewController.h"
#import "LocalizeHelper.h"
#import "UINavigationController+CustomNavigation.h"
#import "CommonDefine.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"

@interface SchoolProfileViewController ()
{
    LevelPickerViewController *termPicker;
    
    RequestToServer *requestToServer;
}
@end

@implementation SchoolProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"School records")];
    
    [self.navigationController setNavigationColor];
    
    [viewHeaderContainer setBackgroundColor:GREEN_COLOR];
    
    [btnShow setBackgroundImage:[UIImage imageNamed:@"btn_165_30.png"] forState:UIControlStateNormal];
    
    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadSchoolProfileData)];
    
    self.navigationItem.rightBarButtonItems = @[refreshButton];
    
    btnMoreInfo.enabled = NO;   //enable after got the information
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
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

- (void)reloadSchoolProfileData {
    
}

- (IBAction)showTermsListPicker:(id)sender {
    [self showLevelPicker];
}

- (void)showLevelPicker {
    termPicker = [[LevelPickerViewController alloc] initWithNibName:@"LevelPickerViewController" bundle:nil];
    termPicker.pickerType = Picker_Terms;
    termPicker.view.alpha = 0;
    
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [termPicker.view setFrame:rect];
    
    [self.view addSubview:termPicker.view];
    
    [UIView animateWithDuration:0.3 animations:^(void) {
        termPicker.view.alpha = 1;
    }];
}

- (IBAction)btnShowClick:(id)sender {
}


- (IBAction)btnMoreClick:(id)sender {
}

- (void)loadData {
    
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *studentSessionTableCellIdentifier = @"StdSessionTableViewCell";
//    
//    StdSessionTableViewCell *cell = [timeTableView dequeueReusableCellWithIdentifier:studentSessionTableCellIdentifier];
//    if (cell == nil) {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StdSessionTableViewCell" owner:nil options:nil];
//        cell = [nib objectAtIndex:0];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    return nil;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
