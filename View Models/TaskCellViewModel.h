//
//  TaskCellViewModel.h
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/21/13.
//  Copyright (c) 2013, Sierra Bravo Corp., dba The Nerdery
//

#import <Foundation/Foundation.h>

@class Task;

@interface TaskCellViewModel : NSObject

@property (nonatomic, strong) Task *task;
@property (weak, nonatomic, readonly) NSAttributedString *attributedText;
@property (weak, nonatomic, readonly) NSString *ageText;
@property (weak, nonatomic, readonly) NSString *priorityText;
@property (weak, nonatomic, readonly) UIColor *priorityColor;
@property (nonatomic, readonly) BOOL shouldShowDate;

@end
