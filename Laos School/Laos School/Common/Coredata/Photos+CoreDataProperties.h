//
//  Photos+CoreDataProperties.h
//  Laos School
//
//  Created by HuKhong on 4/21/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Photos.h"

NS_ASSUME_NONNULL_BEGIN

@interface Photos (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *photoID;
@property (nullable, nonatomic, retain) NSString *caption;
@property (nullable, nonatomic, retain) NSString *filePath;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) Announcements *photoToAnnouncement;

@end

NS_ASSUME_NONNULL_END
