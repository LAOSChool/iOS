//
//  AttendanceCellData.h
//  LazzyBee
//
//  Created by HuKhong on 3/31/15.
//  Copyright (c) 2015 HuKhong. All rights reserved.
//


#ifndef LazzyBee_AttendanceCellData_h
#define LazzyBee_AttendanceCellData_h

#import <UIKit/UIKit.h>

//#define QUEUE_UNKNOWN 0
typedef enum {
    CellType_Normal = 0,
    CellType_Detail,
    CellType_Max
} CELL_TYPE;

@interface AttendanceCellData : NSObject
{
    
}

@property (nonatomic, assign) CELL_TYPE cellType;
@property (nonatomic, strong) NSObject *cellData;
@property (nonatomic, assign) BOOL isShowDetail;

@end

#endif
