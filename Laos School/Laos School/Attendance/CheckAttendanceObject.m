//
//  CheckAttendanceObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckAttendanceObject.h"

/*

 */
@implementation CheckAttendanceObject

- (id)init {
    self = [super init];
    if (self) {

    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
//    [encoder encodeObject:self.wordid forKey:@"wordid"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
//        self.wordid = [decoder decodeObjectForKey:@"wordid"];

    }
    
    return self;
}
@end