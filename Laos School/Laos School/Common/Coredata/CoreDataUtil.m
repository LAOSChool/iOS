//
//  CoreDataUtil.m
//  LaosSchool
//
//  Created by Nguyen Nam on 12/9/14.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataUtil.h"


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


//-(void)insertContactInfo:(ContactInfoDAO *)contactInfoDAO {
//    ContactInfo *ct = [NSEntityDescription
//                     insertNewObjectForEntityForName:@"ContactInfo"
//                     inManagedObjectContext:self.defaultManagedObjectContext];
//    
//    [ct setContactID:[NSNumber numberWithInteger:contactInfoDAO.contactID]];
//    [ct setFirstName:contactInfoDAO.firstName];
//    [ct setLastName:contactInfoDAO.lastName];
//    [ct setAvatar:contactInfoDAO.avatar];
//    
//    if (contactInfoDAO.phoneNumberArr != nil) {
//        for (PhoneNumberDAO *phoneNumberDAO in contactInfoDAO.phoneNumberArr) {
//            PhoneNumber *phoneNumber = [NSEntityDescription
//                                        insertNewObjectForEntityForName:@"PhoneNumber"
//                                        inManagedObjectContext:self.defaultManagedObjectContext];
//            [phoneNumber setPhoneType:phoneNumberDAO.phoneType];
//            [phoneNumber setPhoneNumber:phoneNumberDAO.phoneNumber];
//            [phoneNumber setToContactInfo:ct];
//            
//            [ct addToPhoneNumberObject:phoneNumber];
//        }
//    }
//    
//    [self commitInManagedObjectContext:self.defaultManagedObjectContext];
//}
//
//-(NSArray *)fetchContactsWithPredicate:(NSPredicate *)predicate {
//    NSArray *results = nil;
//    if (self.defaultManagedObjectContext) {
//        NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"ContactInfo" inManagedObjectContext:self.defaultManagedObjectContext];
//        
//        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//        [fetchRequest setEntity:entityDescription];
//        if (predicate != nil) {  // Suspect the check is not required
//            [fetchRequest setPredicate:predicate];
//        }
//        NSError *error;
//        results = [self.defaultManagedObjectContext executeFetchRequest:fetchRequest error:&error];
//    }
//    return results;
//}
//
//-(NSArray *)getAllContacts {
//    return [self fetchContactsWithPredicate:nil];
//}

@end