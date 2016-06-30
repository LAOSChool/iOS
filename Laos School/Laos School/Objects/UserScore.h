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
#import "ScoreObject.h"

@interface UserScore : NSObject
{
    
}

@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *additionalInfo;
@property (nonatomic, strong) NSString *avatarLink;
@property (nonatomic, strong) NSMutableArray *scoreArray;
@property (nonatomic, strong) NSString *subjectID;
@property (nonatomic, strong) NSString *subject;


@end

#endif
