//
//  PersonalInfoViewController.m
//  Laos School
//
//  Created by HuKhong on 3/7/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "PersonalInfoViewController.h"
#import "UINavigationController+CustomNavigation.h"
#import "LocalizeHelper.h"
#import "Common.h"
#import "ComposeViewController.h"

@import FirebaseAnalytics;

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [FIRAnalytics logEventWithName:@"Open_iStudentInfo" parameters:@{
                                                                    kFIRParameterValue:@(1)
                                                                    }];
    
    [self setTitle:LocalizedString(@"Student info")];
    lbParentInfo.text = LocalizedString(@"Parent info");
    
    txtPhonenumber.placeholder = LocalizedString(@"Phone number");
    txtUserEmail.placeholder = LocalizedString(@"Email");
    
    txtParentName.placeholder = LocalizedString(@"Name");
    txtParentPhone.placeholder = LocalizedString(@"Phone number");
    txtParentEmail.placeholder = LocalizedString(@"Email");
    
    [self.navigationController setNavigationColor];
    
    [txtPhonenumber setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_phone_gray.png"]];
    [txtUserEmail setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_email_gray.png"]];
    
    [txtParentName setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_user_gray.png"]];
    [txtParentPhone setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_phone_gray.png"]];
    [txtParentEmail setColor:[UIColor whiteColor] andImage:[UIImage imageNamed:@"ic_email_gray.png"]];
    
    //do not show keyboard
    txtPhonenumber.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    txtUserEmail.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    txtParentName.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    txtParentPhone.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    txtParentEmail.inputView = [[UIView alloc] initWithFrame:CGRectZero];
    
    txtPhonenumber.text     = _userObj.phoneNumber;
    txtUserEmail.text       = _userObj.email;
    
    txtParentName.text      = _userObj.parentName;
    txtParentPhone.text     = _userObj.parentPhone;
    txtParentEmail.text     = _userObj.parentEmail;
    txtParentAddress.text   = _userObj.address;
    
    if (_userObj.avatarPath && _userObj.avatarPath.length > 0) {
        //cancel loading previous image for cell
        [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:imgAvatar];
        
        //load the image
        imgAvatar.imageURL = [NSURL URLWithString:_userObj.fullAvatarPath];
        
    } else {
        imgAvatar.image = [UIImage imageNamed:@"img_default_user.png"];
    }
    
    lbFullname.text = _userObj.displayName;
    lbAdditionalInfo.text = _userObj.nickName;
    
    /*
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveInfo)];
    
    self.navigationItem.rightBarButtonItems = @[btnSave];
    */
    
    UIBarButtonItem *btnMessage = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_message.png"] style:UIBarButtonItemStyleDone target:self action:@selector(sendMessageClick)];
    
    self.navigationItem.rightBarButtonItems = @[btnMessage];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Close") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
    self.navigationItem.leftBarButtonItems = @[btnCancel];
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

- (void)sendMessageClick {
    [FIRAnalytics logEventWithName:@"sent_message_from_student_info" parameters:@{
                                                                     kFIRParameterValue:@(1)
                                                                     }];
    
    ComposeViewController *composeViewController = nil;
    
    composeViewController = [[ComposeViewController alloc] initWithNibName:@"TeacherComposeViewController" bundle:nil];
    composeViewController.isTeacherForm = YES;
    composeViewController.composeType = MessageCompose_Normal;
    
    //set recipient
    NSMutableArray *recipents = [[NSMutableArray alloc] init];
    [recipents addObject:_userObj];
    composeViewController.receiverArray = recipents;
    
    //set content
    NSString *content = @"";
    composeViewController.content = content;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [nav setModalPresentationStyle:UIModalPresentationFormSheet];
    [nav setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)btnCameraClick:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:LocalizedString(@"Select photo source") delegate:(id)self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"Camera"), LocalizedString(@"Photo library"), nil];
    
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveInfo {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdatedProfileInfo" object:nil];
}

#pragma mark action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag == 1) {  //photo source
        if (buttonIndex == 0) {
            NSLog(@"Camera");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypeCamera] == NO) {
                
                return;
            }
            
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.delegate = (id)self;
            controller.allowsEditing = YES;
            
            [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:controller animated:YES completion:nil];
            
        } else if (buttonIndex == 1) {
            NSLog(@"Library");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
                
                return;
            }
            
            UIImagePickerController* controller = [[UIImagePickerController alloc] init];
            controller.delegate = (id)self;
            [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:controller animated:YES completion:nil];
            
        } else if (buttonIndex == 2) {
            NSLog(@"Cancel");
        }
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* image = nil;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        image = [info objectForKey: UIImagePickerControllerEditedImage];
    } else {
        image = [info objectForKey: UIImagePickerControllerOriginalImage];
    }
    
    image = [[Common sharedCommon] scaleAndRotateImage:image withMaxSize:imgAvatar.frame.size.width * 2];
    
        imgAvatar.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    return NO;
}
@end
