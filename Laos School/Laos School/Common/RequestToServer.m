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
#import "DateTimeHelper.h"

#define LIMIT_DAY_TO_LOAD (1*30*24*3600)

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

#pragma mark timetable
- (void)getMyTimeTable:(NSString *)classID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_TIMETABLE_LIST];
    requestString = [NSString stringWithFormat:@"%@?filter_class_id=%@", requestString, classID];
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

- (void)getSubjectsListByClassID:(NSString *)classID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_GET_SUBJECTS_LIST];
    requestString = [NSString stringWithFormat:@"%@?filter_class_id=%@", requestString, classID];
    
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

- (void)getScoreTypeList {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_GET_EXAM_TYPE_LIST];
    
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

#pragma mark score
- (void)getMyScoreListInClass:(NSString *)classID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_SCORE_LIST];
//    requestString = [NSString stringWithFormat:@"%@?filter_class_id=%@", requestString, classID];
    
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

- (void)getScoresListByClassID:(NSString *)classID andSubjectID:(NSString *)subjectID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_SCORE_LIST];
    requestString = [NSString stringWithFormat:@"%@?filter_class_id=%@&filter_subject_id=%@", requestString, classID, subjectID];

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

- (void)submitScoreWithObject:(NSDictionary *)scoreDict {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_ADD_SCORE];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:scoreDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[myString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[myString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)submitMultipleScoresWithObject:(NSArray *)scoresArray {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_ADD_MULTIPLE_SCORE];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:scoresArray options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[myString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[myString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)getRankingDataByserID:(NSString *)userID inClass:(NSString *)classID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_RANKING];
    requestString = [NSString stringWithFormat:@"%@?filter_student_id=%@&filter_class_id=%@", requestString, userID, classID];
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

#pragma mark attendance
- (void)getAttendancesListWithUserID:(NSString *)userID inClass:(NSString *)classID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_ATTENDANCE_LIST];
    requestString = [NSString stringWithFormat:@"%@?filter_user_id=%@&filter_class_id=%@", requestString, userID, classID];
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

- (void)createAbsenceRequest:(NSDictionary *)requestDict fromDate:(NSString*)fromDate toDate:(NSString *)toDate {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_REQ_ATTENDANCE];
    requestString = [NSString stringWithFormat:@"%@?from_dt=%@&to_dt=%@", requestString, fromDate, toDate];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:requestDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[myString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[myString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)getStudentListWithAndAttendanceInfo:(NSString *)classID inDate:(NSString*)date {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_CHECK_ATTENDANCE_LIST];

    requestString = [NSString stringWithFormat:@"%@?filter_class_id=%@&filter_date=%@", requestString, classID, date];
    
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

- (void)createAttendanceChecking:(NSDictionary *)attendanceDict {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_CREATE_ATTENDANCE];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:attendanceDict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[myString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[myString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)deleteAttendanceItem:(NSString *)attID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_TEACHER_CANCEL_ATTENDANCE];
    
    requestString = [NSString stringWithFormat:@"%@/%@", requestString, attID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a GET request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

#pragma mark announcement
- (void)getAnnouncementsListToUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_ANNOUNCEMENT_LIST];
    
    NSTimeInterval date = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeInSec];
    date = date - LIMIT_DAY_TO_LOAD;   //only load messages from last 30 days
    
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_id=%ld&filter_from_time=%.f", requestString, userID, (long)announcementID, date];
    
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

- (void)getUnreadAnnouncementsListToUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_ANNOUNCEMENT_LIST];
    
    NSTimeInterval date = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeInSec];
    date = date - LIMIT_DAY_TO_LOAD;   //only load messages from last 30 days
    
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_id=%ld&filter_is_read=0&filter_from_time=%.f", requestString, userID, (long)announcementID, date];
    
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

- (void)getSentAnnouncementsListFromUser:(NSString *)userID fromAnnouncementID:(NSInteger)announcementID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_ANNOUNCEMENT_LIST];
    
    NSTimeInterval date = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeInSec];
    date = date - LIMIT_DAY_TO_LOAD;   //only load messages from last 30 days
    
    requestString = [NSString stringWithFormat:@"%@?filter_from_user_id=%@&filter_from_id=%ld&filter_from_time=%.f", requestString, userID, (long)announcementID, date];
    
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

- (void)updateAnnouncementRead:(NSInteger)announcementID withFlag:(BOOL)flag {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_UPDATE_ANNOUNCEMENT];
    requestString = [NSString stringWithFormat:@"%@/%ld?is_read=%d", requestString, (long)announcementID, flag];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)updateAnnouncementImportance:(NSInteger)announcementID withFlag:(BOOL)flag {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_UPDATE_ANNOUNCEMENT];
    requestString = [NSString stringWithFormat:@"%@/%ld?imp_flg=%d", requestString, (long)announcementID, flag];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}


#pragma mark login and password
- (void)requestToChangePassword:(NSString *)username oldPass:(NSString *)oldPass byNewPass:(NSString *)newPass {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_CHANGE_PASS];

//    requestString = [NSString stringWithFormat:@"%@?username=%@&old_pass=%@&new_pass=%@", requestString, username, oldPass, newPass];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *parameters = @{ @"username": username,
                                  @"old_pass": oldPass,
                                  @"new_pass": newPass };
   
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    [request setValue:[NSString
                       stringWithFormat:@"%lu", (unsigned long)[myString length]] forHTTPHeaderField:@"Content-length"];
    
    [request setHTTPBody:[myString
                          dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}


- (void)requestToResetForgotPassword:(NSString *)username andPhonenumber:(NSString *)phonenumber {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_RESET_FORGOT_PASS];
    requestString = [NSString stringWithFormat:@"%@?sso_id=%@&phone=%@", requestString, username, phonenumber];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
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

- (void)sendLogoutRequest {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_LOGOUT];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

#pragma mark messages
- (void)getStudentList:(NSString *)classID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STUDENT_LIST];
    requestString = [NSString stringWithFormat:@"%@?filter_class_id=%@&filter_user_role=STUDENT", requestString, classID];
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

- (void)updateMessageRead:(NSInteger)messageID withFlag:(BOOL)flag {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_UPDATEMESSAGE];
    requestString = [NSString stringWithFormat:@"%@/%ld?is_read=%d", requestString, (long)messageID, flag];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

- (void)updateMessageImportance:(NSInteger)messageID withFlag:(BOOL)flag {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_UPDATEMESSAGE];
    requestString = [NSString stringWithFormat:@"%@/%ld?imp_flg=%d", requestString, (long)messageID, flag];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
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

- (void)getMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    
    NSTimeInterval date = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeInSec];
    date = date - LIMIT_DAY_TO_LOAD;   //only load messages from last 30 days
    
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_id=%ld&filter_from_time=%.f", requestString, userID, (long)messageID, date];
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

- (void)getMessageListToUser:(NSString *)userID fromDate:(NSString *)date {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_dt=%@", requestString, userID, date];
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

- (void)getUnreadMessageListToUser:(NSString *)userID fromMessageID:(NSInteger)messageID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    
    NSTimeInterval date = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeInSec];
    date = date - LIMIT_DAY_TO_LOAD;   //only load messages from last 30 days
    
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_id=%ld&filter_is_read=0&filter_from_time=%.f", requestString, userID, (long)messageID, date];
    
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

- (void)getUnreadMessageListToUser:(NSString *)userID fromDate:(NSString *)date {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    requestString = [NSString stringWithFormat:@"%@?filter_to_user_id=%@&filter_from_dt=%@&filter_is_read=0", requestString, userID, date];
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

- (void)getSentMessageListFromUser:(NSString *)userID fromMessageID:(NSInteger)messageID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    
    NSTimeInterval date = [[DateTimeHelper sharedDateTimeHelper] getCurrentDatetimeInSec];
    date = date - LIMIT_DAY_TO_LOAD;   //only load messages from last 30 days
    
    requestString = [NSString stringWithFormat:@"%@?filter_from_user_id=%@&filter_from_id=%ld&filter_from_time=%.f", requestString, userID, (long)messageID, date];
    
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

- (void)getSentMessageListFromUser:(NSString *)userID fromDate:(NSString *)date {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGELIST];
    requestString = [NSString stringWithFormat:@"%@?filter_from_user_id=%@&filter_from_dt=%@", requestString, userID, date];
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


#pragma mark absence
- (void)getAbsenceReasonSample {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_ABSENCE_REASON_SAMPLE];

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

- (void)getAttendanceMessageContentSample {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_MESSAGE_CONTENT_SAMPLE];

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

- (void)getInformMessageContentSample {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_INFORM_CONTENT_SAMPLE];
    
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

#pragma mark school record
- (void)getStudentTermList {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_TERMS_LIST];
    
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

- (void)getSchoolRecordForYear:(NSString *)termID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_STU_SCHOOL_RECORDS];
    requestString = [NSString stringWithFormat:@"%@?filter_year_id=%@", requestString, termID];
    
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

- (void)uploadFirebaseIDToServer:(NSString *)firebaseID {
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_UPLOAD_FIREBASE_ID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    // Specify that it will be a GET request
    [request setHTTPMethod:@"POST"];
    [request setValue:firebaseID forHTTPHeaderField:@"token"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

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
            } else {
                if ([[[response URL] lastPathComponent] isEqualToString:@"logout"]) {
                    [self logoutSuccessfully];
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
            
        } else {
            [SVProgressHUD dismiss];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)inError
{
    NSLog(@"didFailWithError :: %@", [inError description]);
    
    [self failToConnectToServer];
}

 - (NSString *)getAPIKey {
     NSString *apiKey = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
     return apiKey;
 }

- (void)failToConnectToServer {
    [self.delegate failToConnectToServer];
}

- (void)sendPostRequestFailedWithUnknownError {
    [self.delegate sendPostRequestFailedWithUnknownError];
}

- (void)loginSuccessfully {
    [self.delegate loginSuccessfully];
}

- (void)logoutSuccessfully {
    [self.delegate logoutSuccessfully];
}

- (void)loginWithWrongUserPassword {
    [self.delegate loginWithWrongUserPassword];
}

- (void)accountLoginByOtherDevice {
    [[ArchiveHelper sharedArchiveHelper] clearAuthKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PushToLoginScreen" object:nil];
    [self.delegate accountLoginByOtherDevice];
}

@end
