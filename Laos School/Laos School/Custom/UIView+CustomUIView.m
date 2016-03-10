//
//  UIView+CustomUIView.m
//  Laos School
//
//  Created by HuKhong on 2/23/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "UIView+CustomUIView.h"

@implementation UIView (CustomUIView)

- (void)borderWidth:(float)width AndRound:(float)round {
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.layer.borderWidth = width;
    
    self.layer.cornerRadius = round;
    self.clipsToBounds = YES;
}

- (void)borderWidth:(float)width AndRound:(float)round withColor:(UIColor *)color {
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = width;
    
    self.layer.cornerRadius = round;
    self.clipsToBounds = YES;
}

- (void)makeShadow {
    self.layer.masksToBounds = NO;
    self.layer.shadowOffset = CGSizeMake(20, 20);
    self.layer.shadowRadius = 15;
    self.layer.shadowOpacity = 0.3;
}
@end
