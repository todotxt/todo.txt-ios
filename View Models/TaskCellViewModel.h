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
@property (nonatomic, readonly) NSAttributedString *attributedText;
@property (nonatomic, readonly) NSString *ageText;
@property (nonatomic, readonly) NSString *priorityText;
@property (nonatomic, readonly) UIColor *priorityColor;
@property (nonatomic, readonly) BOOL shouldShowDate;

@end
