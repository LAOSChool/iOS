//
//  ClassObject.h
//  LaosSchool
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LaosSchool_ClassObject_h
#define LaosSchool_ClassObject_h

#import <UIKit/UIKit.h>

@interface ClassObject : NSObject
{
    
}


@property (nonatomic, strong) NSString *classID;
@property (nonatomic, strong) NSString *className;
@property (nonatomic, strong) NSString *teacherID;
@property (nonatomic, strong) NSString *classLocation;
@property (nonatomic, strong) NSString *currentTerm;
@property (nonatomic, strong) NSString *currentYear;
@property (nonatomic, strong) NSMutableArray *pupilArray;

@end

#endif
