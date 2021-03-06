//
//  MessageObject.m
//  LaosSchool
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageObject.h"
#import "DateTimeHelper.h"

/*
 @property (nonatomic, assign) NSInteger messageID;
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
        self.messageID = 0;
        self.subject = @"";
        self.content = @"";
        self.fromID = @"";
        self.fromUsername = @"";
        self.toID = @"";
        self.toUsername = @"";
        self.unreadFlag = YES;
        self.messageType = MessageAnnouncement;
        self.importanceType = ImportanceNormal;
        self.messageTypeIcon = @"NX";
        self.dateTime = @"";
        self.senderAvatar = @"";
        self.receiverAvatar = @"";
    }
    return self;
}

- (id)initWithMessageDictionary:(NSDictionary *)messageDict {
    self = [super init];
    if (self) {
        if ([messageDict valueForKey:@"id"] != (id)[NSNull null]) {
            self.messageID = [[messageDict valueForKey:@"id"] integerValue];
        }
        
        if ([messageDict valueForKey:@"title"] != (id)[NSNull null]) {
            self.subject = [messageDict valueForKey:@"title"];
        }
        
        if ([messageDict valueForKey:@"content"] != (id)[NSNull null]) {
            self.content = [messageDict valueForKey:@"content"];
        }
        
        if ([messageDict valueForKey:@"from_user_id"] != (id)[NSNull null]) {
            self.fromID = [NSString stringWithFormat:@"%@", [messageDict valueForKey:@"from_user_id"]];
        }
        
        if ([messageDict valueForKey:@"from_user_name"] != (id)[NSNull null]) {
            self.fromUsername = [messageDict valueForKey:@"from_user_name"];
        }
        
        if ([messageDict valueForKey:@"to_user_id"] != (id)[NSNull null]) {
            self.toID = [NSString stringWithFormat:@"%@", [messageDict valueForKey:@"to_user_id"]];
        }
        
        if ([messageDict valueForKey:@"to_user_name"] != (id)[NSNull null]) {
            self.toUsername = [messageDict valueForKey:@"to_user_name"];
        }
        
        if ([messageDict valueForKey:@"is_read"] != (id)[NSNull null]) {
            self.unreadFlag = [[messageDict valueForKey:@"is_read"] boolValue];
        }
        
        if ([messageDict valueForKey:@"imp_flg"] != (id)[NSNull null]) {
            if ([[messageDict valueForKey:@"imp_flg"] boolValue] == YES) {
                self.importanceType = ImportanceHigh;
                
            } else {
                self.importanceType = ImportanceNormal;
            }
        }
        
        self.messageType = MessageComment;
        
        if ([messageDict valueForKey:@"messageType"] != (id)[NSNull null]) {
            self.messageTypeIcon = [messageDict valueForKey:@"messageType"];
        }
        
        if ([messageDict valueForKey:@"sent_dt"] != (id)[NSNull null]) {
            self.dateTime = [messageDict valueForKey:@"sent_dt"];
        }
        
        if ([messageDict valueForKey:@"frm_user_photo"] != (id)[NSNull null]) {
            self.senderAvatar = [messageDict valueForKey:@"frm_user_photo"];
        }
        
        if ([messageDict valueForKey:@"to_user_photo"] != (id)[NSNull null]) {
            self.receiverAvatar = [messageDict valueForKey:@"to_user_photo"];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeInteger:self.messageID forKey:@"messageID"];
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
    [encoder encodeObject:self.senderAvatar forKey:@"senderAvatar"];
    [encoder encodeObject:self.receiverAvatar forKey:@"receiverAvatar"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
        self.messageID = [decoder decodeIntegerForKey:@"messageID"];
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
        self.senderAvatar = [decoder decodeObjectForKey:@"senderAvatar"];
        self.receiverAvatar = [decoder decodeObjectForKey:@"receiverAvatar"];
    }
    
    return self;
}

- (NSTimeInterval)sortByDateTime {
    if (_dateTime.length > 0) {
        return [[DateTimeHelper sharedDateTimeHelper] timeIntervalOfDateString:_dateTime];
    }
    
    return 0;
}

- (NSString *)senderAvatar {
    NSString *res = _senderAvatar;
    
    if (res.length > 0) {
        if ([res containsString:@"_90."] == NO) {
            NSString *tmp = [res stringByDeletingPathExtension];
            NSString *extension = [res pathExtension];
            res = [tmp stringByAppendingFormat:@"_90.%@", extension];
        }
    }
    
    return res;
}

- (NSString *)receiverAvatar {
    NSString *res = _receiverAvatar;
    
    if (res.length > 0) {
        NSString *tmp = [res stringByDeletingPathExtension];
        NSString *extension = [res pathExtension];
        res = [tmp stringByAppendingFormat:@"_90.%@", extension];
        
    }
    
    return res;
    
    return res;
}

@end