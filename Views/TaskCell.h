//
//  TaskCell.h
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/16/13.
//  Copyright (c) 2013, Sierra Bravo Corp., dba The Nerdery
//

#import <UIKit/UIKit.h>

@class RACDisposable;
@class Task;
@class TaskCellViewModel;

@interface TaskCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *priorityLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UITextView *taskTextView;

@property (nonatomic) BOOL shouldShowDate;

// Hang on to the view model, so the managing table view need not
@property (nonatomic, strong) TaskCellViewModel *viewModel;

// Hang on to some RACDisposables, so they may be manually
// disposed of later.
@property (nonatomic, strong) RACDisposable *textDisposable;
@property (nonatomic, strong) RACDisposable *ageDisposable;
@property (nonatomic, strong) RACDisposable *priorityDisposable;
@property (nonatomic, strong) RACDisposable *priorityColorDisposable;
@property (nonatomic, strong) RACDisposable *showDateDisposable;

+ (CGFloat)heightForTask:(Task *)task givenWidth:(CGFloat)width;

@end
