//
//  MSKeychainHelper.h
//  
//
//  Created by Nguyen Nam on 3/3/15.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

#define serviceName @"spicecall"

@interface MSKeychainHelper : NSObject

// Using serviceName as the service
+(void)savePassword:(NSString*)password forUsername:(NSString*)username;
+(NSMutableDictionary*)getCredentials;
+(void)clearCredentials;

// Programmatically retrieve ONLY THE APP IDENTIFIER PREFIX also known as the Bundle Seed ID
+(NSString*)getAppIdentifierPrefix;


@end