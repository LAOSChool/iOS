//
//  CustomTextField.m
//  MobileTV
//
//  Created by itpro on 5/19/15.
//  Copyright (c) 2015 itpro. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        self.layer.cornerRadius = 8.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0f;
        [self setLeftViewMode:UITextFieldViewModeAlways];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

- (void)setColor:(UIColor *)color andImage:(UIImage *)image {
    if (color) {
        self.layer.cornerRadius = 8.0f;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [color CGColor];
        self.layer.borderWidth = 1.0f;
    }
    
    [self setLeftViewMode:UITextFieldViewModeAlways];
    self.leftView= [[UIImageView alloc] initWithImage:image];
}

@end
