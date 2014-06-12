/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2013 Todo.txt contributors (http://todotxt.com)
 *
 * Dual-licensed under the GNU General Public License and the MIT License
 *
 * @license GNU General Public License http://www.gnu.org/licenses/gpl.html
 *
 * Todo.txt is free software: you can redistribute it and/or modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation, either version 2 of the License, or (at your option) any
 * later version.
 *
 * Todo.txt is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with Todo.txt.  If not, see
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

// Static instance of the class, used to check layout sizing
static TaskCell *_staticSizingCell;

// Constants
static const CGFloat kBigSpacing = 27;
static const CGFloat kSmallBoundsSpacing = 6;
static const CGFloat kSmallSpacing = 4;
static const CGFloat kTaskAndAgeVerticalSpacing = 0;

static const CGFloat kAccessoryWidthEstimate = 35;
static const CGFloat kAccessoryWidthEstimateLessThan7 = 20;
static const CGFloat kAgeLabelWidth = 180;

static const CGFloat kAgeLabelHeight = 14;
static const CGFloat kPriorityLabelHeight = 20;

static const CGFloat kAgeLabelLeftOffset = 3;
static const CGFloat kAgeLabelLeftOffsetLessThan7 = 2;
static const CGFloat kAgeLabelTopOffset = -12;
static const CGFloat kAgeLabelTopOffsetLessThan7 = -15;

@interface TaskCell ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTopSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelLeadingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTrailingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ageLabelHeightConstraint;
@property (nonatomic, readonly) CGFloat priorityLabelHeight;
@property (nonatomic, readonly) CGFloat ageLabelHeight;

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
        
        // Set the priorityLabel and ageLabel fonts.  The textView's font is set by
        // the controller or view model
        priorityLabel.font = [UIFont boldSystemFontOfSize:14.0];
        ageLabel.font = [UIFont systemFontOfSize:10.0];
        
        ageLabel.textColor = [UIColor lightGrayColor];
        
        UIEdgeInsets contentInset = UIEdgeInsetsMake(-8, -2, 0, -4);
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            contentInset = UIEdgeInsetsMake(-1, -6, 0, -4);
        }
        
        textView.contentInset = contentInset;
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
                                   @"priorityLabelTopSpacing" : @(kSmallBoundsSpacing-2),
                                   @"spacing" : @(kSmallSpacing),
                                   @"taskAndAgeVerticalSpacing" : @(kTaskAndAgeVerticalSpacing),
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
          [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(priorityLabelTopSpacing)-[priorityLabel]"
                                                  options:0
                                                  metrics:metrics
                                                    views:bindings],
          [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(boundsSpacing)-[textView]-(boundsSpacing)-|"
                                                  options:0
                                                  metrics:metrics
                                                    views:bindings],
          ];
        
        NSLayoutConstraint *ageLabelTop = [NSLayoutConstraint constraintWithItem:ageLabel
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:textView
                                                                       attribute:NSLayoutAttributeBottom
                                                                      multiplier:1.0
                                                                        constant:kAgeLabelTopOffset];
        NSLayoutConstraint *ageLabelLeft = [NSLayoutConstraint constraintWithItem:ageLabel
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:textView
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:kAgeLabelLeftOffset];
        NSLayoutConstraint *ageLabelHeight = [NSLayoutConstraint constraintWithItem:ageLabel
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1.0
                                                                           constant:self.ageLabelHeight];
        
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            ageLabelTop.constant = kAgeLabelTopOffsetLessThan7;
            ageLabelLeft.constant = kAgeLabelLeftOffsetLessThan7;
        }
        
        self.ageLabelHeightConstraint = ageLabelHeight;
        
        NSLayoutConstraint *priorityLabelHeight = [NSLayoutConstraint constraintWithItem:priorityLabel
                                                                               attribute:NSLayoutAttributeHeight
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:nil
                                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                                              multiplier:1.0
                                                                                constant:self.priorityLabelHeight];

        // Add an array of the individual constraints to the array of constraint arrays,
        // then flatten all of the arrays to get just one array of constraints.
        constraintArrays = [constraintArrays arrayByAddingObject:@[ ageLabelTop, ageLabelLeft, ageLabelHeight, priorityLabelHeight ]];
        
        NSArray *constraints = [constraintArrays valueForKeyPath:@"@unionOfArrays.self"];
        [self.contentView addConstraints:constraints];
        
        // Adjust constraints and add or remove the age label if shouldShowDate changes
        RACSignal *showDateSignal = [RACObserve(self, shouldShowDate) distinctUntilChanged];
        
        // Add/remove the age label based on showDateSignal, and tell the view
        // to layout afterwards.
        [[RACSignal merge:@[
          [[showDateSignal filter:^BOOL(NSNumber *boolNumber) {
            return [boolNumber isEqual:@YES];
        }] doNext:^(id _) {
            [self.contentView addSubview:self.ageLabel];
            [self.contentView addConstraints:@[ ageLabelTop, ageLabelLeft, ageLabelHeight ]];
        }],
          [[showDateSignal filter:^BOOL(NSNumber *boolNumber) {
            return [boolNumber isEqual:@NO];
        }] doNext:^(id _) {
            [self.contentView removeConstraints:@[ ageLabelTop, ageLabelLeft, ageLabelHeight ]];
            [self.ageLabel removeFromSuperview];
        }],
          ]]
         subscribeNext:^(id _) {
             [self setNeedsDisplay];
         }];
    }
    
    return self;
}

#pragma mark - Overridden getters/setters

- (CGFloat)priorityLabelHeight
{
    return kPriorityLabelHeight;
}

- (CGFloat)ageLabelHeight
{
    return kAgeLabelHeight;
}

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (NSString *)accessibilityLabel
{
    NSString *priorityLabel = [self.priorityLabel accessibilityLabel];
    NSString *taskLabel = [self.taskTextView accessibilityLabel];
    NSString *ageLabel = [self.ageLabel accessibilityLabel];
    
    NSMutableArray *labels = [NSMutableArray array];
    
    if (([priorityLabel length] != 0) && !([priorityLabel isEqualToString:@" "])){
        [labels addObject: [NSString stringWithFormat:@"Priority %@", priorityLabel]];
    }
    
    if (taskLabel != nil)
        [labels addObject: taskLabel];
    
    if (ageLabel != nil){
        [labels addObject: [NSString stringWithFormat:@"Created %@", ageLabel]];
    }
    return [ labels componentsJoinedByString:@", "];
}

#pragma mark - Public class methods

+ (CGFloat)heightForText:(NSString *)text withFont:(UIFont *)font width:(CGFloat)width;
{
    TaskCell *cell = self.staticSizingCell;
    
    CGFloat const bottomSpace = kSmallSpacing;
    CGFloat const baseHeight = kSmallSpacing + bottomSpace;
    CGFloat const takenWidth = kBigSpacing + (SYSTEM_VERSION_LESS_THAN(@"7.0") ? kAccessoryWidthEstimateLessThan7 : kAccessoryWidthEstimate);
    
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
