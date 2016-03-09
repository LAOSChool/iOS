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

@interface PersonalInfoViewController ()

@end

@implementation PersonalInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:LocalizedString(@"Update info")];
    
    [self.navigationController setNavigationColor];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveInfo)];
    
    self.navigationItem.rightBarButtonItems = @[btnSave];
    
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
    
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
    
    image = [[Common sharedCommon] scaleAndRotateImage:image withMaxSize:imgAvatar.frame.size.width];
    
        imgAvatar.image = image;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
