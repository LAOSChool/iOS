//
//  common.m
//  LaosSchool
//
//  Created by HuKhong on 3/3/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Common.h"
#import "Reachability.h"
#import <AVFoundation/AVFoundation.h>

@import MessageUI;

@implementation Common

- (id)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}


+(Common *)sharedCommon {
    static Common *sharedCommon = nil;
    if (!sharedCommon) {
        sharedCommon = [[super allocWithZone:nil] init];
    }
    return sharedCommon;
}

+(id)allocWithZone:(NSZone *)zone {
    return [self sharedCommon];
}

- (NSString *)parsePhoneType:(NSString *)phoneType {
    NSString *res = @"";
    NSRange first = [phoneType rangeOfString:@"<"];
    NSRange last = [phoneType rangeOfString:@">"];
    NSRange range;
    
    if (first.location != NSNotFound && last.location != NSNotFound) {
        range.location = first.location + 1;
        range.length = last.location - first.location -1;
        res = [phoneType substringWithRange:range];
    } else {
        res = phoneType;
    }

    return res;
}

- (NSString *)addPrefixToPhoneNumber:(NSString *)phoneNumber {
    if (phoneNumber.length > 0) {
        NSString *phoneWithPrefix = phoneNumber;
        phoneWithPrefix = [[phoneWithPrefix componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
        if (phoneWithPrefix.length > 0) {
//            phoneWithPrefix = [PHONE_PREFIX stringByAppendingString:phoneWithPrefix];
        } else {
            phoneWithPrefix = @"";
        }
        
        return phoneWithPrefix;
        
    } else {
        return @"";
    }
}

- (BOOL) networkIsActive {
    //Attempt to connect to sample host using Reachability
    Reachability* reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    
    //Check remoteHostStatus
    if(remoteHostStatus == NotReachable)
    {
        NSLog(@"Host not reachable");
        return NO;
    }
    else if (remoteHostStatus == ReachableViaWWAN)
    {
        NSLog(@"Host reachable via wwan");
        return YES;
    }
    else if (remoteHostStatus == ReachableViaWiFi)
    {
        NSLog(@"Host reachable via wifi");
        return YES;
    }
    return NO;
}

- (BOOL) isUsingWifi {
    //Attempt to connect to sample host using Reachability
//    Reachability* reachability = [Reachability reachabilityWithHostName:@"www.google.com"];
//    Reachability *reachability = [Reachability reachabilityForInternetConnection];
//    [reachability startNotifier];
//    
//    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
//    
//    //Check remoteHostStatus
//    if(remoteHostStatus == NotReachable)
//    {
//        NSLog(@"Host not reachable");
//        return YES;
//    }
//    else if (remoteHostStatus == ReachableViaWWAN)
//    {
//        NSLog(@"Host reachable via wwan");
//        return NO;
//    }
//    else if (remoteHostStatus == ReachableViaWiFi)
//    {
//        NSLog(@"Host reachable via wifi");
//        return YES;
//    }
//    return YES;
/*    BOOL res = YES;
    NSArray *subviews = [[[[UIApplication sharedApplication] valueForKey:@"statusBar"] valueForKey:@"foregroundView"]subviews];
    NSNumber *dataNetworkItemView = nil;
    
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    switch ([[dataNetworkItemView valueForKey:@"dataNetworkType"]integerValue]) {
        case 0:
            NSLog(@"No wifi or cellular");
            break;
            
        case 1:
            NSLog(@"2G");
            res = NO;
            break;
            
        case 2:
            NSLog(@"3G");
            res = NO;
            break;
            
        case 3:
            NSLog(@"4G");
            res = NO;
            break;
            
        case 4:
            NSLog(@"LTE");
            res = NO;
            break;
            
        case 5:
            NSLog(@"Wifi");
            res = YES;
            break;
            
        default:
            break;
    };
*/    
    return NO;
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients viewController:(id)viewController {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    
    if([MFMessageComposeViewController canSendText])
    {
        controller.body = bodyOfMessage;
        controller.recipients = recipients;
        controller.messageComposeDelegate = (id)viewController;
        [viewController presentViewController:controller animated:YES completion:nil];
    }
}

- (NSString *)encodeURL:(NSString *)unencodedURL {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)unencodedURL,
                                                                                  NULL,
                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                  kCFStringEncodingUTF8 ));
    
    return encodedString;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image withMaxSize:(int)kMaxResolution {
//    int kMaxResolution = 960; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}

-(UIImage *)imageFromText:(NSString *)text {
    // set the font type and size
    UIFont *font = [UIFont systemFontOfSize:50.0];

    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:
                                @[font, [UIColor whiteColor]]
                                                           forKeys:
                                @[NSFontAttributeName, NSForegroundColorAttributeName]];
    
    CGSize size  = [text sizeWithAttributes:attributes];
    
    UIGraphicsBeginImageContext(size);

    [text drawAtPoint:CGPointMake(0.0, 0.0) withAttributes:attributes];
    
    // transfer image
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)createImageFromView:(UIView *)view {
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)validateEmailWithString:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (NSString *)hidePhoneNumber:(NSString *)phonenumber {
    NSString *res = phonenumber;
    NSRange range;
    range.length = 2;
    range.location = res.length - 5;
    res = [res stringByReplacingCharactersInRange:range withString:@"*"];
    
    return res;
}

- (NSString *) stringByRemovingHTMLTag:(NSString *)text {
    NSRange range;
    NSString *res = text;
    
    while ((range = [res rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        res = [res stringByReplacingCharactersInRange:range withString:@""];
    }
    return res;
}

- (NSString *)stringByRemovingSpaceAndNewLineSymbol:(NSString *)text {
    NSString *newText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return newText;
}

- (void)textToSpeech:(NSString *)text withRate:(float)rate {
    AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc]init];
    
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:text];

    [utterance setRate:rate];
    [synthesizer speakUtterance:utterance];
}


@end