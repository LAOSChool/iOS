//
//  PhotoObject.m
//  Born2Go
//
//  Created by itpro on 3/31/15.
//  Copyright (c) 2015 Born2Go. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoObject.h"

@implementation PhotoObject

- (id)init {
    self = [super init];
    if (self) {
        self.image = nil;
        self.caption = @"";
        self.filePath = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.caption forKey:@"caption"];
    [encoder encodeObject:self.filePath forKey:@"filePath"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.caption = [decoder decodeObjectForKey:@"caption"];
        self.filePath = [decoder decodeObjectForKey:@"filePath"];
    }
    
    return self;
}

@end