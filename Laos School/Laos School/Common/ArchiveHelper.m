//
//  ArchiveHelper.m
//  LaosSchool
//
//  Created by HuKhong on 4/19/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import "ArchiveHelper.h"
#import "CommonDefine.h"
#import "MSKeychainHelper.h"
#import "UIKit/UIKit.h"

// Singleton
static ArchiveHelper* sharedArchiveHelper = nil;

@implementation ArchiveHelper
@synthesize downloadFolder, documentsFolder, libraryFolder, tmpFolder, privateDocumentsFolder, trashFolder, backupFolder, restoreFolder, dataFolder;

//-------------------------------------------------------------
// allways return the same singleton
//-------------------------------------------------------------
+ (ArchiveHelper*) sharedArchiveHelper {
    // lazy instantiation
    if (sharedArchiveHelper == nil) {
        sharedArchiveHelper = [[ArchiveHelper alloc] init];
    }
    return sharedArchiveHelper;
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

- (void)saveDataToPlistFile:(NSArray *)data plistFile:(NSString *)plistFile {
    NSFileManager *fileManager = [NSFileManager defaultManager]; // File manager instance
    
    NSString *pathURL = [[fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL] path];
    NSString *filePath = [pathURL stringByAppendingPathComponent:plistFile];
    
    NSError  *error;
    NSData* archiveData = [NSKeyedArchiver archivedDataWithRootObject:data];
    [archiveData writeToFile:filePath options:NSDataWritingAtomic error:&error];
    archiveData = nil;
}

- (NSArray *)loadDataFromPlist:(NSString *)plistFile {
    NSFileManager *fileManager = [NSFileManager defaultManager]; // File manager instance
    
    NSString *pathURL = [[fileManager URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL] path];
    NSString *filePath = [pathURL stringByAppendingPathComponent:plistFile];
    
    NSMutableArray *resArr = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    if (resArr == nil)
    {
        resArr = [[NSMutableArray alloc] init];
    }
    
    return resArr;
}

#pragma mark user default
- (void)saveDataToUserDefaultStandard:(id)data withKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:data forKey:key];
}

- (id)loadDataFromUserDefaultStandardWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id data = [defaults objectForKey:key];
    
    return data;
}

- (void)saveDataToGroupUserDefaultStandard:(id)data withKey:(NSString *)key {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.born2go.laosschool"];
    
    [defaults setObject:data forKey:key];
    
    [defaults synchronize];
}

- (id)loadDataFromGroupUserDefaultStandardWithKey:(NSString *)key {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.born2go.laosschool"];
    id data = [defaults objectForKey:key];
    
    return data;
}

- (void)clearUserDefaultStandardWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
}

- (void)savePersonalData:(NSObject *)personObject withKey:(NSString *)key {
    
    NSData *personEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:personObject];
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:personEncodedObject forKey:key];
}

- (NSObject *)loadPersonalDataWithKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:key];
    NSObject *res =  nil;
    
    if (data) {
        res = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return res;
}


- (void)emptyTrash {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self trashFolder] error:nil];
        if (files != nil && files.count > 0) {
            for (NSString *file in files) {
                NSString *path = [[self trashFolder] stringByAppendingPathComponent:file];
                
                [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            }
        }
    });
}

- (void)saveAuthKey:(NSString *)authKey {
    [MSKeychainHelper savePassword:authKey forUsername:KEY_AUTH_KEY];
}

- (NSString *)loadAuthKey {
    NSString *authKey = @"";
    NSDictionary *credentials = [MSKeychainHelper getCredentials];
    
    if (credentials) {
        authKey = [credentials valueForKey:@"password"];
    }
    
    return authKey;
}

- (void)clearAuthKey {
    [MSKeychainHelper clearCredentials];
}

- (void)saveUsername:(NSString *)username {
    [self saveDataToUserDefaultStandard:username withKey:KEY_USERNAME];
}

- (NSString *)loadUsername {
    NSString *username = @"";
    username = [self loadDataFromUserDefaultStandardWithKey:KEY_USERNAME];
    
    return username;
}

#pragma mark file operations
/*
 Moves the object at path to the trash and returns the path to it if successful
 */
-(NSString *)trashFileAtPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path]) {
        NSString *filename = [path lastPathComponent];
        NSString *trashPath = [[self trashFolder] stringByAppendingPathComponent:filename];
        int n = 0;
        while ([fm fileExistsAtPath:trashPath]) {
            n++;
            trashPath = [trashFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@(%d)", filename, n]];
        }
        NSError *error;
        [fm moveItemAtPath:path toPath:trashPath error:&error];
        if (error == nil) {
            return trashPath;
        }
    }
    return nil;
}

//move the folder at path to trash and delete it
- (void)trashFileAtPathAndEmpptyTrash:(NSString *)path {
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString *deletedName = [self trashFileAtPath:path];
        if (deletedName) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [[NSFileManager defaultManager] removeItemAtPath:deletedName error:nil];
            });
        }
    }
}

- (BOOL)checkFileExist:(NSString *)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:filePath]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)fileExistingInTempFolder {
    NSArray * directoryContents = [[NSFileManager defaultManager]
                                   contentsOfDirectoryAtPath:[self tmpFolder] error:nil];
    
    for (NSString *path in directoryContents) {
        if ([path rangeOfString:@"temp.wav"].location != NSNotFound) {
            return [path lastPathComponent];
        }
    }
    
    return @"";
}

#pragma mark folder operations
-(NSString *)applicationSupportFolder {
    return [[[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:NULL] path];
}

/*
 Returns the Download folder path from the sandbox
 */
-(NSString *)downloadFolder {
    if (downloadFolder == nil) {
        downloadFolder = [[self applicationSupportFolder] stringByAppendingPathComponent:@"Download"];
    }
    
    //    NSLog(@"downloadFolder: %@", documentsFolder);
    return downloadFolder;
}

/*
 Returns the Document folder path from the sandbox
 */
-(NSString *)documentsFolder {
    if (documentsFolder == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsFolder = [paths objectAtIndex:0];
    }
    
    //    NSLog(@"documentsFolder: %@", documentsFolder);
    return documentsFolder;
}

/*
 Return the path to the Library folder
 */
-(NSString *)libraryFolder {
    if (libraryFolder == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        libraryFolder = [paths objectAtIndex:0];
    }
    
    //    NSLog(@"libraryFolder: %@", libraryFolder);
    return libraryFolder;
}

/*
 Return the path to the tmp folder
 */
-(NSString *)tmpFolder {
    if (tmpFolder == nil) {
        tmpFolder = [privateDocumentsFolder stringByAppendingPathComponent:@"Temp Folder"];
        [[NSFileManager defaultManager] createDirectoryAtPath:tmpFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //    NSLog(@"tmpFolder: %@", tmpFolder);
    return tmpFolder;
}

/*
 Creates the "Private Documents" folder if needed and returns the path to it
 */
-(NSString *)privateDocumentsFolder {
    if (privateDocumentsFolder == nil) {
        privateDocumentsFolder = [[self libraryFolder] stringByAppendingPathComponent:@"Private Documents"];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:privateDocumentsFolder withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    //    NSLog(@"privateDocumentsFolder: %@", privateDocumentsFolder);
    return privateDocumentsFolder;
}

- (NSString *)trashFolder {
    if (trashFolder == nil) {
        trashFolder = [[self libraryFolder] stringByAppendingPathComponent:@"Trash Folder"];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:trashFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return trashFolder;
}

/*
 Return the path to the backup folder
 */
-(NSString *)backupFolder {
    if (backupFolder == nil) {
        backupFolder = [[self libraryFolder] stringByAppendingPathComponent:@"Backup"];
        [[NSFileManager defaultManager] createDirectoryAtPath:backupFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //    NSLog(@"backupFolder: %@", backupFolder);
    return backupFolder;
}

-(NSString *)restoreFolder {
    if (restoreFolder == nil) {
        restoreFolder = [[self libraryFolder] stringByAppendingPathComponent:@"Restore"];
        [[NSFileManager defaultManager] createDirectoryAtPath:restoreFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //    NSLog(@"restoreFolder: %@", restoreFolder);
    return restoreFolder;
}

-(NSString *)dataFolder {
    if (dataFolder == nil) {
        dataFolder = [[self libraryFolder] stringByAppendingPathComponent:@"Data"];
        [[NSFileManager defaultManager] createDirectoryAtPath:dataFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //    NSLog(@"dataFolder: %@", dataFolder);
    return dataFolder;
}

- (NSString *)savePhotoWithPath:(NSString *)filePath {
    NSString *fileName = [filePath lastPathComponent];
    NSString *res = [[self dataFolder] stringByAppendingPathComponent:fileName];
    
    if (fileName && fileName.length > 0) {
        NSData *storeImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
        [storeImageData writeToFile:res atomically:YES];
        
    } else {
        res = filePath;
    }
    
    return res;
}

- (NSString *)getPhotoFullPath:(NSString *)fileName {
    NSString *res = [[self dataFolder] stringByAppendingPathComponent:fileName];
    
    return res;
}
@end
