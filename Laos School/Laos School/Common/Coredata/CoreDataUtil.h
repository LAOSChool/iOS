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

@interface CoreDataUtil : NSObject
{
    
}

@property (strong, nonatomic) NSManagedObjectContext *defaultManagedObjectContext;

+(CoreDataUtil *)sharedCoreDataUtil;
+(dispatch_queue_t)getDispatch;

//-(void)insertPhoneType:(PhoneType *)phoneType;
//-(void)insertContactInfo:(ContactInfoDAO *)contactInfoDAO;
//-(BOOL)commitInManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;
//-(NSArray *)getAllContacts;

@end
#endif
