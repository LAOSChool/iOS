//
//  RequestToServer.m
//  Laos School
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "RequestToServer.h"
#import "UIKit/UIKit.h"
#import "ArchiveHelper.h"
#import "MSKeychainHelper.h"
#import "SVProgressHUD.h"

#import "CommonDefine.h"
// Singleton
static RequestToServer* sharedRequestToServer = nil;

@implementation RequestToServer
{
    NSMutableData *responseData;
}

//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (RequestToServer*) sharedRequestToServer {
    // lazy instantiation
    if (sharedRequestToServer == nil) {
        sharedRequestToServer = [[RequestToServer alloc] init];
    }
    return sharedRequestToServer;
}


//-------------------------------------------------------------
// initiating
//-------------------------------------------------------------
- (id) init {
    self = [super init];
    if (self) {
        // use systems main bundle as default bundle
    }
    return self;
}

- (void)requestToResetForgotPassword:(NSString *)username andPhonenumber:(NSString *)phonenumber {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_RESET_FORGOT_PASS];
    requestString = [NSString stringWithFormat:@"%@?sso_id=%@&phone=%@", requestString, username, phonenumber];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)createMessageWithObject:(NSDictionary *)messageDict {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_CREATEMESSAGE];
//    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@", requestString, userID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:messageDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[myString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[myString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)getMessageListToUser:(NSString *)userID fromMessageID:(NSString *)messageID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_id=%@", requestString, userID, messageID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a GET request
    [request setHTTPMethod:@"GET"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)getUnreadMessageListToUser:(NSString *)userID fromMessageID:(NSString *)messageID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_id=%@&filter_is_read=0", requestString, userID, messageID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a GET request
    [request setHTTPMethod:@"GET"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)getSentMessageListFromUser:(NSString *)userID fromMessageID:(NSString *)messageID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    requestString = [NSString stringWithFormat:@"%@?filter_from_user_id=%@&filter_from_id=%@", requestString, userID, messageID];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a GET request
    [request setHTTPMethod:@"GET"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)getMyProfile {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MYPROFILE];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"GET"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_LOGIN];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    
    [request setValue:username forHTTPHeaderField:@"sso_id"];
    [request setValue:password forHTTPHeaderField:@"password"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
{
    responseData = [[NSMutableData alloc] init];
    switch (response.statusCode) {
        case HttpOK:
            if ([[[response URL] lastPathComponent] isEqualToString:@"login"]) {
                if ([response respondsToSelector:@selector(allHeaderFields)]) {
                    NSDictionary *dictionary = [response allHeaderFields];
                    NSString *authKey = [dictionary valueForKey:@"auth_key"];

                    [[ArchiveHelper sharedArchiveHelper] saveAuthKey:authKey];
                    [self loginSuccessfully];
                }
            }
            break;
         
        case BadCredentials:
            [self loginWithWrongUserPassword];
            break;
            
        case NonAuthen:
            [self accountLoginByOtherDevice];
            break;
            
        default:
            
            NSLog(@"error code ::  %ld", (long)response.statusCode);
            [self sendPostRequestFailedWithUnknownError];
            break;
            
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data) {
        [responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *jsonObj = nil;
    if (responseData) {

        jsonObj = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if (error == nil && [jsonObj count] > 0) {
            [self.delegate connectionDidFinishLoading:jsonObj];
            
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)inError
{
    NSLog(@"didFailWithError :: %@", [inError description]);
    
    [self failToConnectToServer];
}

 - (NSString *)getAPIKey {
     NSString *apiKey = @"TEST_API_KEY";
     return apiKey;
 }

- (void)failToConnectToServer {
    [MSKeychainHelper clearCredentials];
    [self.delegate failToConnectToServer];
}

- (void)sendPostRequestFailedWithUnknownError {
    [MSKeychainHelper clearCredentials];
    [self.delegate sendPostRequestFailedWithUnknownError];
}

- (void)sendPostRequestSuccessfully {
    [self.delegate sendPostRequestSuccessfully];
}

- (void)loginSuccessfully {
    [self.delegate loginSuccessfully];
}

- (void)loginWithWrongUserPassword {
    [MSKeychainHelper clearCredentials];
    [self.delegate loginWithWrongUserPassword];
}

- (void)accountLoginByOtherDevice {
    [self.delegate accountLoginByOtherDevice];
}
@end
