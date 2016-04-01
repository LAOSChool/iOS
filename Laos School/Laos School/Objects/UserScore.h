//
//  UserScore.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_UserScore_h
#define LazzyBee_UserScore_h

#import <UIKit/UIKit.h>

//#define QUEUE_UNKNOWN 0

@interface UserScore : NSObject
{
    
}

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, strong) NSMutableArray *scoreArray;
@property (nonatomic, strong) NSString *averageScore;


@end

#endif
