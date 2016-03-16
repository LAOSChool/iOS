//
//  ReasonViewController.h
//  LazzyBee
//
//  Created by HuKhong on 6/4/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReasonViewController : UIViewController
{
    IBOutlet UILabel *lbTotalValue;
    IBOutlet UILabel *lbLevel1Value;
    IBOutlet UILabel *lbLevel2Value;
    IBOutlet UILabel *lbLevel3Value;
    IBOutlet UILabel *lbLevel4Value;
    IBOutlet UILabel *lbLevel5Value;
    IBOutlet UILabel *lbLevel6Value;
    IBOutlet UILabel *lbLevel7Value;

    IBOutlet UILabel *lbLevel7Title;
}

- (void)loadInformation;
@end
