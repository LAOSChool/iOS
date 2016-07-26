//
//  MainTabBarViewController.h
//  SpiceCall
//
//  Created by Nguyen Nam on 12/8/14.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MESSAGE_TAB = 0,
    ANNOUNCEMENT_TAB,
    ATTENDANCE_TAB,
    SCORE_TAB,
    MORE_TAB,
} TAB_DEFINE;

@interface MainTabBarViewController : UITabBarController <UITabBarControllerDelegate>

@property(nonatomic, strong) NSMutableArray *viewControllerItems;

- (id)initWithViewControllers:(NSArray *)viewControllers;
- (void)disableTabs;
- (void)enableTabs;

@end
