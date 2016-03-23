//
//  StudentsListViewController.h
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StudentsListViewController : UIViewController
{
    IBOutlet UITableView *studentsTableView;
    
}

@property (nonatomic, strong) NSMutableArray *studentsArray;
@end
