//
//  MainTabBarViewController.m
//  SpiceCall
//
//  Created by Nam Nguyen on 4/2/13.
//  Copyright (c) 2013 The Boeing Company. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "CommonDefine.h"
#import "LocalizeHelper.h"

@import FirebaseAnalytics;

@interface MainTabBarViewController ()
{
    BOOL blockAllTabs;
}
@end

@implementation MainTabBarViewController
@synthesize viewControllerItems = _viewControllerItems;

- (id)initWithViewControllers:(NSArray *)viewControllers {
	
    _viewControllerItems = [[NSMutableArray alloc] initWithArray:viewControllers];
    
    self = [super init];
			
	blockAllTabs = NO;

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self setViewControllers:_viewControllerItems];

	for (NSInteger index = 0; index < [_viewControllerItems count]; index++) {
		switch (index) {
			case MESSAGE_TAB:
                [self.tabBar.items[index] setTitle:LocalizedString(@"Messages")];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_message"]];
				break;
                
            case ANNOUNCEMENT_TAB:
                [self.tabBar.items[index] setTitle:LocalizedString(@"Announcements")];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_announcement"]];
                break;
                
            case ATTENDANCE_TAB:
                [self.tabBar.items[index] setTitle:LocalizedString(@"Attendance")];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_attendance"]];
                break;
                
            case SCORE_TAB:
                [self.tabBar.items[index] setTitle:LocalizedString(@"Scores")];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_score"]];
                break;
                
            case MORE_TAB:
                [self.tabBar.items[index] setTitle:LocalizedString(@"More")];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_more"]];
                break;

			default:
				break;
		}
	}
	
	self.delegate = self;
    [self setSelectedIndex:MESSAGE_TAB];
    [self.tabBar setTintColor:COMMON_COLOR];
    
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)changeToTabAtIndex:(NSNotification*)notification {
	NSNumber *indexNumber = notification.object;
	NSInteger index = [indexNumber integerValue];
	
	[self setSelectedIndex:index];
}

#pragma tabbar delegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
    switch (tabBarController.selectedIndex) {
        case MESSAGE_TAB:
            [FIRAnalytics setUserPropertyString:@"messsage_tab" forName:@"selected_tab"];
            
            [FIRAnalytics logEventWithName:@"selected_tab" parameters:@{
                                                                  kFIRParameterValue:@"messsage_tab"
                                                                  }];
            
            break;
            
        case ANNOUNCEMENT_TAB:
            [FIRAnalytics setUserPropertyString:@"announcement_tab" forName:@"selected_tab"];
            
            [FIRAnalytics logEventWithName:@"selected_tab" parameters:@{
                                                                        kFIRParameterValue:@"announcement_tab"
                                                                        }];
            break;
            
        case ATTENDANCE_TAB:
            [FIRAnalytics setUserPropertyString:@"attendance_tab" forName:@"selected_tab"];
            
            [FIRAnalytics logEventWithName:@"selected_tab" parameters:@{
                                                                        kFIRParameterValue:@"attendance_tab"
                                                                        }];
            break;
            
        case SCORE_TAB:
            [FIRAnalytics setUserPropertyString:@"score_tab" forName:@"selected_tab"];
            
            [FIRAnalytics logEventWithName:@"selected_tab" parameters:@{
                                                                        kFIRParameterValue:@"score_tab"
                                                                        }];
            break;
            
        case MORE_TAB:
            [FIRAnalytics setUserPropertyString:@"more_tab" forName:@"selected_tab"];
            
            [FIRAnalytics logEventWithName:@"selected_tab" parameters:@{
                                                                        kFIRParameterValue:@"more_tab"
                                                                        }];
            break;
            
        default:
            break;
    }
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {

    return viewController != tabBarController.selectedViewController;
}

- (void)disableTabs {
    blockAllTabs = YES;
}

- (void)enableTabs {
    blockAllTabs = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    return;
}
@end
