//
//  TaskCell.m
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/16/13.
//  Copyright (c) 2013, Sierra Bravo Corp., dba The Nerdery 
//

#import "TaskCell.h"

#import "Priority.h"
#import "Task.h"
#import "TaskCellViewModel.h"

#import <CoreText/CoreText.h>

static TaskCell *staticSizingCell;
static const CGFloat kMinHeight = 44;

@interface TaskCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTopSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelLeadingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTrailingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ageLabelHeight;
@property (nonatomic) CGFloat ageLabelInitialHeight;

+ (TaskCell *)sizingCell;

@end

@implementation TaskCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.taskTextView.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
    self.ageLabelInitialHeight = self.ageLabelHeight.constant;
    
    // Stop if staticSizingCell is nil, i.e. this is awakeFromNib
    // for the staticSizingCell.
    if (!staticSizingCell) {
        return;
    }
    
    // Move all constraints from the cell's view to the cell's contentView.
    // See http://stackoverflow.com/a/13893146/1610271
    for (NSLayoutConstraint *cellConstraint in self.constraints) {
        [self removeConstraint:cellConstraint];
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        NSLayoutConstraint* contentViewConstraint =
        [NSLayoutConstraint constraintWithItem:firstItem
                                     attribute:cellConstraint.firstAttribute
                                     relatedBy:cellConstraint.relation
                                        toItem:seccondItem
                                     attribute:cellConstraint.secondAttribute
                                    multiplier:cellConstraint.multiplier
                                      constant:cellConstraint.constant];
        [self.contentView addConstraint:contentViewConstraint];
    }
}

#pragma mark - Overridden getters/setters

- (void)setShouldShowDate:(BOOL)shouldShowDate
{
    CGFloat newAgeLabelHeight = 0;
    // Show the age of the task, if appropriate. If not, hide the age label.
	if (self.shouldShowDate) {
		self.ageLabel.hidden = NO;
        
        newAgeLabelHeight = self.ageLabelInitialHeight;
	} else {
		self.ageLabel.hidden = YES;
        
        newAgeLabelHeight = 0;
	}
    
    // Find the age label's height constraint and set its constant.
    // We can't just use the IBOutlet because the constraint it connects to
    // is removed in -awakeFromNib:
    for (NSLayoutConstraint *constraint in self.ageLabel.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = newAgeLabelHeight;
        }
    }
}

#pragma mark - Public class methods

// TODO: move me to another class, maybe the view model
+ (CGFloat)heightForTask:(Task *)task givenWidth:(CGFloat)width
{
    const CGFloat bottomSpaceReclaimed = task.relativeAge ? 0 : staticSizingCell.ageLabelHeight.constant;
    
    const CGFloat baseHeight = [self sizingCell].taskLabelTopSpace.constant + [self sizingCell].taskLabelBottomSpace.constant - bottomSpaceReclaimed;
    const CGFloat takenWidth = [self sizingCell].taskLabelLeadingSpace.constant + [self sizingCell].taskLabelTrailingSpace.constant;
    
    CGSize taskLabelSize = CGSizeMake(width - takenWidth, CGFLOAT_MAX);
    
    staticSizingCell.taskTextView.attributedText = [[NSAttributedString alloc] initWithString:task.text];
    CGRect rect = CGRectZero;
    rect.size = [staticSizingCell.taskTextView sizeThatFits:taskLabelSize];
    
    const CGFloat calculatedHeight = baseHeight + CGRectGetHeight(rect);
    
    return calculatedHeight > kMinHeight ? calculatedHeight : kMinHeight;
}


#pragma mark - Private class methods

+ (TaskCell *)sizingCell
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        staticSizingCell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TaskCell class])
                                                         owner:nil
                                                       options:nil][0];
    });
    
    return staticSizingCell;
}

@end
