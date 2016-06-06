//
//  StudentsListTableViewCell.h
//  Laos School
//
//  Created by HuKhong on 3/15/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "AsyncImageView.h"

@interface StudentsListTableViewCell : MGSwipeTableCell
{
    
}


@property (strong, nonatomic) IBOutlet AsyncImageView *imgAvatar;

@property (strong, nonatomic) IBOutlet UILabel *lbFullname;
@property (strong, nonatomic) IBOutlet UILabel *lbAdditionalInfo;
@property (strong, nonatomic) IBOutlet UILabel *lbNoreason;
@property (strong, nonatomic) IBOutlet UILabel *lbGender;

@end
