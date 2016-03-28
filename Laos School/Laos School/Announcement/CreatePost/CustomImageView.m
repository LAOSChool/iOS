//
//  CustomImageView.m
//  Born2Go
//
//  Created by itpro on 5/13/15.
//  Copyright (c) 2015 born2go. All rights reserved.
//

#import "CustomImageView.h"

@implementation CustomImageView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [[NSBundle mainBundle] loadNibNamed:@"CustomImageView" owner:self options:nil];
        CGRect rect = self.view.frame;
        rect.size.height = frame.size.height;
        rect.size.width = frame.size.width;
        [self.view setFrame:rect];
        
        [self addSubview:self.view];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [[NSBundle mainBundle] loadNibNamed:@"CustomImageView" owner:self options:nil];
    [self addSubview:self.view];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)cancelBtnClick:(id)sender {
    [self.delegate cancelBtnClick:self.tag];
}

- (void)setIsViewDetail:(BOOL)isViewDetail {
    _isViewDetail = isViewDetail;
    if (_isViewDetail) {
        _txtCaption.enabled = NO;
        _btnClose.enabled = NO;
    } else {
        _txtCaption.enabled = YES;
        _btnClose.enabled = YES;
    }
}
@end
