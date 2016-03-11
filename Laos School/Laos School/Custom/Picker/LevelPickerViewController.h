//
//  LevelPickerViewController.h
//  LazzyBee
//
//  Created by HuKhong on 10/2/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    Picker_Terms = 0,
    Picker_Classes,
    Picker_Subject,
    PickerTypeMax
} PICKER_TYPE;

@interface LevelPickerViewController : UIViewController
{
    IBOutlet UIPickerView *levelPicker;
    IBOutlet UIButton *btnDone;
    
}

@property (nonatomic, assign) PICKER_TYPE pickerType;
@end
