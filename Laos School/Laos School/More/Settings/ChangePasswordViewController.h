//
//  ChangePasswordViewController.h
//  Laos School
//
//  Created by HuKhong on 5/23/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
@interface ChangePasswordViewController : UIViewController
{

    IBOutlet CustomTextField *txtOldPass;
    IBOutlet CustomTextField *txtNewPass;
    IBOutlet CustomTextField *txtConfirmation;
    IBOutlet UIButton *btnSubmit;
}

@end
