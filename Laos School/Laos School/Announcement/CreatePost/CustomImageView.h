//
//  CustomImageView.h
//  Born2Go
//
//  Created by itpro on 5/13/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CustomImageViewDelegate <NSObject>

@optional // Delegate protocols

- (void)cancelBtnClick:(NSInteger)tag;

@end

@interface CustomImageView : UIView
{
    
}

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) IBOutlet UITextField *txtCaption;
@property(nonatomic, readwrite) id <CustomImageViewDelegate> delegate;

@end
