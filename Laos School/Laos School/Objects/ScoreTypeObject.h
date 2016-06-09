//
//  ScoreTypeObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_ScoreTypeObject_h
#define LazzyBee_ScoreTypeObject_h

#import <UIKit/UIKit.h>

/*
 A 1  Normal
 2 Thi Hoc Ky
 3  Trung Binh 4 thang
 4  Trung Binh Hoc ky
 5 Trung Binh Ca Nam
 6 Thi Lai Ca Nam
 7 Thi Tot Nghiep Cap
 */
typedef enum {
    ScoreType_Normal = 0,   //"exam_type" = 1;
    ScoreType_Average,  //"exam_type" = 3;
    ScoreType_Exam,     //"exam_type" = 2;
    ScoreType_Final,    //"exam_type" = 4;
    ScoreType_YearFinal,
    ScoreType_ExamAgain,
    ScoreType_Graduate,
    ScoreType_Max,
} SCORE_TYPE;

@interface ScoreTypeObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *typeID;
@property (nonatomic, strong) NSString *scoreName;
@property (nonatomic, assign) SCORE_TYPE scoreType;
@property (nonatomic, strong) NSString *scoreMonth;


@end

#endif
