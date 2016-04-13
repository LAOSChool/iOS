//
//  RequestToServer.h
//  Laos School
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LazzyBee_RequestToServer_h
#define LazzyBee_RequestToServer_h
#import <Foundation/Foundation.h>

#define SERVER_PATH @"https://192.168.0.202:9443/laoschoolws"
#define API_NAME_LOGIN @"/login"
#define API_NAME_MYPROFILE @"/api/users/myprofile"
#define API_NAME_MESSAGELIST @"/api/messages"
#define API_NAME_CREATEMESSAGE @"/api/messages/create"
#define API_NAME_RESET_FORGOT_PASS @"/forgot_pass"

#define HttpOK 200
#define Accepted 201
#define NonAuthen 203
#define HttpNoResponse 204
#define RangeReceived 206
#define BadCredentials 401
#define HttpNotFound 404

@protocol RequestToServerDelegate <NSObject>

@optional // Delegate protocols

- (void)failToConnectToServer;
- (void)sendPostRequestFailedWithUnknownError;
- (void)sendPostRequestSuccessfully;
- (void)loginSuccessfully;
- (void)loginWithWrongUserPassword;
- (void)accountLoginByOtherDevice;
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj;
@end

@interface RequestToServer : NSObject

// a singleton:
+ (RequestToServer*) sharedRequestToServer;
- (NSString *)getAPIKey;

- (void)requestToResetForgotPassword:(NSString *)username andPhonenumber:(NSString *)phonenumber;
- (void)createMessageWithObject:(NSDictionary *)messageDict;
- (void)getMessageListToUser:(NSString *)userID;
- (void)getMyProfile;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;


@property(nonatomic, readwrite) id <RequestToServerDelegate> delegate;
@end

#endif
