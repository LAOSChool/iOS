//
//  SubjectObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubjectObject.h"

/*

 */
@implementation SubjectObject

- (id)init {
    self = [super init];
    if (self) {
        self.subjectID = @"";
        self.subjectName = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.subjectID forKey:@"subjectID"];
    [encoder encodeObject:self.subjectName forKey:@"username"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.subjectID = [decoder decodeObjectForKey:@"subjectID"];
        self.subjectName = [decoder decodeObjectForKey:@"subjectName"];
    }
    
    return self;
}
@end