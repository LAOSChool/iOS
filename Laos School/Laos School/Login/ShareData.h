//
//  ShareData.h
//  LazzyBee
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LazzyBee_ShareData_h
#define LazzyBee_ShareData_h
#import <Foundation/Foundation.h>
#import "UserObject.h"
#import "ClassObject.h"

@interface ShareData : NSObject

@property (nonatomic, strong) UserObject *userObj;
// a singleton:
+ (ShareData*) sharedShareData;

@end

#endif
