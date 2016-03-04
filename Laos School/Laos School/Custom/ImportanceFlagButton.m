//
//  ImportanceFlagButton.m
//  MobileTV
//
//  Created by itpro on 5/19/15.
//  Copyright (c) 2015 itpro. All rights reserved.
//

#import "ImportanceFlagButton.h"

@implementation ImportanceFlagButton

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

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

- (void)setImportanceType:(IMPORTANCE_TYPE) importanceType {
    _importanceType = importanceType;
    
    if (_importanceType == ImportanceHight) {
        [self setTintColor:[UIColor redColor]];
        
    } else {
        [self setTintColor:[UIColor lightGrayColor]];
    }
    
}

@end
