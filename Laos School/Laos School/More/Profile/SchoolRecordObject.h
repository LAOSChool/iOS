//
//  SchoolRecordObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_SchoolRecordObject_h
#define LazzyBee_SchoolRecordObject_h

#import <UIKit/UIKit.h>
#import "ScoreObject.h"

//#define QUEUE_UNKNOWN 0

@interface SchoolRecordObject : NSObject
{
    
}
/*
 diem trung binh term 1, term 2, year
 Xep hang, Xep loai.
 Bam info se hien thi trung binh tháng, trung binh 4 thang, trung binh exam, trung binh hoc ky
 */
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *averageTermOne;
@property (nonatomic, strong) NSString *averageTermSecond;
@property (nonatomic, strong) NSString *overallYear;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, assign) NSInteger rank;
@property (nonatomic, strong) NSString *grade;

@property (nonatomic, strong) NSMutableArray *averageMonthArr;
@property (nonatomic, strong) NSString *average4Months;
@property (nonatomic, strong) NSString *averageExams;




@end

#endif
