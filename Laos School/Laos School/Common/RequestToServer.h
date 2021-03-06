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


//#define TEST_SERVER @"https://192.168.0.120:8443/laoschoolws"

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
#define API_NAME_LOGOUT @"/api/logout"
#define API_NAME_MYPROFILE @"/api/users/myprofile"
#define API_NAME_RESET_FORGOT_PASS @"/forgot_pass"
#define API_NAME_CHANGE_PASS @"/api/users/change_pass"

#define API_NAME_MESSAGELIST @"/api/messages"
#define API_NAME_CREATEMESSAGE @"/api/messages/create"
#define API_NAME_UPDATEMESSAGE @"/api/messages/update"
#define API_NAME_STUDENT_LIST @"/api/users"
#define API_NAME_ABSENCE_REASON_SAMPLE @"/api/sys/sys_late_reason"
#define API_NAME_MESSAGE_CONTENT_SAMPLE @"/api/sys/sys_att_msg"
#define API_NAME_INFORM_CONTENT_SAMPLE @"/api/sys/sys_std_msg"


#define API_NAME_ANNOUNCEMENT_LIST @"/api/notifies"
#define API_NAME_CREATE_ANNOUNCEMENT @"/api/notifies/create"
#define API_NAME_UPDATE_ANNOUNCEMENT @"/api/notifies/update"

#define API_NAME_STU_ATTENDANCE_LIST @"/api/attendances/myprofile"
#define API_NAME_STU_REQ_ATTENDANCE @"/api/attendances/request"
#define API_NAME_TEACHER_CREATE_ATTENDANCE @"/api/attendances/create"
#define API_NAME_TEACHER_CANCEL_ATTENDANCE @"/api/attendances/delete"
#define API_NAME_TEACHER_CHECK_ATTENDANCE_LIST @"/api/attendances/rollup"

#define API_NAME_STU_SCORE_LIST @"/api/exam_results/myprofile"
#define API_NAME_TEACHER_SCORE_LIST @"/api/exam_results"
#define API_NAME_TEACHER_ADD_SCORE @"/api/exam_results/input"
#define API_NAME_TEACHER_ADD_MULTIPLE_SCORE @"/api/exam_results/input/batch"

#define API_NAME_STU_TIMETABLE_LIST @"/api/timetables"
#define API_NAME_TEACHER_GET_SUBJECTS_LIST @"/api/timetables/subjects"
#define API_NAME_TEACHER_GET_EXAM_TYPE_LIST @"/api/schools/exams"

#define API_NAME_STU_TERMS_LIST @"/api/school_years/myprofile"
#define API_NAME_STU_SCHOOL_RECORDS @"/api/edu_profiles/myprofile"

#define API_NAME_STU_RANKING @"/api/exam_results/ranks"

#define API_NAME_UPLOAD_FIREBASE_ID @"/api/tokens/save"

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
- (void)logoutSuccessfully;
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
- (void)getScoresListByClassID:(NSString *)classID andSubjectID:(NSString *)subjectID;
- (void)getScoreTypeList;
- (void)submitScoreWithObject:(NSDictionary *)scoreDict;
- (void)submitMultipleScoresWithObject:(NSArray *)scoresArray;
- (void)getRankingDataByserID:(NSString *)userID inClass:(NSString *)classID;

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
- (void)getMessageListToUser:(NSString *)userID fromDate:(NSString *)date;

- (void)getUnreadMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID;
- (void)getUnreadMessageListToUser:(NSString *)userID fromDate:(NSString *)date;

- (void)getSentMessageListFromUser:(NSString *)userID fromMessageID:(NSInteger)messageID;
- (void)getSentMessageListFromUser:(NSString *)userID fromDate:(NSString *)date;

- (void)getAbsenceReasonSample;
- (void)getAttendanceMessageContentSample;
- (void)getInformMessageContentSample;


//login and password
- (void)requestToResetForgotPassword:(NSString *)username andPhonenumber:(NSString *)phonenumber;
- (void)getMyProfile;
- (void)loginWithUsername:(NSString *)username andPassword:(NSString *)password;
- (void)requestToChangePassword:(NSString *)username oldPass:(NSString *)oldPass byNewPass:(NSString *)newPass;
- (void)sendLogoutRequest;


//school record
- (void)getStudentTermList;
- (void)getSchoolRecordForYear:(NSString *)termID;

- (void)uploadFirebaseIDToServer:(NSString *)firebaseID;

@property(nonatomic, readwrite) id <RequestToServerDelegate> delegate;
@end

#endif
