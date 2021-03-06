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
        self.weekDay = @"";
        self.weekDayID = @"";
        self.subject = @"";
        self.subject_lao = @"";
        self.subjectID = @"";
        self.session = @"";
        self.sessionID = @"";
        self.order = 1;
        self.additionalInfo = @"";
        self.duration = @"";
        self.teacherName = @"";
        self.sessionType = SessionType_Morning;

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