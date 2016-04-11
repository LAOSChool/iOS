//
//  ArchiveHelper.h
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#ifndef LaosSchool_ArchiveHelper_h
#define LaosSchool_ArchiveHelper_h
#import <Foundation/Foundation.h>

@interface ArchiveHelper : NSObject

@property (nonatomic, strong) NSString *downloadFolder;
@property (nonatomic, strong) NSString *documentsFolder;
@property (nonatomic, strong) NSString *libraryFolder;
@property (nonatomic, strong) NSString *tmpFolder;
@property (nonatomic, strong) NSString *privateDocumentsFolder;
@property (nonatomic, strong) NSString *trashFolder;
@property (nonatomic, strong) NSString *backupFolder;
@property (nonatomic, strong) NSString *restoreFolder;
@property (nonatomic, strong) NSString *dataFolder;



- (NSString *)downloadFolder;
- (NSString *)documentsFolder;
- (NSString *)libraryFolder;
- (NSString *)tmpFolder;
- (NSString *)privateDocumentsFolder;
- (NSString *)trashFolder;
- (NSString *)backupFolder;
- (NSString *)restoreFolder;
- (NSString *)dataFolder;

// a singleton:
+ (ArchiveHelper*) sharedArchiveHelper;

- (void)saveDataToPlistFile:(NSArray *)data plistFile:(NSString *)plistFile;
- (NSArray *)loadDataFromPlist:(NSString *)plistFile;
- (void)saveDataToUserDefaultStandard:(id)data withKey:(NSString *)key;
- (id)loadDataFromUserDefaultStandardWithKey:(NSString *)key;
- (void)clearUserDefaultStandardWithKey:(NSString *)key;

- (void)saveDataToGroupUserDefaultStandard:(id)data withKey:(NSString *)key;
- (id)loadDataFromGroupUserDefaultStandardWithKey:(NSString *)key;

- (void)savePersonalData:(NSObject *)personObject withKey:(NSString *)key;
- (NSObject *)loadPersonalDataWithKey:(NSString *)key;

- (void)saveAuthKey:(NSString *)authKey;
- (NSString *)loadAuthKey;

- (void)saveUsername:(NSString *)username;
- (NSString *)loadUsername;

- (void)trashFileAtPathAndEmpptyTrash:(NSString *)path;
- (NSString *)trashFileAtPath:(NSString *)path;
- (void)emptyTrash;
- (BOOL)checkFileExist:(NSString *)filePath;
- (NSString *)fileExistingInTempFolder;

@end

#endif
