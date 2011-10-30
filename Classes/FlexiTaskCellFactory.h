//
//  FlexiTaskCellFactory.h
//  todo.txt-touch-ios
//
//  Created by Ricky Hussmann on 10/30/11.
//  Copyright (c) 2011 LovelyRide. All rights reserved.
//

#import "FlexiTaskCell.h"

#import <Foundation/Foundation.h>

@interface FlexiTaskCellFactory : NSObject
+ (FlexiTaskCell*)cellForDeviceOrientation;
+ (NSString*)cellIDForDeviceOrientation;
@end
