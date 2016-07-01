//
//  ScoresViewController.h
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ScoreTable_Normal = 0,
    ScoreTable_SchoolRecord,
    ScoreTable_Max
} SCORE_TABLE_TYPE;

@interface ScoresViewController : UIViewController
{
    
    IBOutlet UITableView *scoresTableView;
}

@property (nonatomic, assign) SCORE_TABLE_TYPE tableType;

@property (nonatomic, strong) NSMutableArray *scoresArray;

@property (nonatomic, strong) NSString *curTerm;    //use for school records
@end
