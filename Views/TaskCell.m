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

#import <ReactiveCocoa/ReactiveCocoa.h>

static TaskCell *_staticSizingCell;
static const CGFloat kBigSpacing = 30;
static const CGFloat kSmallBoundsSpacing = 7;
static const CGFloat kSmallSpacing = 4;
static const CGFloat kAgeLabelWidth = 180;
static const CGFloat kAccessoryWidthEstimate = 20;

@interface TaskCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTopSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelLeadingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTrailingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ageLabelHeight;
@property (nonatomic, readonly) CGFloat labelHeight;

+ (TaskCell *)staticSizingCell;

@end

@implementation TaskCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _shouldShowDate = YES;
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        // Setup the content view
        UILabel *priorityLabel = [[UILabel alloc] init];
        UILabel *ageLabel = [[UILabel alloc] init];
        UITextView *textView = [[UITextView alloc] init];
        
        ageLabel.textColor = [UIColor blackColor];
        
        textView.contentInset = UIEdgeInsetsMake(0, -4, 0, -4);
        textView.userInteractionEnabled = NO;
        
        self.priorityLabel = priorityLabel;
        self.ageLabel = ageLabel;
        self.taskTextView = textView;
        
        [@[ priorityLabel, ageLabel, textView ] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
            view.backgroundColor = [UIColor clearColor];
            view.translatesAutoresizingMaskIntoConstraints = NO;
            [self.contentView addSubview:view];
        }];
        
        NSDictionary *metrics = @{ @"bigSpacing" : @(kBigSpacing),
                                   @"boundsSpacing" : @(kSmallBoundsSpacing),
                                   @"spacing" : @(kSmallSpacing),
                                   @"ageLabelWidth" : @(kAgeLabelWidth) };
        NSDictionary *bindings = NSDictionaryOfVariableBindings(priorityLabel, ageLabel, textView);
        NSArray *constraintArrays =
        @[
          [NSLayoutConstraint constraintsWithVisualFormat:@"|-(bigSpacing)-[textView]|"
                                                  options:0
                                                  metrics:metrics
                                                    views:bindings],
          [NSLayoutConstraint constraintsWithVisualFormat:@"[priorityLabel]-(spacing)-[textView]"
                                                  options:0
                                                  metrics:metrics
                                                    views:bindings],
          [NSLayoutConstraint constraintsWithVisualFormat:@"[ageLabel(==ageLabelWidth)]"
                                                  options:0
                                                  metrics:metrics
                                                    views:bindings],
          [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(boundsSpacing)-[priorityLabel]"
                                                  options:0
                                                  metrics:metrics
                                                    views:bindings],
          [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(boundsSpacing)-[textView]-(spacing)-[ageLabel]-(boundsSpacing)-|"
                                                  options:NSLayoutFormatAlignAllLeft
                                                  metrics:metrics
                                                    views:bindings],
          ];
        
        
        NSLayoutConstraint *priorityHeight = [NSLayoutConstraint constraintWithItem:priorityLabel
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:self.labelHeight];
        NSLayoutConstraint *ageHeight = [NSLayoutConstraint constraintWithItem:ageLabel
                                                                     attribute:NSLayoutAttributeHeight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                                    multiplier:1.0
                                                                      constant:self.labelHeight];
        self.ageLabelHeight = ageHeight;
        
        // Add an array of the individual constraints to the array of constraint arrays,
        // then flatten all of the arrays to get just one array of constraints.
        constraintArrays = [constraintArrays arrayByAddingObjectsFromArray:@[ @[ priorityHeight, ageHeight ] ]];
        
        NSArray *constraints = [constraintArrays valueForKeyPath:@"@unionOfArrays.self"];
        [self.contentView addConstraints:constraints];
        
        NSArray *constraintsWithAgeLabel = constraintArrays[3];
        NSArray *constraintsWithoutAgeLabel =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(boundsSpacing)-[textView]-(boundsSpacing)-|"
                                                options:0
                                                metrics:metrics
                                                  views:bindings];
        
        // Adjust constraints and add or remove the age label if shouldShowDate changes
        RACSignal *showDateSignal = [RACAble(self.shouldShowDate) distinctUntilChanged];
        
        [[showDateSignal filter:^BOOL(NSNumber *boolNumber) {
            return [boolNumber isEqual:@YES];
        }] subscribeNext:^(id _) {
            [self.contentView removeConstraints:constraintsWithoutAgeLabel];
            [self.contentView addSubview:self.ageLabel];
            [self.contentView addConstraints:constraintsWithAgeLabel];
        }];
        
        [[showDateSignal filter:^BOOL(NSNumber *boolNumber) {
            return [boolNumber isEqual:@NO];
        }] subscribeNext:^(id _) {
            [self.contentView removeConstraints:constraintsWithAgeLabel];
            [self.ageLabel removeFromSuperview];
            [self.contentView addConstraints:constraintsWithoutAgeLabel];
        }];
        
        // tell the view that constraints changed if showDateSignal fires
        [showDateSignal subscribeNext:^(id _) {
            [self setNeedsUpdateConstraints];
            [self layoutIfNeeded];
        }];
    }
    
    return self;
}

#pragma mark - Overridden getters/setters

- (CGFloat)labelHeight
{
    static CGFloat const labelHeight = 20;
    return labelHeight;
}

#pragma mark - Public class methods

// TODO: consider moving me to another class, maybe the view model
+ (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font showingDate:(BOOL)shouldShowDate width:(CGFloat)width;
{
    TaskCell *cell = self.staticSizingCell;
    
    CGFloat bottomSpace = kSmallSpacing;
    if (shouldShowDate) {
        bottomSpace += kSmallSpacing + cell.labelHeight;
    }
    
    CGFloat const baseHeight = kSmallSpacing + bottomSpace;
    CGFloat const takenWidth = kBigSpacing + kAccessoryWidthEstimate;
    
    CGSize taskLabelSize = CGSizeMake(width - takenWidth, CGFLOAT_MAX);
    
    cell.taskTextView.attributedText = [[NSAttributedString alloc] initWithString:text
                                                                       attributes:@{
                                                                                    NSFontAttributeName : font
                                                                                    } ];
    CGRect rect = CGRectZero;
    rect.size = [cell.taskTextView sizeThatFits:taskLabelSize];
    
    CGFloat const height = baseHeight + CGRectGetHeight(rect);
    
    return height;
}

#pragma mark - Private class methods

+ (TaskCell *)staticSizingCell
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _staticSizingCell = [[TaskCell alloc] initWithStyle:UITableViewStylePlain reuseIdentifier:nil];
    });
    
    return _staticSizingCell;
}

@end
