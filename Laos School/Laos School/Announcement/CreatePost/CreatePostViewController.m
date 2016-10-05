//
//  CreatePostViewController.m
//  Born2Go
//
//  Created by itpro on 5/12/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import "CreatePostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Common.h"
#import "PhotoObject.h"
#import "UserObject.h"
#import "ClassObject.h"
#import "CustomImageView.h"
#import "SVProgressHUD.h"
#import "LocalizeHelper.h"
#import "RequestToServer.h"
#import "ShareData.h"
#import "ArchiveHelper.h"
#import "CommonAlert.h"
#import "CoreDataUtil.h"

#import "UINavigationController+CustomNavigation.h"

#import "CTAssetsPickerController.h"
#import "CTAssetsPageViewController.h"

#import "FSBasicImage.h"
#import "FSBasicImageSource.h"

#import "JTSImageViewController.h"
#import "JTSImageInfo.h"

@import FirebaseAnalytics;

#define IMAGE_FILE_SIZE 1024
#define IMAGE_VIEW_HEIGHT 275
#define IMAGE_VIEW_OFFSET 8
#define IMAGE_KEYBOARD_OFFSET 250

#define IMAGE_LIMIT_NUMBER 5
#define PLACEHOLDER_SUBJECT @"Subject"
#define PLACEHOLDER_CONTENT @"Content"

@interface CreatePostViewController ()
{
    NSMutableArray *photoArray;
    NSMutableArray *imageViewArray;
    
    NSMutableData *responseData;
    PHImageRequestOptions *requestOptions;
    
    RequestToServer *requestToServer;
}
@end


@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self.navigationController setNavigationColor];
    
    [lbReceiverList setTextColor:BLUE_COLOR];
    
    photoArray = [[NSMutableArray alloc] init];
    imageViewArray = [[NSMutableArray alloc] init];
    
    requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.networkAccessAllowed = NO;
    
    if (_announcementObject == nil) {
        _announcementObject = [[AnnouncementObject alloc] init];
    }
    
    if (requestToServer == nil) {
        requestToServer = [[RequestToServer alloc] init];
        requestToServer.delegate = (id)self;
    }
    
    //border
    textViewTitle.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textViewTitle.layer.borderWidth = 0.3f;
    textViewTitle.layer.cornerRadius = 5.0f;
    textViewTitle.clipsToBounds = YES;
    
    textViewPost.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textViewPost.layer.borderWidth = 0.3f;
    textViewPost.layer.cornerRadius = 5.0f;
    textViewPost.clipsToBounds = YES;
    
    if (_isViewDetail) {
        [self setTitle:_announcementObject.subject];
        
        textViewTitle.text = _announcementObject.subject;
        textViewPost.text = _announcementObject.content;
        
        textViewPost.textColor = [UIColor blackColor];
        textViewTitle.textColor = [UIColor blackColor];
        
        lbTo.text = LocalizedString(@"From:");
        lbReceiverList.text = _announcementObject.fromUsername;
        lbDateTime.text = [[DateTimeHelper sharedDateTimeHelper] stringDateFromString:_announcementObject.dateTime withFormat:@"dd-MM-yyyy HH:mm:ss"];
        
        [textViewPost setFont:[UIFont systemFontOfSize:15]];
        
    } else {
        [self setTitle:LocalizedString(@"New anouncement")];
        lbTo.text = LocalizedString(@"To:");
        lbReceiverList.text = [[[ShareData sharedShareData] userObj] classObj].className;
        lbDateTime.text = @"";
        [textViewPost setFont:[UIFont systemFontOfSize:15]];
        
        UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
        
        self.navigationItem.leftBarButtonItems = @[btnCancel];
        
        UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(btnSendClick)];

        self.navigationItem.rightBarButtonItem = postBarBtn;
        
        [textViewTitle becomeFirstResponder];
        
      /*  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];*/
    }
    
    if (_announcementObject.importanceType == AnnouncementImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    //scroll content size
//    CGFloat height = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
//    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
//    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
    
    textViewPost.editable = !_isViewDetail;
    textViewTitle.userInteractionEnabled = !_isViewDetail;
    btnCamera.enabled = !_isViewDetail;
    
    if (_isViewDetail) {
        for (PhotoObject *photoObj in _announcementObject.imgArray) {
            [self addImageToDetailView:photoObj];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidAppear:(BOOL)animated {
//    //scroll content size
//    CGFloat height = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
//    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
//    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)cancelButtonClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return TRUE;
}

- (IBAction)tapGestureHandle:(id)sender {
    [self dismissKeyboard];
}
- (IBAction)swipeGestureHandle:(id)sender {
    [self dismissKeyboard];
}

- (void)dismissKeyboard {
    [textViewPost resignFirstResponder];
    [textViewTitle resignFirstResponder];
    
    for (CustomImageView *view in imageViewArray) {
        [view.txtCaption resignFirstResponder];
    }

}

- (IBAction)btnPriorityFlagClick:(id)sender {
    if (_announcementObject.importanceType == AnnouncementImportanceNormal) {
        _announcementObject.importanceType = AnnouncementImportanceHigh;
        if (_isViewDetail) {
            [[CoreDataUtil sharedCoreDataUtil] updateAnnouncementImportance:_announcementObject.announcementID withFlag:YES];
            [requestToServer updateAnnouncementImportance:_announcementObject.announcementID withFlag:YES];
        }
        
    } else {
        _announcementObject.importanceType = AnnouncementImportanceNormal;
        if (_isViewDetail) {
            [[CoreDataUtil sharedCoreDataUtil] updateAnnouncementImportance:_announcementObject.announcementID withFlag:NO];
            [requestToServer updateAnnouncementImportance:_announcementObject.announcementID withFlag:NO];
        }
    }
    
    if (_announcementObject.importanceType == AnnouncementImportanceHigh) {
        [btnImportanceFlag setTintColor:HIGH_IMPORTANCE_COLOR];
        
    } else {
        [btnImportanceFlag setTintColor:NORMAL_IMPORTANCE_COLOR];
    }
    
    if (_isViewDetail) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshAnnouncementAfterUpdateFlag" object:_announcementObject];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissKeyboard];
}

#pragma mark - keyboard movements
/*
- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = toolbar.frame;
        rect.origin.y = self.view.frame.size.height - (rect.size.height +                                                                                                                      keyboardSize.height);
        toolbar.frame = rect;
    }];
}

-(void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = toolbar.frame;
        rect.origin.y = self.view.frame.size.height - rect.size.height;
        toolbar.frame = rect;
    }];
}*/

#pragma mark text view delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    if ([textField isEqual:textViewTitle]) {
        [textViewPost becomeFirstResponder];
        
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //set placeholder, because it's not support by default
//    if ([textView isEqual:textViewTitle]) {
//        if ([textView.text isEqualToString:PLACEHOLDER_SUBJECT]) {
//            textView.text = @"";
//            textView.textColor = [UIColor blackColor]; //optional
//        }
//        
//    } else if ([textView isEqual:textViewPost]) {
//        if ([textView.text isEqualToString:PLACEHOLDER_CONTENT]) {
//            textView.text = @"";
//            textView.textColor = [UIColor blackColor]; //optional
//        }
//    }
//    
//    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
//    if ([textView isEqual:textViewTitle]) {
//        if ([textView.text isEqualToString:@""]) {
//            textView.text = PLACEHOLDER_SUBJECT;
//            textView.textColor = [UIColor lightGrayColor]; //optional
//        }
//        
//    } else if ([textView isEqual:textViewPost]) {
//        if ([textView.text isEqualToString:@""]) {
//            textView.text = PLACEHOLDER_CONTENT;
//            textView.textColor = [UIColor lightGrayColor]; //optional
//        }
//    }
//    
//    [textView resignFirstResponder];
    
    //need scroll to this textview -> do this if have time
}

#pragma mark toolbar handle
- (IBAction)photoHandle:(id)sender {
    [self dismissKeyboard];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:LocalizedString(@"Select photo source") delegate:(id)self cancelButtonTitle:LocalizedString(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:LocalizedString(@"Camera"), LocalizedString(@"Photo library"), nil];
    
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

#pragma mark action sheet delegate
- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
     if (actionSheet.tag == 1) {  //photo source
         dispatch_queue_t taskQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
         dispatch_async(taskQ, ^{
             
             dispatch_sync(dispatch_get_main_queue(), ^{
                if (buttonIndex == 0) {
                    NSLog(@"Camera");
                    if ([photoArray count] < IMAGE_LIMIT_NUMBER) {
                        if ([UIImagePickerController isSourceTypeAvailable:
                             UIImagePickerControllerSourceTypeCamera] == NO) {
                            
                            return;
                        }
                        
                        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
                        controller.delegate = (id)self;
                        [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
                        [self presentViewController:controller animated:YES completion:nil];
                        
                    } else {
                        [self showAlertOverLimitation];
                    }
                    
                } else if (buttonIndex == 1) {
                    NSLog(@"Library");
                    if ([photoArray count] < IMAGE_LIMIT_NUMBER) {
                        if ([UIImagePickerController isSourceTypeAvailable:
                             UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
                            
                            return;
                        }
            /*
                        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                // init picker
                                CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                                
                                // set delegate
                                picker.delegate = (id)self;
                                
                                // create options for fetching photo only
                                PHFetchOptions *fetchOptions = [PHFetchOptions new];
                                fetchOptions.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                                fetchOptions.includeAssetSourceTypes = PHAssetSourceTypeUserLibrary;
                                
                                // assign options
                                picker.assetsFetchOptions = fetchOptions;
                                
                                // to show selection order
                                picker.showsSelectionIndex = YES;
                                
                                // to present picker as a form sheet in iPad
                                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                                    picker.modalPresentationStyle = UIModalPresentationFormSheet;
                                
                                // present picker
                                [self presentViewController:picker animated:YES completion:nil];
                                
                            });
                        }];
             */
                        UIImagePickerController* controller = [[UIImagePickerController alloc] init];
                        controller.delegate = (id)self;
                        [controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                        [self presentViewController:controller animated:YES completion:nil];
                        
                    } else {
                        [self showAlertOverLimitation];
                    }
                    
                } else if (buttonIndex == 2) {
                    NSLog(@"Cancel");
                }
             });
         });
    }
}

// implement should select asset delegate
- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset
{
    NSInteger max = IMAGE_LIMIT_NUMBER;
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:LocalizedString(@"Attention")
                                            message:[NSString stringWithFormat:LocalizedString(@"You have reached to the limitation. Only allow %ld photos."), (long)max]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:LocalizedString(@"OK")
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alert addAction:action];
        
        [picker presentViewController:alert animated:YES completion:nil];
    }
    
    // limit selection to max
    return (picker.selectedAssets.count < max);
}

#pragma mark - Assets Picker Delegate

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    // Dismiss the picker controller.
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self removeAllPhoto];
    
    if (assets.count == 0) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    for (PHAsset *asset in assets) {

        PHImageManager *manager = [PHImageManager defaultManager];
        CGFloat scale = UIScreen.mainScreen.scale;
        CGSize targetSize = CGSizeMake(IMAGE_FILE_SIZE * scale, IMAGE_FILE_SIZE * scale);
        
        [manager requestImageForAsset:asset
                           targetSize:targetSize
                          contentMode:PHImageContentModeAspectFill
                              options:requestOptions
                        resultHandler:^(UIImage *image, NSDictionary *info){

                            if (image) {
                                [photoArray addObject:image];
                                
                                [self addImageToList:image];
                            }
                            
                        }];
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* image = [info objectForKey: UIImagePickerControllerOriginalImage];
    image = [[Common sharedCommon] scaleAndRotateImage:image withMaxSize:IMAGE_FILE_SIZE];
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    if ([photoArray count] < IMAGE_LIMIT_NUMBER) {
        [photoArray addObject:image];
        
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        [self addImageToList:image];
        
    } else {
        [picker dismissViewControllerAnimated:YES completion:^(void) {
            [self showAlertOverLimitation];
        }];
    }
}

- (void)removeAllPhoto {
    [photoArray removeAllObjects];
    
    //remove old subview
    for (UIView *view in imageViewArray) {
        [view removeFromSuperview];
    }
    
    [imageViewArray removeAllObjects];
}

#pragma mark custom image delegate
- (void)cancelBtnClick:(NSInteger)tag {
    UIView *imageView = [imageViewArray objectAtIndex:tag];
    
    [imageView removeFromSuperview];
    
    [photoArray removeObjectAtIndex:tag];
    [self displayImageList];
}

- (void)displayImageList {
    //remove old subview
    for (UIView *view in imageViewArray) {
        [view removeFromSuperview];
    }
    
    [imageViewArray removeAllObjects];
    
    //re add
    for (UIImage *image in photoArray) {
        CGFloat y = textViewTitle.frame.origin.y + textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET * 2;
        y = y + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
        CGRect rect = CGRectMake(IMAGE_VIEW_OFFSET, y, self.view.frame.size.width - IMAGE_VIEW_OFFSET*2, IMAGE_VIEW_HEIGHT);
        
        CustomImageView * customImageView = [[CustomImageView alloc] initWithFrame:rect];
        
        [customImageView.imageView setImage:image];
        customImageView.tag = [imageViewArray count];
        customImageView.delegate = (id)self;
        
        [imageViewArray addObject:customImageView];
        [mainScrollView addSubview:customImageView];
    }
    
    //scroll content size
    CGFloat height = textViewTitle.frame.origin.y + textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET * 2;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
}

- (void)addImageToList:(UIImage *)image {
    CGFloat y = textViewTitle.frame.origin.y + textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET * 2;
    y = y + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
    CGRect rect = CGRectMake(IMAGE_VIEW_OFFSET, y, self.view.frame.size.width - IMAGE_VIEW_OFFSET*2, IMAGE_VIEW_HEIGHT);
    
    CustomImageView * customImageView = [[CustomImageView alloc] initWithFrame:rect];
    
    [customImageView.imageView setImage:image];
    customImageView.tag = [imageViewArray count];
    customImageView.delegate = (id)self;
    
    [imageViewArray addObject:customImageView];
    [mainScrollView addSubview:customImageView];
    
    //scroll content size
    CGFloat height = textViewTitle.frame.origin.y + textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET * 2;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
}

- (void)addImageToDetailView:(PhotoObject *)photo {
    CGFloat y = textViewTitle.frame.origin.y + textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET * 2;
    y = y + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
    CGRect rect = CGRectMake(IMAGE_VIEW_OFFSET, y, mainScrollView.frame.size.width - IMAGE_VIEW_OFFSET*2, IMAGE_VIEW_HEIGHT);
    
    CustomImageView * customImageView = [[CustomImageView alloc] initWithFrame:rect];
    customImageView.isViewDetail = _isViewDetail;
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:customImageView.imageView];
    
    //load the image
    NSString *fullPath = [[ArchiveHelper sharedArchiveHelper] getPhotoFullPath:[photo.filePath lastPathComponent]];
    NSURL *url = [NSURL URLWithString:photo.filePath];
    
    if ([[ArchiveHelper sharedArchiveHelper] checkFileExist:fullPath]) {
        [customImageView.imageView setImage:[UIImage imageWithContentsOfFile:fullPath]];
        
    } else {
        customImageView.imageView.imageURL = url;
    }

    customImageView.txtCaption.text = photo.caption;
    customImageView.tag = [imageViewArray count];
    customImageView.delegate = (id)self;
    
    [imageViewArray addObject:customImageView];
    [mainScrollView addSubview:customImageView];
    
    //scroll content size
    CGFloat height = textViewTitle.frame.origin.y + textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET * 2;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
}

#pragma mark post
//return NO if not valid
- (BOOL)validateInputs {
    BOOL res = YES;
    
    NSString *subject = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:textViewTitle.text];
    NSString *content = [[Common sharedCommon] stringByRemovingSpaceAndNewLineSymbol:textViewPost.text];
    
    if (subject.length == 0 || content.length == 0) {
        //show alert invalid
        res = NO;
    }
    
    return res;
}

- (void)btnSendClick {
    if ([self validateInputs]) {
        if ([photoArray count] == 0) {
            [self showAlertNoImageAttached];
            
        } else {
            [self confirmBeforeSendingAnnouncement];
        }
        
    } else {
        [self showAlertInvalidInputs];
    }
}

- (void)sendNewAnnouncement {
    [SVProgressHUD showWithStatus:LocalizedString(@"Uploading...")];
    NSString *requestString = [NSString stringWithFormat:@"%@%@", SERVER_PATH, API_NAME_CREATE_ANNOUNCEMENT];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    [request setValue:[self getAPIKey] forHTTPHeaderField:@"api_key"];
    [request setValue:[[ArchiveHelper sharedArchiveHelper] loadAuthKey] forHTTPHeaderField:@"auth_key"];
    
    //—————————
    //    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *boundary = @"laosshool14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //adding content as a body to post
    
    NSMutableData *body = [NSMutableData data];
    
    //image files
    NSInteger order = 0;
    for (CustomImageView *view in imageViewArray) {
        order ++;
        
        //image
        NSData *imageData = UIImagePNGRepresentation(view.imageView.image);
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"tmp.jpg\"\r\n\r\n"]] dataUsingEncoding:NSUTF8StringEncoding]];
        
//        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[NSData dataWithData:[[NSData alloc] init]]];
        [body appendData:[NSData dataWithData:imageData]];
        
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        //caption
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"caption\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
 //       [body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"%@", [self encodeString:view.txtCaption.text]] dataUsingEncoding:NSUTF8StringEncoding]];

        //order
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"order\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
 //       [body appendData:[@"Content-Type: text/plain\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        
        [body appendData:[[NSString stringWithFormat:@"%ld", (long)order] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    //post json_in_string
    /*{ "school_id": 1,  "class_id":1, "content": "thong bao thong bao",  "title": "Xin chao phu huynh hoc sinh lop 5A5","dest_type":"1"}
     */
    NSMutableDictionary *jsonDict = [[NSMutableDictionary alloc] init];
    UserObject *userObj = [[ShareData sharedShareData] userObj];
    ClassObject *classObj = userObj.classObj;
    
    [jsonDict setValue:userObj.shoolID forKey:@"school_id"];
    [jsonDict setValue:classObj.classID forKey:@"class_id"];
    [jsonDict setValue:[self encodeString:textViewPost.text] forKey:@"content"];
    [jsonDict setValue:[self encodeString:textViewTitle.text] forKey:@"title"];
    [jsonDict setValue:@"1" forKey:@"dest_type"];
    
    if (_announcementObject.importanceType == AnnouncementImportanceHigh) {
        [jsonDict setObject:[NSNumber numberWithInteger:1] forKey:@"imp_flg"];
        
    } else {
        [jsonDict setObject:[NSNumber numberWithInteger:0] forKey:@"imp_flg"];
    }
    
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self insertParameterToBody:body paramKey:@"json_in_string" paramValue:myString withBoundary:boundary];
    
//    NSString* test = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//    NSLog(@"test ::: %@", test);
    
    //finish
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [connection start];
    
    [FIRAnalytics logEventWithName:@"sent_announcement" parameters:@{
                                                                              kFIRParameterValue:@(1)
                                                                              }];
}

- (void)insertParameterToBody:(NSMutableData *)body paramKey:(NSString *)key paramValue:(NSString *)value withBoundary:(NSString *)boundary {

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
//    [body appendData:[@"Content-Type: text/plain\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
 //   [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response
{
    responseData = [[NSMutableData alloc] init];
    switch (response.statusCode) {
        case HttpOK:
            
            break;
            
        case BadCredentials:
            [self loginWithWrongUserPassword];
            break;
            
        case NonAuthen:
            [self accountLoginByOtherDevice];
            break;
            
        default:
            
            NSLog(@"error code ::  %ld", (long)response.statusCode);
            [self sendPostRequestFailedWithUnknownError];
            break;
            
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (data) {
        [responseData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [SVProgressHUD dismiss];
    NSError *error;
    NSDictionary *jsonObj = nil;
    if (responseData) {
        
        jsonObj = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        
        if (error == nil && [jsonObj count] > 0) {
            [self receivedData:jsonObj];
            
        } else {
            [self sendAnnouncementFailed];
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)inError
{
    NSLog(@"didFailWithError :: %@", [inError description]);
    [SVProgressHUD dismiss];
    [self failToConnectToServer];
}

- (NSString *)getAPIKey {
    NSString *apiKey = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return apiKey;
}

- (void)failToConnectToServer {
    [self showAlertFailedToConnectToServer];
}

- (void)sendPostRequestFailedWithUnknownError {
    [SVProgressHUD dismiss];
}

- (void)loginWithWrongUserPassword {
    
}

- (void)accountLoginByOtherDevice {
    [SVProgressHUD dismiss];
    [self showAlertAccountLoginByOtherDevice];
}

- (void)receivedData:(NSDictionary *)jsonObj {
    NSInteger statusCode = [[jsonObj valueForKey:@"httpStatus"] integerValue];
    
    if (statusCode == HttpOK) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"SentNewAnnouncement" object:nil];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^(void) {
            [SVProgressHUD showSuccessWithStatus:@"Sent"];
        }];
        
    } else {
        [self sendAnnouncementFailed];
        
        
    }
}

- (void)showAlertAccountLoginByOtherDevice {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"This account was being logged in by other device. Please re-login.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 1;
    
    [alert show];
}

- (void)sendAnnouncementFailed {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There was an error while sending announcement. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 2;
    
    [alert show];
}

- (void)showAlertFailedToConnectToServer {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Failed") message:LocalizedString(@"Failed to connect to server. Please try again.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 3;
    
    [alert show];
}

- (void)confirmBeforeSendingAnnouncement {
    NSString *content = [NSString stringWithFormat:LocalizedString(@"Send this announcement to class %@. Are you sure?"), [ShareData sharedShareData].userObj.classObj.className];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Confirmation") message:content delegate:(id)self cancelButtonTitle:LocalizedString(@"No") otherButtonTitles:LocalizedString(@"Yes"), nil];
    alert.tag = 4;
    
    [alert show];
}

- (void)showAlertInvalidInputs {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"Please enter subject and content!") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 5;
    
    [alert show];
}

- (void)showAlertNoImageAttached {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LocalizedString(@"Error") message:LocalizedString(@"There is no image attached. Please attach at least one.") delegate:(id)self cancelButtonTitle:LocalizedString(@"OK") otherButtonTitles:nil];
    alert.tag = 6;
    
    [alert show];
}

- (void)showAlertOverLimitation {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:LocalizedString(@"Attention")
                                        message:[NSString stringWithFormat:LocalizedString(@"You have reached to the limitation. Only allow %ld photos."), (long)IMAGE_LIMIT_NUMBER]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action =
    [UIAlertAction actionWithTitle:LocalizedString(@"OK")
                             style:UIAlertActionStyleDefault
                           handler:nil];
    
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (alertView.tag == 4) {    //confirmBeforeSendingAnnouncement
        if (buttonIndex != 0) {
            if ([[Common sharedCommon]networkIsActive]) {
                [self sendNewAnnouncement];
            } else {
                [[CommonAlert sharedCommonAlert] showNoConnnectionAlert];
            }
        }
    }
}

- (void)tapOnImage:(id)sender {
 /*   FSBasicImage *firstPhoto = [[FSBasicImage alloc] initWithImageURL:[NSURL URLWithString:@"http://farm8.staticflickr.com/7319/9668947331_3112b1fcca_b.jpg"] name:@"Photo by Brian Adamson"];
    
    FSBasicImageSource *photoSource = [[FSBasicImageSource alloc] initWithImages:@[firstPhoto]];
    self.imageViewController = [[FSImageViewerViewController alloc] initWithImageSource:photoSource];
    
    _imageViewController.delegate = self;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_imageViewController];

    [self.navigationController presentViewController:navigationController animated:YES completion:nil];*/
    // Create image info
    CustomImageView *imageView = (CustomImageView *)sender;
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = imageView.imageView.image;
    CGRect rect = imageView.frame;
    rect.origin.y = rect.origin.y - 44;
    imageInfo.referenceRect = rect;
    imageInfo.referenceView = imageView.superview;
    imageInfo.referenceContentMode = imageView.contentMode;
    imageInfo.referenceCornerRadius = imageView.layer.cornerRadius;
    
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    // Present the view controller.
    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
    
}

- (void)imageViewerViewController:(FSImageViewerViewController *)imageViewerViewController didMoveToImageAtIndex:(NSInteger)index {
    NSLog(@"FSImageViewerViewController: %@ didMoveToImageAtIndex: %li",imageViewerViewController, (long)index);
}

- (NSString *)encodeString:(NSString *)myString {
    NSString *uniText = [NSString stringWithUTF8String:[myString UTF8String]];
    
    NSData *data = [uniText dataUsingEncoding:NSNonLossyASCIIStringEncoding];
    
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return str;
}

@end
