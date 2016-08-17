//
//  HelpViewController.m
//  Laos School
//
//  Created by HuKhong on 2/26/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "HelpViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "Common.h"
#import "CommonAlert.h"

#define HELP_LINK_ENG @"https://www.youtube.com/watch?v=dA8qruho2Ow"
#define HELP_LINK_LAOS @"https://www.youtube.com/watch?v=dA8qruho2Ow"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Help")];
    
    [self.navigationController setNavigationColor];
    
    if ([[Common sharedCommon] networkIsActive]) {
        NSString *urlAddress = HELP_LINK_ENG;
        NSString *curLang = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguageInApp"];
        
        if ([curLang isEqualToString:LANGUAGE_ENGLISH]) {
            urlAddress = HELP_LINK_ENG;
            
        } else {
            urlAddress = HELP_LINK_LAOS;
        }
        NSURL *url = [NSURL URLWithString:urlAddress];
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
        
        [webView loadRequest:requestObj];
        
    } else {
//        [self loadLocalHtml];
        [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
    }
    
    UIBarButtonItem *btnClose = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(closeButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnClose];
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

- (void)closeButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
