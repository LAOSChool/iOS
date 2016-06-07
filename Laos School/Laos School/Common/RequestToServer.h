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

//#define TEST_SERVER @"https://192.168.0.119:8443/laoschoolws"

#ifdef PRODUCTION_SERVER
#define SERVER_PATH PRODUCTION_SERVER
#else
#ifdef TEST_SERVER
#define SERVER_PATH TEST_SERVER
#else
#define SERVER_PATH @"https://192.168.0.202:9443/laoschoolws"
#endif
#endif

#define API_NAME_LOGIN @"/login"
#define API_NAME_MYPROFILE @"/api/users/myprofile"
#define API_NAME_RESET_FORGOT_PASS @"/forgot_pass"
#define API_NAME_CHANGE_PASS @"/api/users/change_pass"

#define API_NAME_MESSAGELIST @"/api/messages"
#define API_NAME_CREATEMESSAGE @"/api/messages/create"
#define API_NAME_UPDATEMESSAGE @"/api/messages/update"
#define API_NAME_STUDENT_LIST @"/api/users"

#define API_NAME_ANNOUNCEMENT_LIST @"/api/notifies"
#define API_NAME_CREATE_ANNOUNCEMENT @"/api/notifies/create"
#define API_NAME_UPDATE_ANNOUNCEMENT @"/api/notifies/update"

#define API_NAME_STU_ATTENDANCE_LIST @"/api/attendances/myprofile"
#define API_NAME_STU_REQ_ATTENDANCE @"/api/attendances/request"
#define API_NAME_TEACHER_CREATE_ATTENDANCE @"/api/attendances/create"
#define API_NAME_TEACHER_CANCEL_ATTENDANCE @"/api/attendances/delete"
#define API_NAME_TEACHER_CHECK_ATTENDANCE_LIST @"/api/attendances/rollup"

#define API_NAME_STU_SCORE_LIST @"/api/exam_results/myprofile"
#define API_NAME_STU_SCHOOL_RECORD_LIST @"/api/final_results/myprofile"

#define API_NAME_STU_TIMETABLE_LIST @"/api/timetables"
#define API_NAME_TEACHER_GET_SUBJECTS_LIST @"/api/timetables/subjects"


#define HttpOK 200
#define Accepted 201
#define HttpNoResponse 204
#define RangeReceived 206
#define BadCredentials 401
#define HttpNotFound 404
#define NonAuthen 409
#define Confliction 429

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

//Time table
- (void)getMyTimeTable:(NSString *)classID;
- (void)getSubjectsListByClassID:(NSString *)classID;


//score
- (void)getMyScoreListInClass:(NSString *)classID;
- (void)getMySchoolRecordInClass:(NSString *)classID;
- (void)getScoresListByClassID:(NSString *)classID andSubjectID:(NSString *)subjectID;

//attendance
- (void)getAttendancesListWithUserID:(NSString *)userID inClass:(NSString *)classID;
- (void)createAbsenceRequest:(NSDictionary *)requestDict fromDate:(NSString*)fromDate toDate:(NSString *)toDate;
- (void)getStudentListWithAndAttendanceInfo:(NSString *)classID inDate:(NSString*)date;
- (void)createAttendanceChecking:(NSDictionary *)attendanceDict;
- (void)deleteAttendanceItem:(NSString *)attID;

//announcements
- (void)updateAnnouncementRead:(NSInteger)announcementID withFlag:(BOOL)flag;
- (void)updateAnnouncementImportance:(NSInteger)announcementID withFlag:(BOOL)flag;
- (void)getAnnouncementsListToUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID;
- (void)getUnreadAnnouncementsListToUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID;
- (void)getSentAnnouncementsListFromUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID;

//messages
- (void)getStudentList:(NSString *)classID;
- (void)updateMessageRead:(NSInteger)messageID withFlag:(BOOL)flag;
- (void)updateMessageImportance:(NSInteger)messageID withFlag:(BOOL)flag;
- (void)createMessageWithObject:(NSDictionary *)messageDict;
- (void)getMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID;
- (void)getUnreadMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID;
- (void)getSentMessageListFromUser:(NSString *)userID fromMessageID:(NSInteger)messageID;

//login and password
- (void)requestToResetForgotPassword:(NSString *)username andPhonenumber:(NSString *)phonenumber;
- (void)getMyProfile;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)requestToChangePassword:(NSString *)username oldPass:(NSString *)oldPass byNewPass:(NSString *)newPass;

@property(nonatomic, readwrite) id <RequestToServerDelegate> delegate;
@end

#endif
