//
//  StdTimeTableDayViewController.m
//  Laos School
//
//  Created by HuKhong on 5/18/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "StdTimeTableDayViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "StdSessionTableViewCell.h"
#import "LocalizeHelper.h"
#import "CommonDefine.h"

@interface StdTimeTableDayViewController ()
{
    NSMutableDictionary *sessionGroupByType;
    NSArray *allKeys;
}
@end

@implementation StdTimeTableDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (sessionGroupByType ==  nil) {
        sessionGroupByType = [[NSMutableDictionary alloc] init];
    }
    
    if (_timeTableType == TimeTableOneDay) {
        [self.navigationController setNavigationColor];
        
        UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
        
        self.navigationItem.leftBarButtonItems = @[btnCancel];
        
        UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Done") style:UIBarButtonItemStyleDone target:self action:@selector(btnDoneClick)];
        
        self.navigationItem.rightBarButtonItems = @[btnDone];
        
        [timeTableView setAllowsSelection:YES];
        
    } else {
        [timeTableView setAllowsSelection:NO];
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

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnDoneClick {
    [self.delegate btnDoneClick:self withObjectReturned:_selectedSession];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSArray *)sortSessionByOrder:(NSArray *)arr {
    NSSortDescriptor *order = [NSSortDescriptor sortDescriptorWithKey:@"order" ascending:YES];

    NSArray *resultArr = [arr sortedArrayUsingDescriptors:[NSArray arrayWithObjects:order, nil]];
    
    return resultArr;
}

- (void)setSessionsArray:(NSArray *)sessionsArray {
    _sessionsArray = [self sortSessionByOrder:sessionsArray];

    if (sessionGroupByType ==  nil) {
        sessionGroupByType = [[NSMutableDictionary alloc] init];
    }
    
    for (TTSessionObject *sessionObj in _sessionsArray) {
        NSString *sessionType = [NSString stringWithFormat:@"%d", sessionObj.sessionType];
        
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[sessionGroupByType objectForKey:sessionType]];
        
        [arr addObject:sessionObj];
        [sessionGroupByType setObject:arr forKey:sessionType];
    }
    
    allKeys = [self sortKey:[sessionGroupByType allKeys]];
    
    if ([allKeys count] > 0) {
        [timeTableView reloadData];
    }
    
}

- (NSArray *)sortKey:(NSArray *)arr {
    
    if ([arr count] > 1) {
        NSMutableArray *sortArr = [[NSMutableArray alloc] initWithArray:arr];
        [sortArr sortUsingComparator:^(NSString *a, NSString *b){
            return [a compare:b];
        }];
        
        return sortArr;
    }
    return arr;
}

#pragma mark data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [allKeys count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerTitle = @"";

    if (section < [allKeys count]) {
        NSString *key = [allKeys objectAtIndex:section];
        
        if ([key isEqualToString:[NSString stringWithFormat:@"%d", SessionType_Morning]]) {
            headerTitle = LocalizedString(@"Morning");
            
        } else if ([key isEqualToString:[NSString stringWithFormat:@"%d", SessionType_Afternoon]]) {
            headerTitle = LocalizedString(@"Afternoon");
            
        } else if ([key isEqualToString:[NSString stringWithFormat:@"%d", SessionType_Evening]]) {
            headerTitle = LocalizedString(@"Evening");
        }
    }
    
    return headerTitle;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
        UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
        
        header.textLabel.textColor = [UIColor whiteColor];
        header.textLabel.font = [UIFont boldSystemFontOfSize:15];
        CGRect headerFrame = header.frame;
        header.textLabel.frame = headerFrame;
        header.textLabel.textAlignment = NSTextAlignmentLeft;
        
        header.backgroundView.backgroundColor = [UIColor lightGrayColor];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    // If you're serving data from an array, return the length of the array:
    
    if ([allKeys count] > 0) {
        NSString *key = [allKeys objectAtIndex:section];
        NSArray *arr = [sessionGroupByType objectForKey:key];
        return [arr count];
        
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *studentSessionTableCellIdentifier = @"StdSessionTableViewCell";
    
    StdSessionTableViewCell *cell = [timeTableView dequeueReusableCellWithIdentifier:studentSessionTableCellIdentifier];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"StdSessionTableViewCell" owner:nil options:nil];
        cell = [nib objectAtIndex:0];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    NSString *key = [allKeys objectAtIndex:indexPath.section];
    NSArray *arr = [sessionGroupByType objectForKey:key];
    TTSessionObject *sessionObj = [arr objectAtIndex:indexPath.row];
    
    if (_selectedSession && [_selectedSession isEqual:sessionObj]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (![sessionObj.subject isEqualToString:@""]) {
        //set color
        [cell.lbSession setTextColor:[UIColor darkGrayColor]];
        [cell.lbSubject setTextColor:BLUE_COLOR];
        [cell.lbDuration setTextColor:[UIColor darkGrayColor]];
        [cell.lbTeacherName setTextColor:[UIColor darkGrayColor]];
        [cell.lbAddionalInfo setTextColor:[UIColor darkGrayColor]];
        
        [cell.contentView setBackgroundColor:[UIColor whiteColor]];
        [cell setBackgroundColor:[UIColor whiteColor]];
        
        //fill data
        cell.lbSession.text = [NSString stringWithFormat:@"%@ %@", LocalizedString(@"Session"), sessionObj.session];
        cell.lbDuration.text = sessionObj.duration;
        cell.lbSubject.text = sessionObj.subject;
        cell.lbTeacherName.text = sessionObj.teacherName;
        cell.lbAddionalInfo.text = sessionObj.additionalInfo;
        
    } else {
        //set color
        [cell.lbSession setTextColor:[UIColor whiteColor]];
        [cell.lbSubject setTextColor:[UIColor whiteColor]];
        [cell.lbDuration setTextColor:[UIColor whiteColor]];
        [cell.lbTeacherName setTextColor:[UIColor whiteColor]];
        [cell.lbAddionalInfo setTextColor:[UIColor whiteColor]];
        
        [cell.contentView setBackgroundColor:[UIColor darkGrayColor]];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
        
        //fill data
        cell.lbSession.text = [NSString stringWithFormat:@"%@", sessionObj.session];
        cell.lbDuration.text = sessionObj.duration;
        cell.lbSubject.text = sessionObj.subject;
        cell.lbTeacherName.text = sessionObj.teacherName;
        cell.lbAddionalInfo.text = sessionObj.additionalInfo;
    }
    return cell;
}

#pragma mark table delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *key = [allKeys objectAtIndex:indexPath.section];
    NSArray *arr = [sessionGroupByType objectForKey:key];
    _selectedSession = [arr objectAtIndex:indexPath.row];
    
    [tableView reloadData];
    
}
@end
