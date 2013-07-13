/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2013 Todo.txt contributors (http://todotxt.com)
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

#import "TaskCellViewModel.h"

#import "UIColor+CustomColors.h"
#import "Task.h"

@interface TaskCellViewModel ()

@property (weak, nonatomic, readonly) NSDictionary *attributesForTask;
@property (weak, nonatomic, readonly) NSDictionary *attributesForCompletedTask;
@property (weak, nonatomic, readonly) UIFont *taskFont;
@property (weak, nonatomic, readonly) UIColor *taskColor;

@end

@implementation TaskCellViewModel

#pragma mark - Custom getters/setters

/*!
 * Get the attributed text to display for a task. Note that a white
 * non-printing character (bell, or \a, or ASCII code 7) is added at
 * the end of the attributed string to work around odd layout behavior of
 * UITextView when an attributed string has uniform attributes.
 * \return An attributed string for the view model's associated task.
 */
- (NSAttributedString *)attributedText
{
    NSDictionary *taskAttributes = self.attributesForTask;
    
    if (self.task.completed) {
        taskAttributes = self.attributesForCompletedTask;
    }
    
    NSString *taskText = [self.task inScreenFormat];
    
    // append the non-printing bell character, for the UITextView workaround
    taskText = [taskText stringByAppendingString:[NSString stringWithFormat:@"%c", 7]];
    
    NSMutableAttributedString *taskString;
    taskString = [[NSMutableAttributedString alloc] initWithString:taskText
                                                        attributes:taskAttributes];
    
    NSDictionary *grayAttribute = @{ NSForegroundColorAttributeName : [UIColor grayColor] };
    
    NSArray *contextsRanges = [self.task rangesOfContexts];
    NSArray *projectsRanges = [self.task rangesOfProjects];
    for (NSValue *rangeValue in [contextsRanges arrayByAddingObjectsFromArray:projectsRanges]) {
        NSRange range = rangeValue.rangeValue;
        [taskString addAttributes:grayAttribute range:range];
    }
    
    // make the bell character a different color than the other text,
    // for the UITextView layout workaround.
    NSDictionary *whiteAttribute = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    [taskString addAttributes:whiteAttribute range:NSMakeRange(taskText.length - 1, 1)];
    
    return taskString;
}

- (NSString *)ageText
{
    return self.task.relativeAge;
}

- (NSString *)priorityText
{
    return [[self.task priority] listFormat];
}

- (UIColor *)priorityColor
{
    UIColor *color = nil;
    
    // Set the priority label's color
	PriorityName name = [[self.task priority] name];
	switch (name) {
		case PriorityA:
			//Set color to green #587058
			color = [UIColor green];
			break;
		case PriorityB:
			//Set color to blue #587498
			color = [UIColor blue];
			break;
		case PriorityC:
			//Set color to orange #E86850
			color = [UIColor orange];
			break;
		case PriorityD:
			//Set color to gold #587058
			color = [UIColor gold];
			break;
		default:
			//Set color to black #000000
			color = [UIColor black];
			break;
	}

	return color;
}

- (BOOL)shouldShowDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isAllowed = [defaults boolForKey:@"date_new_tasks_preference"];
    
    return isAllowed && !self.task.completed && self.task.relativeAge;
}

#pragma mark - Private getters/setters

- (NSDictionary *)attributesForTask
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : self.taskFont,
                                 NSForegroundColorAttributeName : self.taskColor
                                 };
    
    return attributes;
}

- (NSDictionary *)attributesForCompletedTask
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:self.attributesForTask];
    
    NSDictionary * const completedAttributes = @{ NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle) };
    [attributes addEntriesFromDictionary:completedAttributes];
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

- (UIFont *)taskFont
{
    return [UIFont systemFontOfSize:14.0];
}

- (UIColor *)taskColor
{
    return [UIColor blackColor];
}

@end
