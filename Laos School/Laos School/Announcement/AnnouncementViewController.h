//
//  AnnouncementViewController.h
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnnouncementViewController : UIViewController
{
    
    IBOutlet UITableView *announcementTableView;
}

@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) UISplitViewController *splitViewController;
@end
