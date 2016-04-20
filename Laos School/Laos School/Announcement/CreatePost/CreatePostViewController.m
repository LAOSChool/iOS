//
//  CreatePostViewController.m
//  Born2Go
//
//  Created by itpro on 5/12/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import "CreatePostViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WSAssetPicker.h"
#import "Common.h"
#import "PhotoObject.h"
#import "CustomImageView.h"
#import "SVProgressHUD.h"
#import "LocalizeHelper.h"

#import "UINavigationController+CustomNavigation.h"

#define IMAGE_VIEW_HEIGHT 275
#define IMAGE_VIEW_OFFSET 8
#define IMAGE_KEYBOARD_OFFSET 250

#define IMAGE_LIMIT_NUMBER 10

@interface CreatePostViewController ()
{
    NSMutableArray *photoArray;
    NSMutableArray *imageViewArray;
}
@end


@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    [self.navigationController setNavigationColor];
    
    photoArray = [[NSMutableArray alloc] init];
    imageViewArray = [[NSMutableArray alloc] init];
    
    if (_isViewDetail) {
        [self setTitle:_announcementObject.subject];
        
        textViewTitle.text = _announcementObject.subject;
        textViewPost.text = _announcementObject.content;
        
        textViewPost.textColor = [UIColor blackColor];
        textViewTitle.textColor = [UIColor blackColor];
        
    } else {
        [self setTitle:LocalizedString(@"New Anouncement")];
        
        UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Cancel") style:UIBarButtonItemStyleDone target:(id)self  action:@selector(cancelButtonClick)];
        
        self.navigationItem.leftBarButtonItems = @[btnCancel];
        
        UIBarButtonItem *postBarBtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleDone target:(id)self action:@selector(sendRequestToGetPostLink)];
        self.navigationItem.rightBarButtonItem = postBarBtn;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    //scroll content size
    CGFloat height = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
    
    textViewPost.editable = !_isViewDetail;
    textViewTitle.editable = !_isViewDetail;
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
    [textViewPost resignFirstResponder];
    [textViewTitle resignFirstResponder];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [textViewPost resignFirstResponder];
    [textViewTitle resignFirstResponder];
}

#pragma mark - keyboard movements
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
}

#pragma mark text view delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    [textViewPost resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    //set placeholder, because it's not support by default
    if ([textView isEqual:textViewTitle]) {
        if ([textView.text isEqualToString:@"Post title"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor]; //optional
        }
        
    } else if ([textView isEqual:textViewPost]) {
        if ([textView.text isEqualToString:@"Post content"]) {
            textView.text = @"";
            textView.textColor = [UIColor blackColor]; //optional
        }
    }
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView isEqual:textViewTitle]) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Post title";
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
        
    } else if ([textView isEqual:textViewPost]) {
        if ([textView.text isEqualToString:@""]) {
            textView.text = @"Post content";
            textView.textColor = [UIColor lightGrayColor]; //optional
        }
    }
    
    [textView resignFirstResponder];
    
    //need scroll to this textview -> do this if have time
}

#pragma mark toolbar handle
- (IBAction)photoHandle:(id)sender {
    [textViewPost resignFirstResponder];
    [textViewTitle resignFirstResponder];
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select photo source" delegate:(id)self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera", @"Photo library", nil];
    
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

#pragma mark - WSAssetPickerControllerDelegate Methods

- (void)assetPickerControllerDidCancel:(WSAssetPickerController *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)assetPickerControllerDidLimitSelection:(WSAssetPickerController *)sender {
//    if ([TSMessage isNotificationActive] == NO) {
//        [TSMessage showNotificationInViewController:sender withTitle:@"Selection limit reached." withMessage:nil withType:TSMessageNotificationTypeWarning withDuration:2.0];
//    }
}

- (void)assetPickerController:(WSAssetPickerController *)sender didFinishPickingMediaWithAssets:(NSArray *)assets
{
    // Dismiss the picker controller.
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (assets.count == 0) {
            [self dismissViewControllerAnimated:YES completion:nil];
            return;
        }
        
        for (ALAsset *asset in assets) {
            
            UIImage *image = [[UIImage alloc] initWithCGImage:asset.defaultRepresentation.fullScreenImage];
            image = [[Common sharedCommon] scaleAndRotateImage:image withMaxSize:IMAGE_VIEW_HEIGHT];
            
            [photoArray addObject:image];
            
            [self addImageToList:image];
        }
    }];
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
            [controller setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self presentViewController:controller animated:YES completion:nil];
            
        } else if (buttonIndex == 1) {
            NSLog(@"Library");
            if ([UIImagePickerController isSourceTypeAvailable:
                 UIImagePickerControllerSourceTypePhotoLibrary] == NO) {
                
                return;
            }
        
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        
            WSAssetPickerController *picker = [[WSAssetPickerController alloc] initWithAssetsLibrary:library];
            picker.delegate = (id)self;
            [picker setSelectionLimit:IMAGE_LIMIT_NUMBER];
            
            [self presentViewController:picker animated:YES completion:nil];
            
        } else if (buttonIndex == 2) {
            NSLog(@"Cancel");
        }
    }
}

-(void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary*)info {
    UIImage* image = [info objectForKey: UIImagePickerControllerOriginalImage];
    image = [[Common sharedCommon] scaleAndRotateImage:image withMaxSize:IMAGE_VIEW_HEIGHT];
    
    [photoArray addObject:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self addImageToList:image];
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
        CGFloat y = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
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
    CGFloat height = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
}

- (void)addImageToList:(UIImage *)image {
    CGFloat y = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
    y = y + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
    CGRect rect = CGRectMake(IMAGE_VIEW_OFFSET, y, self.view.frame.size.width - IMAGE_VIEW_OFFSET*2, IMAGE_VIEW_HEIGHT);
    
    CustomImageView * customImageView = [[CustomImageView alloc] initWithFrame:rect];
    
    [customImageView.imageView setImage:image];
    customImageView.tag = [imageViewArray count];
    customImageView.delegate = (id)self;
    
    [imageViewArray addObject:customImageView];
    [mainScrollView addSubview:customImageView];
    
    //scroll content size
    CGFloat height = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count] + IMAGE_KEYBOARD_OFFSET;
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
}

- (void)addImageToDetailView:(PhotoObject *)photo {
    CGFloat y = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
    y = y + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
    CGRect rect = CGRectMake(IMAGE_VIEW_OFFSET, y, self.view.frame.size.width - IMAGE_VIEW_OFFSET*2, IMAGE_VIEW_HEIGHT);
    
    CustomImageView * customImageView = [[CustomImageView alloc] initWithFrame:rect];
    customImageView.isViewDetail = _isViewDetail;
    //cancel loading previous image for cell
    [[AsyncImageLoader sharedLoader] cancelLoadingImagesForTarget:customImageView.imageView];
    
    //load the image
    customImageView.imageView.imageURL = [NSURL URLWithString:photo.filePath];
    customImageView.txtCaption.text = photo.caption;
    customImageView.tag = [imageViewArray count];
    customImageView.delegate = (id)self;
    
    [imageViewArray addObject:customImageView];
    [mainScrollView addSubview:customImageView];
    
    //scroll content size
    CGFloat height = textViewTitle.frame.size.height + textViewPost.frame.size.height + IMAGE_VIEW_OFFSET *3;
    height = height + (IMAGE_VIEW_HEIGHT + IMAGE_VIEW_OFFSET) * [imageViewArray count];
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, height)];
}

#pragma mark post
- (void)sendRequestToGetPostLink {
//    [SVProgressHUD showWithStatus:LocalizedString(@"Uploading")];
    
    //for test
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//    NSString *reqest = REQUEST_POST_LINK;
//    
//    //for test
//    NSURL *url = [NSURL URLWithString:[@"http://192.168.0.116:8080/api?" stringByAppendingString:reqest]];
////    NSURL *url = [NSURL URLWithString:[SERVER_LINK stringByAppendingString:reqest]];
//    NSURLRequest *urlReq = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
//    
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    
//    [NSURLConnection sendAsynchronousRequest:urlReq queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//     {
//         dispatch_sync(dispatch_get_main_queue(), ^{
//             if (error == nil && data != nil) {
//                 [self didReceivePostLink:data];
//                 
//             } else {
//                 //                 [[CommonAlert sharedCommonAlert] showServerCommonErrorAlert];
//             }
//         });
//     }];
    
    
}
/*
- (void)didReceivePostLink:(NSData *)data {
    NSString* postLink = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //for test
    postLink = [postLink stringByReplacingOccurrencesOfString:@"VUQUANGHOA"
                                         withString:@"192.168.0.116"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:postLink]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    // Specify that it will be a POST request
    [request setHTTPMethod:@"POST"];
    //—————————
//    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *boundary = @"born2go14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    //adding content as a body to post
    
    NSMutableData *body = [NSMutableData data];
    
    //image files
    for (CustomImageView *view in imageViewArray) {
        NSData *imageData = UIImagePNGRepresentation(view.imageView.image);
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

        [body appendData:[[NSString stringWithString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", view.txtCaption.text]] dataUsingEncoding:NSUTF8StringEncoding]];

        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
    }
    
    //post title
    [self insertParameterToBody:body paramKey:@"title" paramValue:textViewTitle.text withBoundary:boundary];
    
    //post content
    [self insertParameterToBody:body paramKey:@"post_content" paramValue:textViewPost.text withBoundary:boundary];
    
    //trip_id
//    [self insertParameterToBody:body paramKey:@"trip_id" paramValue:_tripID withBoundary:boundary];
    //for test
    [self insertParameterToBody:body paramKey:@"trip_id" paramValue:@"4925812092436480" withBoundary:boundary];
   
    //access_token
    NSString *token = [[FBHelper sharedFBHelper] getAccessToken];
    [self insertParameterToBody:body paramKey:@"access_token" paramValue:token withBoundary:boundary];
    
    //date time
    NSTimeInterval datetime = [[Common sharedCommon] getCurrentDatetimeInMinisec];
    NSString *dateString = [NSString stringWithFormat:@"%.0f",datetime];

    [self insertParameterToBody:body paramKey:@"created_date" paramValue:dateString withBoundary:boundary];
    
    //finish
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
//    NSString* test = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
//    NSLog(@"test ::: %@", test);
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         dispatch_sync(dispatch_get_main_queue(), ^{
             [SVProgressHUD dismiss];
             if (error == nil && data != nil) {
                 [self didPostingResponse:data];
                 
             } else {
//                 [[CommonAlert sharedCommonAlert] showServerCommonErrorAlert];
             }
         });
     }];
}
*/
- (void)didPostingResponse:(NSData *)data {
    NSString *status = @"ok";
    NSString *err_msg = @"no error";
    
    NSString* test = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"test ::: %@", test);
    
    NSError *error;
    NSDictionary *jsonObj = nil;
    if (data) {
        jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        
        if (error == nil && [jsonObj count] > 0) {
            status = [jsonObj objectForKey:@"status"];
            err_msg = [jsonObj objectForKey:@"err_msg"];
            if (status && err_msg) {
                if ([[status lowercaseString] isEqualToString:@"ok"]) {
                    [self.navigationController popViewControllerAnimated:YES];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTrip" object:nil];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:err_msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    alert.tag = 1;
                    
                    [alert show];
                }
            }
        }
    }
}

- (void)insertParameterToBody:(NSMutableData *)body paramKey:(NSString *)key paramValue:(NSString *)value withBoundary:(NSString *)boundary {

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: text/plain\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    
 //   [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[[NSString stringWithFormat:@"%@", value] dataUsingEncoding:NSUTF8StringEncoding]];
}

@end
