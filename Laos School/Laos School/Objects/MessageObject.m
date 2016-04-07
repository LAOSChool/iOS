//
//  MessageObject.m
//  LaosSchool
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageObject.h"

/*
 @property (nonatomic, strong) NSString *messsageID;
 @property (nonatomic, strong) NSString *subject;
 @property (nonatomic, strong) NSString *content;
 @property (nonatomic, strong) NSString *fromID;
 @property (nonatomic, strong) NSString *fromUsername;
 @property (nonatomic, strong) NSString *toID;
 @property (nonatomic, strong) NSString *toUsername;
 @property (nonatomic, assign) BOOL unreadFlag;
 @property (nonatomic, assign) MESSAGE_TYPE *messageType;
 @property (nonatomic, assign) IMPORTANCE_TYPE importanceType;
 @property (nonatomic, strong) NSString *messageTypeIcon;
 @property (nonatomic, strong) NSString *dateTime;
 */
@implementation MessageObject

- (id)init {
    self = [super init];
    if (self) {
        self.messsageID = @"";
        self.subject = @"";
        self.content = @"";
        self.fromID = @"";
        self.fromUsername = @"";
        self.toID = @"";
        self.toUsername = @"";
        self.unreadFlag = YES;
        self.messageType = MessageAnnouncement;
        self.importanceType = ImportanceNormal;
        self.messageTypeIcon = @"";
        self.dateTime = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:self.messsageID forKey:@"messsageID"];
    [encoder encodeObject:self.subject forKey:@"subject"];
    [encoder encodeObject:self.content forKey:@"content"];
    [encoder encodeObject:self.fromID forKey:@"fromID"];
    [encoder encodeObject:self.fromUsername forKey:@"fromUsername"];
    [encoder encodeObject:self.toID forKey:@"toID"];
    [encoder encodeObject:self.toUsername forKey:@"toUsername"];
    [encoder encodeBool:self.unreadFlag forKey:@"unreadFlag"];
    [encoder encodeInteger:self.messageType forKey:@"messageType"];
    [encoder encodeInteger:self.importanceType forKey:@"importanceType"];
    [encoder encodeObject:self.messageTypeIcon forKey:@"messageTypeIcon"];
    [encoder encodeObject:self.dateTime forKey:@"dateTime"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.messsageID = [decoder decodeObjectForKey:@"messsageID"];
        self.subject = [decoder decodeObjectForKey:@"subject"];
        self.content = [decoder decodeObjectForKey:@"content"];
        self.fromID = [decoder decodeObjectForKey:@"fromID"];
        self.fromUsername = [decoder decodeObjectForKey:@"fromUsername"];
        self.toID = [decoder decodeObjectForKey:@"toID"];
        self.toUsername = [decoder decodeObjectForKey:@"toUsername"];
        self.unreadFlag = [decoder decodeBoolForKey:@"unreadFlag"];
        self.messageType = (MESSAGE_TYPE)[decoder decodeIntegerForKey:@"messageType"];
        self.importanceType = (IMPORTANCE_TYPE)[decoder decodeIntegerForKey:@"importanceType"];
        self.messageTypeIcon = [decoder decodeObjectForKey:@"messageTypeIcon"];
        self.dateTime = [decoder decodeObjectForKey:@"dateTime"];
    }
    
    return self;
}
@end