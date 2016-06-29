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

@property (nonatomic, strong) NSString *score;
@property (nonatomic, strong) NSString *dateTime;
@property (nonatomic, strong) ScoreTypeObject *scoreTypeObj;
@property (nonatomic, strong) NSString *comment;

@end

#endif
