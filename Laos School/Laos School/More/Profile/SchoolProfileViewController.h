//
//  SchoolProfileViewController.h
//  Laos School
//
//  Created by HuKhong on 3/9/16.
//  Copyright © 2016 com.born2go.laosschool. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolProfileViewController : UIViewController
{
    
    IBOutlet UIView *viewTerm;
    IBOutlet UIView *viewHeaderContainer;
    IBOutlet UIView *viewMainContainer;
    
    IBOutlet UILabel *lbClass;
    IBOutlet UILabel *lbTermOne;
    IBOutlet UILabel *lbTermTwo;
    IBOutlet UILabel *lbAllYear;
    IBOutlet UIButton *btnMoreInfo;
    
    IBOutlet UILabel *lbSchoolYear;
    
    IBOutlet UILabel *lbClassValue;
    IBOutlet UILabel *lbAverage1Value;
    IBOutlet UILabel *lbAverage2Value;
    IBOutlet UILabel *lbAverageYearValue;

    IBOutlet UILabel *lbAverage1;
    IBOutlet UILabel *lbAverage2;
    IBOutlet UILabel *lbAverageYear;
        
}
@end
