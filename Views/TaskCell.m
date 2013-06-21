/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Brendon Justin <bjustin@nerdery.com>
 * @copyright 2013 Sierra Bravo Corp., dba The Nerdery (http://nerdery.com)
 *
 * Dual-licensed under the GNU General Public License and the MIT License
 *
 * @license GNU General Public License http://www.gnu.org/licenses/gpl.html
 *
 * Todo.txt Touch is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any
 * later version.
 *
 * Todo.txt Touch is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with Todo.txt Touch.  If not, see
 * <http://www.gnu.org/licenses/>.
 *
 *
 * @license The MIT License http://www.opensource.org/licenses/mit-license.php
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

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
