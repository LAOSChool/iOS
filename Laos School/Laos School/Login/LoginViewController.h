//
//  LoginViewController.h
//  Laos School
//
//  Created by HuKhong on 2/22/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface LoginViewController : UIViewController
{
    IBOutlet UIImageView *imgBackground;
    IBOutlet UILabel *lbAppName;
    
    IBOutlet UIView *viewContainer;
    IBOutlet UILabel *lbUsername;
    IBOutlet CustomTextField *txtUsername;
    IBOutlet UILabel *lbPassword;
    IBOutlet CustomTextField *txtPassword;

    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnForgot;
    IBOutlet UIButton *btnLanguage;
    IBOutlet UILabel *lbVersion;
}

@end
