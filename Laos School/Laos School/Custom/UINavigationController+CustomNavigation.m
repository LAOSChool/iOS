//
//  UINavigationController+CustomNavigation.m
//  Laos School
//
//  Created by HuKhong on 3/2/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import "UINavigationController+CustomNavigation.h"
#import "CommonDefine.h"

@implementation UINavigationController (CustomNavigation)


- (void)setNavigationColor {
    [self.navigationBar setTranslucent:NO];
    [self.navigationBar setBarTintColor:BLUE_COLOR];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [self.navigationBar setTintColor:[UIColor whiteColor]];
}
@end
