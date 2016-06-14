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
#import "ScoreTypeObject.h"

//#define QUEUE_UNKNOWN 0

@interface ScoreObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *scoreID;
@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *subjectID;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) NSString *examID;
@property (nonatomic, strong) NSString *scoreName;
@property (nonatomic, assign) SCORE_TYPE scoreType;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger weight;
@property (nonatomic, strong) NSString *teacherName;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *termID;
@property (nonatomic, strong) NSString *term;


@end

#endif
