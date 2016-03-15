//
//  StudentsListViewController.m
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StudentsListViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "StudentsListTableViewCell.h"

@interface StudentsListViewController ()
{
    UIBarButtonItem *btnCheck;
}
@end

@implementation StudentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Students list")];
    
    [self.navigationController setNavigationColor];
    
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(doneButtonClick)];
    
    btnCheck = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_checkall"] style:UIBarButtonItemStylePlain target:self action:@selector(checkButtonClick)];
    
    self.navigationItem.rightBarButtonItems = @[btnCheck, btnDone];
    
    UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(closeButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnClose];
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


- (void)closeButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)doneButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SentNewMessage" object:nil];
}

- (void)checkButtonClick {
    
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *studentsListCellIdentifier = @"StudentsListCellIdentifier";
    
    StudentsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:studentsListCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StudentsListTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}
@end
