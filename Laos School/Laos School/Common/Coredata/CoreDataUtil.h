//
//  CoreDataUtil.h
//  LaosSchool
//
//  Created by Nguyen Nam on 12/9/14.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#ifndef LaosSchool_CoreDataUtil_h
#define LaosSchool_CoreDataUtil_h
#import <CoreData/CoreData.h>
#import "MessageObject.h"

@interface CoreDataUtil : NSObject
{
    
}

@property (strong, nonatomic) NSManagedObjectContext *defaultManagedObjectContext;

+(CoreDataUtil *)sharedCoreDataUtil;
+(dispatch_queue_t)getDispatch;

//-(void)insertPhoneType:(PhoneType *)phoneType;
- (void)insertNewMessage:(MessageObject *)messageObject;
- (void)insertMessagesArray:(NSArray *)messageArr;
- (NSArray *)loadAllMessagesFromID:(NSInteger)messageID toUserID:(NSString *)userID;
- (NSArray *)loadUnreadMessagesFromID:(NSInteger)messageID toUserID:(NSString *)userID;
- (NSArray *)loadSentMessagesFromID:(NSInteger)messageID fromUserID:(NSString *)userID;
@end
#endif
