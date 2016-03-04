//
//  TagManagerHelper.h
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LaosSchool_TagManagerHelper_h
#define LaosSchool_TagManagerHelper_h
#import <Foundation/Foundation.h>
#import "TAGDataLayer.h"
#import "TAGContainer.h"
#import "TAGManager.h"

@interface TagManagerHelper : NSObject

// a singleton:
+ (TagManagerHelper*) sharedTagManagerHelper;

+ (void)pushOpenScreenEvent:(NSString *)screenName;
@end

#endif
