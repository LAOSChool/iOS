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

@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *averageTermOne;
@property (nonatomic, strong) NSString *averageTermSecond;
@property (nonatomic, strong) NSString *overallYear;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) NSString *additionalInfo;


@end

#endif
