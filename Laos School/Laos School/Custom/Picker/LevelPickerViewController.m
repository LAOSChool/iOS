//
//  LevelPickerViewController.m
//  LazzyBee
//
//  Created by HuKhong on 10/2/15.
//  Copyright © 2015 Born2go. All rights reserved.
//

#import "LevelPickerViewController.h"
#import "Common.h"
#import "SubjectObject.h"
#import "ScoreTypeObject.h"
#import "LocalizeHelper.h"

#define MAX_LEVEL 6
#define MAX_TIME 11

@interface LevelPickerViewController ()

@end

@implementation LevelPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [btnDone setTitle:LocalizedString(@"Done") forState:UIControlStateNormal];
    
    if (_selectedItem) {
        if (_pickerType == Picker_Subject ||
            _pickerType == Picker_ScoreType) {
            if ([_dataArray count] > 0) {
                NSInteger selectedRow = [_dataArray indexOfObject:_selectedItem];
                
                [levelPicker selectRow:selectedRow inComponent:0 animated:YES];
            }
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setSelectedItem:(id)selectedItem {
    if (selectedItem) {
        _selectedItem = selectedItem;
        
        if (_pickerType == Picker_Subject ||
            _pickerType == Picker_ScoreType) {
            if ([_dataArray count] > 0) {
                NSInteger selectedRow = [_dataArray indexOfObject:_selectedItem];
                
                [levelPicker selectRow:selectedRow inComponent:0 animated:YES];
            }
            
        }
    }
}

- (void)setDataArray:(NSArray *)dataArray {
    if (dataArray) {
        _dataArray = dataArray;
        
        [levelPicker reloadAllComponents];
    }
}

- (IBAction)tapGestureHandle:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

- (IBAction)btnDoneClick:(id)sender {
    [UIView animateWithDuration:0.3 animations:^(void) {
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
    
    if ([_dataArray count] > 0) {
        NSInteger selectedRow = [levelPicker selectedRowInComponent:0];
        
        if (_pickerType == Picker_Subject) {
            SubjectObject *subObj = [_dataArray objectAtIndex:selectedRow];
            [self.delegate btnDoneClick:self withObjectReturned:subObj];
            
        } else if (_pickerType == Picker_ScoreType) {
            ScoreTypeObject *typeObj = [_dataArray objectAtIndex:selectedRow];
            [self.delegate btnDoneClick:self withObjectReturned:typeObj];
        }
        
    }
}

#pragma mark picker datasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_pickerType == Picker_Subject ||
        _pickerType == Picker_ScoreType) {
        if (_dataArray) {
            return [_dataArray count];
        }
        
        return 0;
    }
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (_pickerType == Picker_Subject) {
        SubjectObject *subObj = [_dataArray objectAtIndex:row];
        
        return subObj.subjectName;
        
    } else if (_pickerType == Picker_ScoreType) {
        ScoreTypeObject *typeObj = [_dataArray objectAtIndex:row];
        
        return typeObj.scoreName;
    }
    
    return @"";
}

#pragma mark picker delegate
- (void)pickerView:(UIPickerView *)pV didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
//    if (_dataArray) {
//        SubjectObject *subObj = [_dataArray objectAtIndex:row];
//        [self.delegate btnDoneClick:self withValueReturned:subObj.subjectID];
//    }
}
@end
