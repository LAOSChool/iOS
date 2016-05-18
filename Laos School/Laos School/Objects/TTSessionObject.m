//
//  TTSessionObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTSessionObject.h"

/*
 @property (nonatomic, strong) NSString *subject;
 @property (nonatomic, strong) NSString *session;
 @property (nonatomic, strong) NSString *fromHour;
 @property (nonatomic, strong) NSString *toHour;
 @property (nonatomic, strong) NSString *teacherName;
 */

@implementation TTSessionObject

- (id)init {
    self = [super init];
    if (self) {
        self.subject = @"";
        self.session = @"";
        self.fromHour = @"";
        self.toHour = @"";
        self.teacherName = @"";

    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
//    [encoder encodeObject:self.wordid forKey:@"wordid"];
//    [encoder encodeObject:self.gid forKey:@"gid"];
//    [encoder encodeObject:self.question forKey:@"question"];

}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
//        self.wordid = [decoder decodeObjectForKey:@"wordid"];
//        self.gid = [decoder decodeObjectForKey:@"gid"];
//        self.question = [decoder decodeObjectForKey:@"question"];

    }
    
    return self;
}
@end