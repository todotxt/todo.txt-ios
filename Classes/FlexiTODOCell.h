//
//  FlexiTODOCell.h
//  todo.txt-touch-ios
//
//  Created by Ricky Hussmann on 10/13/11.
//  Copyright (c) 2011 LovelyRide. All rights reserved.
//

#import "Task.h"
#import <UIKit/UIKit.h>

@interface FlexiTODOCell : UITableViewCell

// -(id)init is now the designated initializer

+ (CGFloat)heightForCellWithTask:(Task*)aTask;
+ (NSString*)cellId;

@property (readwrite, retain) Task* task;

@end
