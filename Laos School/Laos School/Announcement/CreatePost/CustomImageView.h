//
//  CustomImageView.h
//  Born2Go
//
//  Created by itpro on 5/13/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"
@protocol CustomImageViewDelegate <NSObject>

@optional // Delegate protocols

- (void)cancelBtnClick:(NSInteger)tag;

@end

@interface CustomImageView : UIView
{
    
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet AsyncImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *txtCaption;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;

@property(nonatomic, assign) BOOL isViewDetail;

@property(nonatomic, readwrite) id <CustomImageViewDelegate> delegate;

@end
