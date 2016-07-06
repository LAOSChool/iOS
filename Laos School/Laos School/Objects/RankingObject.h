//
//  RankingObject.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_RankingObject_h
#define LazzyBee_RankingObject_h

#import <UIKit/UIKit.h>
#import "ScoreTypeObject.h"

//#define QUEUE_UNKNOWN 0

@interface RankingObject : NSObject
{
    
}

@property (nonatomic, strong) NSString *averageScore;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic, strong) NSString *ranking;
@property (nonatomic, strong) ScoreTypeObject *scoreTypeObj;


@end

#endif
