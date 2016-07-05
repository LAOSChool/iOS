//
//  Messages+CoreDataProperties.h
//  Laos School
//
//  Created by HuKhong on 7/5/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Messages.h"

NS_ASSUME_NONNULL_BEGIN

@interface Messages (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *dateTime;
@property (nullable, nonatomic, retain) NSString *fromID;
@property (nullable, nonatomic, retain) NSString *fromUsername;
@property (nullable, nonatomic, retain) NSNumber *importanceType;
@property (nullable, nonatomic, retain) NSNumber *messageID;
@property (nullable, nonatomic, retain) NSNumber *messageType;
@property (nullable, nonatomic, retain) NSString *messageTypeIcon;
@property (nullable, nonatomic, retain) NSString *senderAvatar;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *toID;
@property (nullable, nonatomic, retain) NSString *toUsername;
@property (nullable, nonatomic, retain) NSNumber *unreadFlag;

@end

NS_ASSUME_NONNULL_END
