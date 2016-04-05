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

- (void)postJsonStringToServer:(NSString *)jsonString withApi:(NSString *)api {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, api];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.HTTPAdditionalHeaders = @{
                                                   @"auth_key"       : [self getAPIKey],
                                                   @"Content-Type"  : @"application/json"
                                                   };
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[jsonString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[jsonString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The server answers with an error because it doesn't receive the params
        NSLog(@"%@ :: %@", response, error);
    }];
    [postDataTask resume];
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
    
    //save user/pass, remove if login failed
    [MSKeychainHelper savePassword:username forUsername:password];
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
{
    
        switch (response.statusCode) {
            case HttpOK:
                if ([[[response URL] lastPathComponent] isEqualToString:@"login"]) {
                    if ([response respondsToSelector:@selector(allHeaderFields)]) {
                        NSDictionary *dictionary = [response allHeaderFields];
                        
                        [[ArchiveHelper sharedArchiveHelper] saveAuthKey:[dictionary valueForKey:@"auth_key"]];
                        [self loginSuccessfully];
                    }
                }
                break;
             
            case BadCredentials:
                [self loginWithWrongUserPassword];
                break;
                
            default:
                [self sendPostRequestFailedWithUnknownError];
                break;
                
        }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSError *error;
    NSDictionary *jsonObj = nil;
    if (data) {
        jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error == nil && [jsonObj count] > 0) {
            [self.delegate didReceiveData:jsonObj];
            
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{

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
@end
