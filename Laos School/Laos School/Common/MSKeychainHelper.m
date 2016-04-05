//
//  MSKeychainHelper.h
//
//
//  Created by Nguyen Nam on 3/3/15.
//  Copyright (c) 2014 ITPRO. All rights reserved.
//

#import "MSKeychainHelper.h"
#import <TargetConditionals.h>


@implementation MSKeychainHelper

#define APP_NAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]

+(void)clearCredentials
{
    
    NSMutableDictionary *terminatorQuery = [NSMutableDictionary dictionary];
    
    // create a dictionary to use as a query
    // we will use the servicename and the username we got above to filter for the password
    [terminatorQuery setObject:serviceName forKey:(__bridge id)kSecAttrService];
    [terminatorQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    SecItemDelete((__bridge CFDictionaryRef)terminatorQuery);

    // Temporary fix
    NSMutableDictionary *terminator2Query = [NSMutableDictionary dictionary];
    
    // create a dictionary to use as a query
    // we will use the servicename and the username we got above to filter for the password
    [terminator2Query setObject:serviceName forKey:(__bridge id)kSecAttrService];
    [terminator2Query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    SecItemDelete((__bridge CFDictionaryRef)terminator2Query);
}


+(NSMutableDictionary*)getCredentials
{
    
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *itemQuery = [[NSMutableDictionary alloc] init];
    [itemQuery setObject:serviceName forKey:(__bridge id)kSecAttrService];
    [itemQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    // Use the proper search constants, return only the attributes of the first match.
    [itemQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [itemQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    NSDictionary *inceptionItemQuery = [NSDictionary dictionaryWithDictionary:itemQuery];
    
    CFDataRef itemRef = NULL;
    
    OSStatus queryError = SecItemCopyMatching((__bridge CFDictionaryRef)inceptionItemQuery, (CFTypeRef*)&itemRef);
    
    NSMutableDictionary *resultsDict;
    
    if(itemRef != nil)
    {
        resultsDict = (__bridge_transfer NSMutableDictionary*)itemRef;
    }
    
    if(queryError == errSecSuccess)
    {
        
        
        //NSLog(@"%@", resultsDict);
        // SET THE USERNAME
        [returnDict setObject:[resultsDict objectForKey:@"acct"] forKey:@"username"];
        
        
        NSMutableDictionary *passwordQuery = [NSMutableDictionary dictionary];
        
        // create a dictionary to use as a query
        // we will use the servicename and the username we got above to filter for the password
        [passwordQuery setObject:serviceName forKey:(__bridge id)kSecAttrService];
        [passwordQuery setObject:[resultsDict objectForKey:@"acct"] forKey:(__bridge id)kSecAttrAccount];
        [passwordQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        // set return type
        [passwordQuery setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        
        CFDataRef passwordRef = NULL;
        
        OSStatus passwordError = SecItemCopyMatching((__bridge CFDictionaryRef)passwordQuery, (CFTypeRef*)&passwordRef);
        NSData *passwordData;
        if(passwordRef != nil)
        {
            passwordData = (__bridge_transfer NSData*)passwordRef;
        }
        
        // SET THE PASSWORD
        if(passwordError == errSecSuccess)
        {
            if(passwordData != nil)
            {
                NSString *passwordString = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
                [returnDict setObject:passwordString forKey:@"password"];
            }
            else
            {
                [returnDict setObject:@"" forKey:@"password"];
            }
        }
        else
        {
            [returnDict setObject:@"" forKey:@"password"];
        }
        
    }
    else
    {
        [returnDict setObject:@"" forKey:@"username"];
        [returnDict setObject:@"" forKey:@"password"];
    }
    
    
    //NSLog(@"%@ = %@", [returnDict objectForKey:@"username"], [returnDict objectForKey:@"password"]);
    
    return returnDict;
}



+(void)savePassword:(NSString*)password forUsername:(NSString*)username
{
    if(password != nil && username != nil)
    {
        
        // Basically we create a dictionary with the attributes of what we would like to store
        // We then use this dictionary and do a query on the keychain
        // If we find the dictionary in question is actually in the keychain we'll just update the password
        // If we find the dictionary is not we just add the dictionary
        
        // create credential dictionary
        NSMutableDictionary *myCredentialDictionary = [NSMutableDictionary dictionary];
        
        // hand load the service name
        [myCredentialDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
        // associate the password we are going to make with username/account
        [myCredentialDictionary setObject:username forKey:(__bridge id)kSecAttrAccount];
        // create a generic password - this adds a generica password to the keychain
        [myCredentialDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
        // the credentials should only be access when the device is unlocked
        [myCredentialDictionary setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
        
        // lets see if this dictionary is already in the keychain
        OSStatus keychainError = SecItemCopyMatching((__bridge CFDictionaryRef)myCredentialDictionary, NULL);
        
        // if this dictionary is already in the keychain lets just update it
        if(keychainError == errSecSuccess)
        {
            //since this dictionary is already there, we should create a key/value of the password and issue the OSStatus command to update
            NSMutableDictionary *newHotnessPassword = [NSMutableDictionary dictionaryWithObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
            keychainError = SecItemUpdate((__bridge CFDictionaryRef)myCredentialDictionary, (__bridge CFDictionaryRef)newHotnessPassword);
            if(keychainError != errSecSuccess)
            {
                NSLog(@"we had an issue updating the keychain in MSCommonLoginController");
            }
            
        }
        // if this dictionary is not found we can push a fresh new one in
        else if(keychainError == errSecItemNotFound)
        {
            // push the actual password value into the keychain
            [myCredentialDictionary setObject:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
            keychainError = SecItemAdd((__bridge CFDictionaryRef)myCredentialDictionary, NULL);
            if(keychainError != errSecSuccess)
            {
                NSLog(@"we had an issue updating the keychain in MSCommonLoginController");
            }
            
        }
        else
        {
            NSLog(@"we had an issue updating the keychain in MSCommonLoginController - uncaptured keychainError");
        }
        
    }
    else
    {
        NSLog(@"The password or username you provided were nil");
    }
    
}

// Gets the AppIdentifierPrefix at runtime
+(NSString*)getAppIdentifierPrefix
{
    // create the dummy query dictionary, we basically create a super generic entry
    // to put into the keychain, then probe the result
    NSMutableDictionary *itemQuery = [[NSMutableDictionary alloc] init];
    // load up the account which we just call bundleseedid
    [itemQuery setObject:@"bundleSeedID" forKey:(__bridge id)kSecAttrAccount];
    // load up the dummy service name
    [itemQuery setObject:@"dummyService" forKey:(__bridge id)kSecAttrService];
    // we are looking for a generic password class
    [itemQuery setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    // Use the proper search constants, return only the attributes of the first match.
    //[itemQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    // set return attributes to true
    [itemQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnAttributes];
    
    NSDictionary *inceptionItemQuery = [NSDictionary dictionaryWithDictionary:itemQuery];
    
    CFDictionaryRef itemRef = NULL;
    
    OSStatus queryError = SecItemCopyMatching((__bridge CFDictionaryRef)inceptionItemQuery, (CFTypeRef*)&itemRef);
    
    // if this dummy query wasn't found add it
    if(queryError == errSecItemNotFound)
    {
        queryError = SecItemAdd((__bridge CFDictionaryRef)inceptionItemQuery, (CFTypeRef*)&itemRef);
    }
    
    // if we get success (since we previously checked for item not found)
    if(queryError == errSecSuccess)
    {
        // grab the full access group name
        NSString *fullAccessGroup = [(__bridge NSDictionary*)itemRef objectForKey:(__bridge id)kSecAttrAccessGroup];
        // split the name by .
        NSArray *tokenizedElements = [fullAccessGroup componentsSeparatedByString:@"."];
        // grab the app identifier prefix
        NSString *appIdentifierPrefix = [[tokenizedElements objectEnumerator] nextObject];
        // check to see that the app identifier is not nil, if not return the composited usergroup
        if(appIdentifierPrefix != nil)
        {
            return appIdentifierPrefix;
        }
        else
        {
            // return empty string
            return @"";
        }
        
    }
    // if we get anything that is not success at this point return nil
    else
    {
        // return empty string
        return @"";
    }
    
}

@end
