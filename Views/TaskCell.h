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

@property (nonatomic, strong) Task *task;

+ (CGFloat)heightForTask:(Task *)task givenWidth:(CGFloat)width;
+ (NSAttributedString *)attributedTextForTask:(Task *)task;

@property (nonatomic) BOOL shouldShowDate;

@end
