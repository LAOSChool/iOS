//
//  UIView+CustomUIView.h
//  Laos School
//
//  Created by HuKhong on 2/23/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CustomUIView)

- (void)borderWidth:(float)width AndRound:(float)round;
- (void)borderWidth:(float)width AndRound:(float)round withColor:(UIColor *)color;
- (void)makeShadow;
@end
