//
//  PersonalInfoViewController.h
//  Laos School
//
//  Created by HuKhong on 3/7/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTextField.h"
#import "UserObject.h"
#import "AsyncImageView.h"

@interface PersonalInfoViewController : UIViewController
{
    IBOutlet CustomTextField *txtPhonenumber;
    IBOutlet CustomTextField *txtUserEmail;
    IBOutlet AsyncImageView *imgAvatar;

    IBOutlet CustomTextField *txtParentPhone;
    IBOutlet CustomTextField *txtParentEmail;
    IBOutlet UITextView *txtParentAddress;
    IBOutlet UILabel *lbFullname;
    IBOutlet UILabel *lbAdditionalInfo;
    
    IBOutlet UILabel *lbParentInfo;
}

@property (nonatomic, strong) UserObject *userObj;
@end
