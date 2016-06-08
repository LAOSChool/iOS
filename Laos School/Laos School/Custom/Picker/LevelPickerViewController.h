//
//  LevelPickerViewController.h
//  LazzyBee
//
//  Created by HuKhong on 10/2/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DataPickerViewDelegate <NSObject>

@optional // Delegate protocols

- (void)btnDoneClick:(id)sender withObjectReturned:(id)returnedObj;

@end

typedef enum {
    Picker_Terms = 0,
    Picker_Classes,
    Picker_Subject,
    Picker_Section,
    PickerTypeMax
} PICKER_TYPE;

@interface LevelPickerViewController : UIViewController
{
    IBOutlet UIPickerView *levelPicker;
    IBOutlet UIButton *btnDone;
    
}

@property (nonatomic, assign) PICKER_TYPE pickerType;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) id selectedItem;

@property(nonatomic, readwrite) id <DataPickerViewDelegate> delegate;

@end
