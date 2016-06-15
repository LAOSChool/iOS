//
//  TermObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TermObject.h"

/*

 */
@implementation TermObject

- (id)init {
    self = [super init];
    if (self) {
        self.termID = @"";
        self.termName = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.termID forKey:@"termID"];
    [encoder encodeObject:self.termName forKey:@"termName"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.termID = [decoder decodeObjectForKey:@"termID"];
        self.termName = [decoder decodeObjectForKey:@"termName"];
    }
    
    return self;
}
@end