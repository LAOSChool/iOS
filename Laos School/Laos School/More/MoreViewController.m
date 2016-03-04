//
//  MoreViewController.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "MoreViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "Common.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationColor];
    [self setTitle:LocalizedString(@"More")];
    
    //make avatar round
    imgAvatar.layer.cornerRadius = imgAvatar.frame.size.width/2;
    imgAvatar.clipsToBounds = YES;
    
    imgAvatar.image = [[Common sharedCommon] imageFromText:@"HN"];
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

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return MoreGroupMax;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    if (section == MoreGroupProfile) {
        return ProfileSectionMax;
        
    } else if (section == MoreGroupSchool) {
        return SchoolSectionMax;
        
    }else if (section == MoreGroupSettings) {
        return SettingsSectionMax;
        
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *moreCellIdentifier = @"MoreCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:moreCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.section) {
        case MoreGroupProfile:
        {
            switch (indexPath.row) {
                case ProfileSectionProfile:
                {
                    cell.textLabel.text = LocalizedString(@"Profile");
                    cell.imageView.image = [UIImage imageNamed:@"ic_user_gray.png"];
                }
                    break;
                   
                case ProfileSectionScore:
                {
                    cell.textLabel.text = LocalizedString(@"Score table");
                    cell.imageView.image = [UIImage imageNamed:@"ic_user_gray.png"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case MoreGroupSchool:
        {
            switch (indexPath.row) {
                case SchoolSectionInfo:
                {
                    cell.textLabel.text = LocalizedString(@"School information");
                    cell.imageView.image = [UIImage imageNamed:@"ic_user_gray.png"];
                }
                    break;
                    
                case SchoolSectionTeacherList:
                {
                    cell.textLabel.text = LocalizedString(@"Teacher list");
                    cell.imageView.image = [UIImage imageNamed:@"ic_user_gray.png"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case MoreGroupSettings:
        {
            switch (indexPath.row) {
                case SettingsSectionSettings:
                {
                    cell.textLabel.text = LocalizedString(@"Settings");
                    cell.imageView.image = [UIImage imageNamed:@"ic_setting.png"];
                }
                    break;
                    
                case SettingsSectionLogout:
                {
                    cell.textLabel.text = LocalizedString(@"Logout");
                    cell.imageView.image = [UIImage imageNamed:@"ic_user_gray.png"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}
@end
