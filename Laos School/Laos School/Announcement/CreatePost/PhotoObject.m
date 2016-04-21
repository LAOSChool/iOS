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
        self.photoID = 0;
        self.order = 0;
        self.image = nil;
        self.caption = @"";
        self.filePath = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:self.photoID forKey:@"photoID"];
    [encoder encodeInteger:self.order forKey:@"order"];
    [encoder encodeObject:self.caption forKey:@"caption"];
    [encoder encodeObject:self.filePath forKey:@"filePath"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.photoID = [decoder decodeIntegerForKey:@"photoID"];
        self.order = [decoder decodeIntegerForKey:@"order"];
        self.caption = [decoder decodeObjectForKey:@"caption"];
        self.filePath = [decoder decodeObjectForKey:@"filePath"];
    }
    
    return self;
}

@end