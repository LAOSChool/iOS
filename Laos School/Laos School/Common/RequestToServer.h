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

//#define TESTSERVER @"https://192.168.0.116:8443/laoschoolws"

#ifdef TESTSERVER
#define SERVER_PATH TESTSERVER
#else
#define SERVER_PATH @"https://192.168.0.202:9443/laoschoolws"
#endif

#define API_NAME_LOGIN @"/login"
#define API_NAME_MYPROFILE @"/api/users/myprofile"
#define API_NAME_MESSAGELIST @"/api/messages"
#define API_NAME_CREATEMESSAGE @"/api/messages/create"
#define API_NAME_RESET_FORGOT_PASS @"/forgot_pass"

#define API_NAME_ANNOUNCEMENTLIST @"/api/notifies"
#define API_NAME_CREATE_ANNOUNCEMENT @"/api/notifies/create"

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
- (void)loginSuccessfully;
- (void)loginWithWrongUserPassword;
- (void)accountLoginByOtherDevice;
- (void)connectionDidFinishLoading:(NSDictionary *)jsonObj;
@end

@interface RequestToServer : NSObject

// a singleton:
+ (RequestToServer*) sharedRequestToServer;
- (NSString *)getAPIKey;

//announcements
- (void)getAnnouncementsListToUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID;
- (void)getUnreadAnnouncementsListToUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID;
- (void)getSentAnnouncementsListFromUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID;

//messages
- (void)createMessageWithObject:(NSDictionary *)messageDict;
- (void)getMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID;
- (void)getUnreadMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID;
- (void)getSentMessageListFromUser:(NSString *)userID fromMessageID:(NSInteger)messageID;

//login and password
- (void)requestToResetForgotPassword:(NSString *)username andPhonenumber:(NSString *)phonenumber;
- (void)getMyProfile;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;


@property(nonatomic, readwrite) id <RequestToServerDelegate> delegate;
@end

#endif
