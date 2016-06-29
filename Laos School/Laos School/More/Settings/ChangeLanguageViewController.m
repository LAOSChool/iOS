//
//  ChangeLanguageViewController.m
//  LazzyBee
//
//  Created by HuKhong on 3/3/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "ChangeLanguageViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LoginViewController.h"
#import "LocalizeHelper.h"
#import "CommonDefine.h"
#import "AppDelegate.h"

@interface ChangeLanguageViewController ()
{
    NSString *selectedLang;
}
@end

@implementation ChangeLanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Change language")];
    
    [self.navigationController setNavigationColor];
    
    UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(closeButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnClose];
    
    UIBarButtonItem *btnApply = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Apply") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(btnApplyClick)];
    
    self.navigationItem.rightBarButtonItem = btnApply;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    selectedLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
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

- (void)btnApplyClick {
    NSString *content = LocalizedString(@"App will be reloaded after changing language. Are you sure?");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Confirmation") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
    alert.tag = 1;
    
    [alert show];
}

#pragma table delegate
//Data Source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    
    return LanguageMax;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *changeLanguageCellId = @"ChangeLanguageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:changeLanguageCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:changeLanguageCellId];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    switch (indexPath.row) {
        case LanguageEnglish:
            cell.textLabel.text = LocalizedString(@"English");

            if (selectedLang && [selectedLang isEqualToString:LANGUAGE_ENGLISH]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        case LanguageLaos:
            cell.textLabel.text = LocalizedString(@"ພາສາລາວ");

            if (selectedLang && [selectedLang isEqualToString:LANGUAGE_LAOS]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    switch (indexPath.row) {
        case LanguageEnglish:
            selectedLang = LANGUAGE_ENGLISH;
            
            break;
            
        case LanguageLaos:
            selectedLang = LANGUAGE_LAOS;
            break;
            
        default:
            break;
    }
    NSString *oldLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
    if ([selectedLang isEqualToString:oldLang]) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [tableView reloadData];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 1) {    //confirm changing language
        if (buttonIndex != 0) {
            LocalizationSetLanguage(selectedLang);
            [[NSUserDefaults standardUserDefaults] setObject:selectedLang forKey:@"CurrentLanguageInApp"];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            LoginViewController *loginView = nil;
            
            if (IS_IPAD) {
                loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController_iPad" bundle:nil];
            } else {
                loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            }
            
            appDelegate.window.rootViewController = loginView;
        }
    }
}
@end
