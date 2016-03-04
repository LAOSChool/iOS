//
//  MainTabBarViewController.m
//  SpiceCall
//
//  Created by Nam Nguyen on 4/2/13.
//  Copyright (c) 2013 The Boeing Company. All rights reserved.
//

#import "MainTabBarViewController.h"

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
                [self.tabBar.items[index] setTitle:@"Messages"];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_message"]];
				break;
                
            case ANNOUNCEMENT_TAB:
                [self.tabBar.items[index] setTitle:@"Announcements"];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_announcement"]];
                break;
                
            case ATTENDANCE_TAB:
                [self.tabBar.items[index] setTitle:@"Attendance"];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_attendance"]];
                break;
                
            case TIMETABLE_TAB:
                [self.tabBar.items[index] setTitle:@"Time table"];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_timetable"]];
                break;
                
            case MORE_TAB:
                [self.tabBar.items[index] setTitle:@"More"];
                [self.tabBar.items[index] setImage: [UIImage imageNamed:@"ic_more"]];
                break;

			default:
				break;
		}
	}
	
	self.delegate = self;
    [self setSelectedIndex:MESSAGE_TAB];
    
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
