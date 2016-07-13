//
//  AnnouncementObject.m
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnouncementObject.h"
#import "DateTimeHelper.h"

@implementation AnnouncementObject

/*
 @property (nonatomic, strong) NSString *announcementID;
 @property (nonatomic, strong) NSString *subject;
 @property (nonatomic, strong) NSString *content;
 @property (nonatomic, strong) NSString *dateTime;
 @property (nonatomic, assign) IMPORTANCE_TYPE importanceType;
 @property (nonatomic, strong) NSMutableArray *imgArray;
 
 */

- (id)init {
    self = [super init];
    if (self) {
        self.announcementID = 0;
        self.subject = @"";
        self.content = @"";
        self.importanceType = AnnouncementImportanceNormal;
        self.dateTime = @"";
        self.imgArray = [[NSMutableArray alloc] init];
        self.senderAvatar = @"";
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
//    [encoder encodeObject:self.wordid forKey:@"wordid"];
//    [encoder encodeObject:self.gid forKey:@"gid"];
//    [encoder encodeObject:self.question forKey:@"question"];
//    [encoder encodeObject:self.answers forKey:@"answers"];
//    [encoder encodeObject:self.subcats forKey:@"subcats"];
//    [encoder encodeObject:self.status forKey:@"status"];
//    [encoder encodeObject:self.package forKey:@"package"];
//    [encoder encodeObject:self.level forKey:@"level"];
//    [encoder encodeObject:self.queue forKey:@"queue"];
//    [encoder encodeObject:self.due forKey:@"due"];
//    [encoder encodeObject:self.revCount forKey:@"revCount"];
//    [encoder encodeObject:self.lastInterval forKey:@"lastInterval"];
//    [encoder encodeObject:self.eFactor forKey:@"eFactor"];
//    [encoder encodeObject:self.langVN forKey:@"langVN"];
//    [encoder encodeObject:self.langEN forKey:@"langEN"];
//    [encoder encodeObject:self.userNote forKey:@"userNote"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) // Superclass init
    {
//        self.wordid = [decoder decodeObjectForKey:@"wordid"];
//        self.gid = [decoder decodeObjectForKey:@"gid"];
//        self.question = [decoder decodeObjectForKey:@"question"];
//        self.answers = [decoder decodeObjectForKey:@"answers"];
//        self.subcats = [decoder decodeObjectForKey:@"subcats"];
//        self.status = [decoder decodeObjectForKey:@"status"];
//        self.package = [decoder decodeObjectForKey:@"package"];
//        self.level = [decoder decodeObjectForKey:@"level"];
//        self.queue = [decoder decodeObjectForKey:@"queue"];
//        self.due = [decoder decodeObjectForKey:@"due"];
//        self.revCount = [decoder decodeObjectForKey:@"revCount"];
//        self.lastInterval = [decoder decodeObjectForKey:@"lastInterval"];
//        self.eFactor = [decoder decodeObjectForKey:@"eFactor"];
//        self.langVN = [decoder decodeObjectForKey:@"langVN"];
//        self.langEN = [decoder decodeObjectForKey:@"langEN"];
//        self.userNote = [decoder decodeObjectForKey:@"userNote"];
    }
    
    return self;
}

- (NSTimeInterval)sortByDateTime {
    if (_dateTime.length > 0) {
        return [[DateTimeHelper sharedDateTimeHelper] timeIntervalOfDateString:_dateTime];
    }
    
    return 0;
}
@end