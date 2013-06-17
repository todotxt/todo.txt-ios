//
//  TaskCell.h
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/16/13.
//
//

#import <UIKit/UIKit.h>

@class Task;

@interface TaskCell : UITableViewCell

@property (nonatomic, retain) Task *task;

@end
