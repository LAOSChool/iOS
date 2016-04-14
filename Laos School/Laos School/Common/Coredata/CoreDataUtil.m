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
    [mess setMessageID:[NSNumber numberWithInteger:[messageObject.messageID integerValue]]];
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

- (NSArray *)loadAllMessagesFromID:(NSString *)messageID toUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (messageID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@)", userID];
        
    } else {
    
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (messageID < %d)", userID, [messageID integerValue]];
        
        
    }
    results = [self fetchMessagesWithPredicate:predicate];
    
    return results;
}

- (NSArray *)loadUnreadMessagesFromID:(NSString *)messageID toUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (messageID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (unreadFlag == 1)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (messageID < %d) AND (unreadFlag == 1)", userID, [messageID integerValue]];
        
    }
    
    results = [self fetchMessagesWithPredicate:predicate];
    
    return results;
}

- (NSArray *)loadSentMessagesFromID:(NSString *)messageID fromUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (messageID == nil) {
        predicate = [NSPredicate predicateWithFormat:@"(fromID == %@)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(fromID == %@) AND (messageID < %d)", userID, [messageID integerValue]];
        
    }
    
    results = [self fetchMessagesWithPredicate:predicate];
    
    return results;
}

@end