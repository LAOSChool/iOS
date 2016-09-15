//
//  SchoolInfoViewController.m
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "SchoolInfoViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "Common.h"
#import "CommonAlert.h"

@import FirebaseAnalytics;
@import FirebaseRemoteConfig;

#define SCHOOL_INFO_LINK_ENG @"http://%@/ls2/school_info/?lang=en&school_id=%@"
#define SCHOOL_INFO_LINK_LAOS @"http://%@/ls2/school_info/?lang=la&school_id=%@"

@interface SchoolInfoViewController ()

@end

@implementation SchoolInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [FIRAnalytics logEventWithName:@"Open_iSchoolInfoScreen" parameters:@{
                                                                    kFIRParameterValue:@(1)
                                                                    }];
    [self.navigationController setNavigationColor];
    [self setTitle:LocalizedString(@"School info")];
    FIRRemoteConfig *config = [FIRRemoteConfig remoteConfig];
    __block NSString *domain = @"itpro.vn";
    
    if ([[Common sharedCommon] networkIsActive]) {
        [config fetchWithExpirationDuration:43200 completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
            if (status == FIRRemoteConfigFetchStatusSuccess) {
                NSLog(@"Config fetched!");
                [config activateFetched];
                FIRRemoteConfigValue *domainName = config[@"domain_name"];
                
                if (domainName.stringValue && domainName.stringValue.length > 0) {
                    domain = domainName.stringValue;
                }
                
            } else {
                NSLog(@"Config not fetched");
                NSLog(@"Error %@", error);
                domain = @"itpro.vn";
            }
            
            NSString *urlAddress = SCHOOL_INFO_LINK_ENG;
            
            NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
            
            if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
                urlAddress = [NSString stringWithFormat:SCHOOL_INFO_LINK_ENG, domain, _schoolID];
                
            } else {
                urlAddress = [NSString stringWithFormat:SCHOOL_INFO_LINK_LAOS, domain, _schoolID];
            }
            
            NSURL *url = [NSURL URLWithString:urlAddress];
            NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
            
            [webView loadRequest:requestObj];
        }];
        
    } else {
//        [self loadLocalHtml];
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

-(void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error {
//    [self loadLocalHtml];
}

- (void)loadLocalHtml {
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"school_info" ofType:@"htm"];
    
    NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
    
    if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
        htmlFile = [[NSBundle mainBundle] pathForResource:@"school_info" ofType:@"htm"];
        
    } else {
        htmlFile = [[NSBundle mainBundle] pathForResource:@"school_info_laos" ofType:@"htm"];
    }
    
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    
    [webView loadHTMLString:htmlString baseURL:nil];
}
@end
