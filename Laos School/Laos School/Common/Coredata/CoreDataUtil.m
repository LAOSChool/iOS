//
//  CoreDataUtil.m
//  LaosSchool
//
//  Created by Nguyen Nam on 12/9/14.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataUtil.h"
#import "Messages.h"
#import "Announcements.h"
#import "Photos.h"

#import "ArchiveHelper.h"

#define PAGING_REQUEST 100
#define ENTITY_MESSAGES @"Messages"
#define ENTITY_ANNOUNCEMENTS @"Announcements"

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
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"(messageID == %d)", messageObject.messageID];
    
    NSArray *results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_MESSAGES];
    
    if ([results count] == 0) {
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
        [mess setSenderAvatar:messageObject.senderAvatar];
        [mess setUnreadFlag:[NSNumber numberWithBool:messageObject.unreadFlag]];
        
        [self commitInManagedObjectContext:self.defaultManagedObjectContext];
    }
}

- (void)insertMessagesArray:(NSArray *)messageArr {
    for (MessageObject *messageObj in messageArr) {
        [self insertNewMessage:messageObj];
    }
}

- (NSArray *)fetchDataWithPredicate:(NSPredicate *)predicate fromEntity:(NSString *)entityName {
    NSArray *results = nil;
    if (self.defaultManagedObjectContext) {
        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:self.defaultManagedObjectContext];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:entityDescription];
        fetchRequest.fetchLimit = PAGING_REQUEST;
        
        NSSortDescriptor *sortDescriptor = nil;
        
        if ([entityName isEqualToString:ENTITY_MESSAGES]) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"messageID" ascending:NO];
            
        } else if ([entityName isEqualToString:ENTITY_ANNOUNCEMENTS]) {
            sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"announcementID" ascending:NO];
        }
        
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
    results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_MESSAGES];
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
    
    results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_MESSAGES];
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
    
    results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_MESSAGES];
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
            messageObj.senderAvatar = mess.senderAvatar;
            messageObj.unreadFlag = [mess.unreadFlag boolValue];
            
            [results addObject:messageObj];
        }
    }
    
    return results;
}

- (void)updateMessageRead:(NSInteger)messageID withFlag:(BOOL)flag {
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"(messageID == %d)", messageID];

    NSArray *results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_MESSAGES];
    
    if ([results count] > 0) {
        Messages *mess = [results objectAtIndex:0];
        
        [mess setUnreadFlag:[NSNumber numberWithBool:!flag]];
        
        [self.defaultManagedObjectContext save:nil];
    }
}

- (void)updateMessageImportance:(NSInteger)messageID withFlag:(BOOL)flag {
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"(messageID == %d)", messageID];
    
    NSArray *results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_MESSAGES];
    
    if ([results count] > 0) {
        Messages *mess = [results objectAtIndex:0];
        
        [mess setImportanceType:[NSNumber numberWithBool:flag]];
        
        [self.defaultManagedObjectContext save:nil];
    }
}

#pragma mark announcement
- (void)insertNewAnnouncement:(AnnouncementObject *)announcementObject {
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"(announcementID == %d)", announcementObject.announcementID];
    
    NSArray *results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_ANNOUNCEMENTS];
    
    if ([results count] == 0) {
        Announcements *announcement = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Announcements"
                          inManagedObjectContext:self.defaultManagedObjectContext];
        /*
         @property (nullable, nonatomic, retain) NSString *content;
         @property (nullable, nonatomic, retain) NSString *datetime;
         @property (nullable, nonatomic, retain) NSString *fromID;
         @property (nullable, nonatomic, retain) NSString *fromUsername;
         @property (nullable, nonatomic, retain) NSNumber *importanceType;
         @property (nullable, nonatomic, retain) NSNumber *announcementID;
         @property (nullable, nonatomic, retain) NSString *subject;
         @property (nullable, nonatomic, retain) NSString *toID;
         @property (nullable, nonatomic, retain) NSString *toUsername;
         @property (nullable, nonatomic, retain) NSNumber *unreadFlag;
         @property (nullable, nonatomic, retain) NSSet<Photos *> *announcementToPhotos;
         */
        [announcement setAnnouncementID:[NSNumber numberWithInteger:announcementObject.announcementID]];
        [announcement setSubject:announcementObject.subject];
        [announcement setContent:announcementObject.content];
        [announcement setDateTime:announcementObject.dateTime];
        [announcement setFromID:announcementObject.fromID];
        [announcement setFromUsername:announcementObject.fromUsername];
        [announcement setImportanceType:[NSNumber numberWithInteger:announcementObject.importanceType]];
        [announcement setToID:announcementObject.toID];
        [announcement setToUsername:announcementObject.toUsername];
        [announcement setSenderAvatar:announcementObject.senderAvatar];
        [announcement setUnreadFlag:[NSNumber numberWithBool:announcementObject.unreadFlag]];
        
        for (PhotoObject *photoObj in announcementObject.imgArray) {
            Photos *photo = [NSEntityDescription
                                           insertNewObjectForEntityForName:@"Photos"
                                           inManagedObjectContext:self.defaultManagedObjectContext];
            
            [photo setPhotoID:[NSNumber numberWithInteger:photoObj.photoID]];
            [photo setOrder:[NSNumber numberWithInteger:photoObj.order]];
            [photo setCaption:photoObj.caption];
            
            //save file to local then change file path
            NSString *newPath = [[ArchiveHelper sharedArchiveHelper] savePhotoWithPath:photoObj.filePath];
            [photo setFilePath:newPath];
            
            [announcement addAnnouncementToPhotosObject:photo];
        }
        
        [self commitInManagedObjectContext:self.defaultManagedObjectContext];
    }
}

- (void)insertAnnouncementsArray:(NSArray *)announcementArr {
    for (AnnouncementObject *announcementObj in announcementArr) {
        [self insertNewAnnouncement:announcementObj];
    }
}

- (NSArray *)loadAllAnnouncementsFromID:(NSInteger)announcementID toUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (announcementID == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (announcementID < %d)", userID, announcementID];
        
        
    }
    results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_ANNOUNCEMENTS];
    results = [self transferFromAnnouncementsToAnnouncementObject:results];
    
    return results;
}

- (NSArray *)loadUnreadAnnouncementsFromID:(NSInteger)announcementID toUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (announcementID == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (unreadFlag == 1)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(toID == %@) AND (announcementID < %d) AND (unreadFlag == 1)", userID, announcementID];
        
    }
    
    results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_ANNOUNCEMENTS];
    results = [self transferFromAnnouncementsToAnnouncementObject:results];
    
    return results;
}

- (NSArray *)loadSentAnnouncementsFromID:(NSInteger)announcementID fromUserID:(NSString *)userID {
    NSArray *results = nil;
    NSPredicate *predicate = nil;
    
    if (userID == nil) {
        userID = @"";
    }
    
    if (announcementID == 0) {
        predicate = [NSPredicate predicateWithFormat:@"(fromID == %@)", userID];
        
    } else {
        
        predicate = [NSPredicate predicateWithFormat:@"(fromID == %@) AND (announcementID < %d)", userID, announcementID];
        
    }
    
    results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_ANNOUNCEMENTS];
    results = [self transferFromAnnouncementsToAnnouncementObject:results];
    return results;
}

- (NSArray *)transferFromAnnouncementsToAnnouncementObject:(NSArray *)announcements {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if ([announcements count] > 0) {
        /*
         @property (nonatomic, assign) NSInteger announcementID;
         @property (nonatomic, strong) NSString *subject;
         @property (nonatomic, strong) NSString *content;
         @property (nonatomic, strong) NSString *dateTime;
         @property (nonatomic, strong) NSString *fromID;
         @property (nonatomic, strong) NSString *fromUsername;
         @property (nonatomic, strong) NSString *toID;
         @property (nonatomic, strong) NSString *toUsername;
         @property (nonatomic, assign) ANNOUNCEMENT_IMPORTANCE_TYPE importanceType;
         @property (nonatomic, strong) NSMutableArray *imgArray;
         @property (nonatomic, assign) BOOL unreadFlag;
         */
        for (Announcements *announcement in announcements) {
            AnnouncementObject *announcementObj = [[AnnouncementObject alloc] init];
            
            announcementObj.announcementID = [announcement.announcementID integerValue];
            announcementObj.content = announcement.content;
            announcementObj.dateTime = announcement.dateTime;
            announcementObj.fromID = announcement.fromID;
            announcementObj.fromUsername = announcement.fromUsername;
            announcementObj.importanceType = (ANNOUNCEMENT_IMPORTANCE_TYPE)[announcement.importanceType integerValue];
            announcementObj.subject = announcement.subject;
            announcementObj.toID = announcement.toID;
            announcementObj.toUsername = announcement.toUsername;
            announcementObj.senderAvatar = announcement.senderAvatar;
            announcementObj.unreadFlag = [announcement.unreadFlag boolValue];
            
            for (Photos *photo in announcement.announcementToPhotos) {
                PhotoObject *photoObj = [[PhotoObject alloc] init];
                
                photoObj.photoID = [photo.photoID integerValue];
                photoObj.order = [photo.order integerValue];
                photoObj.caption = photo.caption;
                photoObj.filePath = photo.filePath;
                
                [announcementObj.imgArray addObject:photoObj];
            }
            
            [results addObject:announcementObj];
        }
    }
    
    return results;
}

- (void)updateAnnouncementRead:(NSInteger)announcementID withFlag:(BOOL)flag {
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"(announcementID == %d)", announcementID];
    
    NSArray *results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_ANNOUNCEMENTS];
    
    if ([results count] > 0) {
        Announcements *announcement = [results objectAtIndex:0];
        
        [announcement setUnreadFlag:[NSNumber numberWithBool:!flag]];
        
        [self.defaultManagedObjectContext save:nil];
    }
}

- (void)updateAnnouncementImportance:(NSInteger)announcementID withFlag:(BOOL)flag {
    NSPredicate *predicate = nil;
    
    predicate = [NSPredicate predicateWithFormat:@"(announcementID == %d)", announcementID];
    
    NSArray *results = [self fetchDataWithPredicate:predicate fromEntity:ENTITY_ANNOUNCEMENTS];
    
    if ([results count] > 0) {
        Announcements *announcement = [results objectAtIndex:0];
        
        [announcement setImportanceType:[NSNumber numberWithBool:flag]];
        
        [self.defaultManagedObjectContext save:nil];
    }
}
@end