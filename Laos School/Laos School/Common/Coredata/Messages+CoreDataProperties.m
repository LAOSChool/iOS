//
//  Messages+CoreDataProperties.m
//  Laos School
//
//  Created by HuKhong on 3/10/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Messages+CoreDataProperties.h"

@implementation Messages (CoreDataProperties)

@dynamic messageID;
@dynamic subject;
@dynamic content;
@dynamic fromID;
@dynamic fromUsername;
@dynamic toID;
@dynamic toUsername;
@dynamic unreadFlag;
@dynamic incomeOutgoType;
@dynamic messageType;
@dynamic importanceType;
@dynamic dateTime;

@end
