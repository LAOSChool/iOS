//
//  Announcements+CoreDataProperties.h
//  Laos School
//
//  Created by HuKhong on 4/21/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Announcements.h"
#import "Photos.h"

NS_ASSUME_NONNULL_BEGIN

@interface Announcements (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *content;
@property (nullable, nonatomic, retain) NSString *dateTime;
@property (nullable, nonatomic, retain) NSString *fromID;
@property (nullable, nonatomic, retain) NSString *fromUsername;
@property (nullable, nonatomic, retain) NSNumber *importanceType;
@property (nullable, nonatomic, retain) NSNumber *announcementID;
@property (nullable, nonatomic, retain) NSString *subject;
@property (nullable, nonatomic, retain) NSString *toID;
@property (nullable, nonatomic, retain) NSString *toUsername;
@property (nullable, nonatomic, retain) NSNumber *unreadFlag;
@property (nullable, nonatomic, retain) NSSet<Photos *> *announcementToPhotos;

@end

@interface Announcements (CoreDataGeneratedAccessors)

- (void)addAnnouncementToPhotosObject:(Photos *)value;
- (void)removeAnnouncementToPhotosObject:(Photos *)value;
- (void)addAnnouncementToPhotos:(NSSet<Photos *> *)values;
- (void)removeAnnouncementToPhotos:(NSSet<Photos *> *)values;

@end

NS_ASSUME_NONNULL_END
