//
//  SchoolInfoViewController.h
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolInfoViewController : UIViewController
{
    IBOutlet UIWebView *webView;
    
}

@property (nonatomic, strong) NSString *schoolID;
@end
