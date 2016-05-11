//
//  ScoreObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_ScoreObject_h
#define LazzyBee_ScoreObject_h

#import <UIKit/UIKit.h>

//#define QUEUE_UNKNOWN 0

typedef enum {
    ScoreType_Normal = 0,
    ScoreType_Exam,
    ScoreType_Final,
    ScoreType_Max,
} SCORE_TYPE;

@interface ScoreObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *scoreID;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, assign) SCORE_TYPE scoreType;
@property (nonatomic, strong) NSString *month;
@property (nonatomic, assign) NSInteger weight;

@end

#endif
