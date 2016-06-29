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

#define SCORE_KEY_SEP @"m1"
#define SCORE_KEY_OCT @"m2"
#define SCORE_KEY_NOV @"m3"
#define SCORE_KEY_DEC @"m4"
#define SCORE_KEY_AVE4M1 @"m5"
#define SCORE_KEY_TERM_EXAM1 @"m6"
#define SCORE_KEY_AVE_TERM1 @"m7"
#define SCORE_KEY_FEB @"m8"
#define SCORE_KEY_MAR @"m9"
#define SCORE_KEY_APR @"m10"
#define SCORE_KEY_MAY @"m11"
#define SCORE_KEY_AVE4M2 @"m12"
#define SCORE_KEY_TERM_EXAM2 @"m13"
#define SCORE_KEY_AVE_TERM2 @"m14"
#define SCORE_KEY_OVERALL @"m15"
#define SCORE_KEY_RETEST @"m16"
#define SCORE_KEY_GRADUATION @"m17"
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
    ScoreType_Average,  //"exam_type" = 3;  average of 4 months
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

@property (nonatomic, strong) NSString *scoreName;
@property (nonatomic, assign) SCORE_TYPE scoreType;
@property (nonatomic, strong) NSString *scoreKey;
@property (nonatomic, strong) NSString *scoreShortName;


@end

#endif
