//
//  ForgotPasswordViewController.h
//  Laos School
//
//  Created by HuKhong on 2/26/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"

@interface ForgotPasswordViewController : UIViewController
{
    IBOutlet UILabel *lbGuide1;
    IBOutlet UILabel *lbGuide2;
    
    IBOutlet CustomTextField *txtUsername;
    IBOutlet CustomTextField *txtPhonenumber;
    IBOutlet UIButton *btnSubmit;
}
@end
