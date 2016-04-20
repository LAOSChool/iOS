//
//  CoreDataUtil.m
//  LaosSchool
//
//  Created by Nguyen Nam on 12/9/14.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataUtil.h"
#import "Messages+CoreDataProperties.h"

#define PAGING_REQUEST 30

@implementation CoreDataUtil

-(id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(dispatch_queue_t)getDispatch {
    static dispatch_queue_t coreDataQueue;
    
    if(coreDataQueue == nil)
    {
        coreDataQueue = dispatch_queue_create("com.itpro.coredataqueue", NULL);
    }
    return coreDataQueue;
}

+(CoreDataUtil *)sharedCoreDataUtil {
    static CoreDataUtil *sharedCoreDataUtil = nil;
    if (!sharedCoreDataUtil) {
        sharedCoreDataUtil = [[super allocWithZone:nil] init];
    }
    return sharedCoreDataUtil;
}

+(id)allocWithZone:(NSZone *)zone {
    return [self sharedCoreDataUtil];
}

-(BOOL)commitInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    NSError *error;

    if (![managedObjectContext save:&error]) {
        NSLog(@"*** %@", [error localizedDescription]);
        return NO;
    }
    
    return YES;
}


- (void)insertNewMessage:(MessageObject *)messageObject {
    Messages *mess = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Messages"
                     inManagedObjectContext:self.defaultManagedObjectContext];
    /*
     @property (nullable, nonatomic, retain) NSString *content;
     @property (nullable, nonatomic, retain) NSString *dateTime;
     @property (nullable, nonatomic, retain) NSString *fromID;
     @property (nullable, nonatomic, retain) NSString *fromUsername;
     @property (nullable, nonatomic, retain) NSNumber *importanceType;
     @property (nullable, nonatomic, retain) NSString *messageID;
     @property (nullable, nonatomic, retain) NSNumber *messageType;
     @property (nullable, nonatomic, retain) NSString *subject;
     @property (nullable, nonatomic, retain) NSString *toID;
     @property (nullable, nonatomic, retain) NSString *toUsername;
     @property (nullable, nonatomic, retain) NSNumber *unreadFlag;
     */
    [mess setMessageID:[NSNumber numberWithInteger:messageObject.messageID]];
    [mess setSubject:messageObject.subject];
    [mess setContent:messageObject.content];
    [mess setDateTime:messageObject.dateTime];
    [mess setFromID:messageObject.fromID];
    [mess setFromUsername:messageObject.fromUsername];
    [mess setImportanceType:[NSNumber numberWithInteger:messageObject.importanceType]];
    [mess setMessageType:[NSNumber numberWithInteger:messageObject.messageType]];
    [mess setMessageTypeIcon:messageObject.messageTypeIcon];
    [mess setToID:messageObject.toID];
    [mess setToUsername:messageObject.toUsername];
    [mess setUnreadFlag:[NSNumber numberWithBool:messageObject.unreadFlag]];
    
    [self commitInManagedObjectContext:self.defaultManagedObjectContext];
}

- (void)insertMessagesArray:(NSArray *)messageArr {
    for (MessageObject *messageObj in messageArr) {
        [self insertNewMessage:messageObj];
    }
}

- (NSArray *)fetchMessagesWithPredicate:(NSPredicate *)predicate {
    NSArray *results = nil;
    if (self.defaultManagedObjectContext) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Messages" inManagedObjectContext:self.defaultManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        fetchRequest.fetchLimit = PAGING_REQUEST;
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageID" ascending:NO];
        fetchRequest.sortDescriptors = @[ sortDescriptor ];
        
        if (predicate != nil) {  // Suspect the check is not required
            [fetchRequest setPredicate:predicate];
        }
        NSError *error;
        results = [self.defaultManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    }
    return results;
}

- (NSArray *)loadAllMessagesFromID:(NSInteger)messageID toUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (messageID == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@)", userID];
        
    } else {
    
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (messageID < %d)", userID, messageID];
        
        
    }
    results = [self fetchMessagesWithPredicate:predicate];
    results = [self transferFromMessageToMessageObject:results];
    
    return results;
}

- (NSArray *)loadUnreadMessagesFromID:(NSInteger)messageID toUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (messageID == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (unreadFlag == 1)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (messageID < %d) AND (unreadFlag == 1)", userID, messageID];
        
    }
    
    results = [self fetchMessagesWithPredicate:predicate];
    results = [self transferFromMessageToMessageObject:results];
    
    return results;
}

- (NSArray *)loadSentMessagesFromID:(NSInteger)messageID fromUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (messageID == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(fromID == %@)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(fromID == %@) AND (messageID < %d)", userID, messageID];
        
    }
    
    results = [self fetchMessagesWithPredicate:predicate];
    results = [self transferFromMessageToMessageObject:results];
    return results;
}

- (NSArray *)transferFromMessageToMessageObject:(NSArray *)messages {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if ([messages count] > 0) {
        /*@property (nullable, nonatomic, retain) NSString *content;
         @property (nullable, nonatomic, retain) NSString *dateTime;
         @property (nullable, nonatomic, retain) NSString *fromID;
         @property (nullable, nonatomic, retain) NSString *fromUsername;
         @property (nullable, nonatomic, retain) NSNumber *importanceType;
         @property (nullable, nonatomic, retain) NSNumber *messageID;
         @property (nullable, nonatomic, retain) NSNumber *messageType;
         @property (nullable, nonatomic, retain) NSString *subject;
         @property (nullable, nonatomic, retain) NSString *toID;
         @property (nullable, nonatomic, retain) NSString *toUsername;
         @property (nullable, nonatomic, retain) NSNumber *unreadFlag;
         @property (nullable, nonatomic, retain) NSString *messageTypeIcon;
         */
        for (Messages *mess in messages) {
            MessageObject *messageObj = [[MessageObject alloc] init];
            
            messageObj.messageID = [mess.messageID integerValue];
            messageObj.content = mess.content;
            messageObj.dateTime = mess.dateTime;
            messageObj.fromID = mess.fromID;
            messageObj.fromUsername = mess.fromUsername;
            messageObj.importanceType = (IMPORTANCE_TYPE)[mess.importanceType integerValue];
            messageObj.messageType = (MESSAGE_TYPE)[mess.messageType integerValue];
            messageObj.subject = mess.subject;
            messageObj.toID = mess.toID;
            messageObj.toUsername = mess.toUsername;
            messageObj.unreadFlag = [mess.unreadFlag boolValue];
            
            [results addObject:messageObj];
        }
    }
    
    return results;
}

#pragma mark announcement
- (void)insertNewAnnouncement:(AnnouncementObject *)announcementObject {
    
}

- (void)insertAnnouncementsArray:(NSArray *)announcementArr {
    
}

- (NSArray *)loadAllAnnouncementsFromID:(NSInteger)announcementID toUserID:(NSString *)userID {
    return nil;
}

- (NSArray *)loadUnreadAnnouncementsFromID:(NSInteger)announcementID toUserID:(NSString *)userID {
    return nil;
}

- (NSArray *)loadSentAnnouncementsFromID:(NSInteger)announcementID fromUserID:(NSString *)userID {
    return nil;
}
@end