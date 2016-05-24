//
//  SchoolRecordObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SchoolRecordObject.h"

/*
 @property (nonatomic, strong) NSString *wordid;

 */
@implementation SchoolRecordObject

- (id)init {
    self = [super init];
    if (self) {
//        self.wordid = @"";

    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
//    [encoder encodeObject:self.wordid forKey:@"wordid"];
//    [encoder encodeObject:self.gid forKey:@"gid"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
//        self.wordid = [decoder decodeObjectForKey:@"wordid"];
//        self.gid = [decoder decodeObjectForKey:@"gid"];

    }
    
    return self;
}
@end