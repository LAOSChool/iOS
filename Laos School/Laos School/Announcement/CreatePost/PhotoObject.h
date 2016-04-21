//
//  PhotoObject.h
//  Born2Go
//
//  Created by itpro on 3/31/15.
//  Copyright (c) 2015 Born2Go. All rights reserved.
//


#ifndef Born2Go_PhotoObject_h
#define Born2Go_PhotoObject_h

#import <UIKit/UIKit.h>
@interface PhotoObject : NSObject
{
    
}

@property (nonatomic, assign) NSInteger photoID;
@property (nonatomic, assign) NSInteger order;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *filePath;


@end

#endif
