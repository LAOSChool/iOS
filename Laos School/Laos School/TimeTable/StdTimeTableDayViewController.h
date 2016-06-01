//
//  StdTimeTableDayViewController.h
//  Laos School
//
//  Created by HuKhong on 5/18/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSessionObject.h"

@protocol TimeTableDayViewDelegate <NSObject>

@optional // Delegate protocols

- (void)btnDoneClick:(id)sender withObjectReturned:(TTSessionObject *)returnedObj;

@end

typedef enum {
    TimeTableFull = 0,
    TimeTableOneDay,
    TimeTableMax
} TIME_TABLE_TYPE;

@interface StdTimeTableDayViewController : UIViewController
{
    IBOutlet UITableView *timeTableView;
    
}

@property(nonatomic, readwrite) id <TimeTableDayViewDelegate> delegate;

@property (nonatomic, strong) NSArray *sessionsArray;
@property (nonatomic, strong) TTSessionObject *selectedSession;

@property (nonatomic, assign) TIME_TABLE_TYPE timeTableType;
@end
