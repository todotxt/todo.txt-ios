/**
 *
 * Todo.txt-Touch-iOS/Classes/FlexiTaskCell.m
 *
 * Copyright (c) 2009-2011 Gina Trapani, Shawn McGuire
 *
 * LICENSE:
 *
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file (http://todotxt.com).
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
 * @author Ricky Hussmmann <ricky[dot]hussmann[at]gmail[dot]com>
 * @license http://www.gnu.org/licenses/gpl.html
 * @copyright 2009-2011 Ricky Hussmann
 *
 * Copyright (c) 2011 Gina Trapani and contributors, http://todotxt.com
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

#import "AttributedLabel.h"
#import "Color.h"
#import "ContextParser.h"
#import "FlexiTaskCell.h"
#import "ProjectParser.h"

#import <CoreText/CoreText.h>

#import "NSMutableAttributedString+TodoTxt.h"

#define VERTICAL_PADDING        5
#define PRI_XPOS_SHORT          28
#define PRI_XPOS_LONG           10
#define TEXT_XPOS_SHORT         46
#define TEXT_WIDTH_SHORT_IPHONE 235
#define TEXT_WIDTH_LONG_IPHONE  253
#define TEXT_WIDTH_SHORT_IPAD   675
#define TEXT_WIDTH_LONG_IPAD    700
#define TEXT_XPOS_LONG          PRI_XPOS_SHORT
#define TEXT_HEIGHT_SHORT       19
#define TEXT_HEIGHT_LONG        35
#define AGE_HEIGHT              13

@interface FlexiTaskCell ()

- (NSAttributedString*)attributedTaskText;

+ (UIFont*)taskFont;
+ (CGFloat)taskTextWidth;
+ (CGFloat)shortTaskWidth;
+ (CGFloat)longTaskWidth;
+ (CGFloat)taskTextOriginX;
+ (NSDictionary*)auxStringAttributes;

@property (retain, readwrite) UILabel *priorityLabel;
@property (retain, readwrite) UILabel *todoIdLabel;
@property (retain, readwrite) UILabel *ageLabel;
@property (retain, readwrite) AttributedLabel *taskLabel;
@end

@implementation FlexiTaskCell
@synthesize priorityLabel, todoIdLabel, ageLabel, taskLabel, task;

- (id)init {
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:[[self class] cellId]];

    if (self) {
        self.priorityLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.priorityLabel.font = [UIFont boldSystemFontOfSize:14.0];

        self.ageLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.ageLabel.font = [UIFont systemFontOfSize:10.0];
        self.ageLabel.textColor = [UIColor lightGrayColor];

        self.todoIdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.todoIdLabel.font = [UIFont systemFontOfSize:10.0];
        self.todoIdLabel.textColor = [UIColor lightGrayColor];
        self.todoIdLabel.textAlignment = UITextAlignmentRight;

        self.taskLabel = [[[AttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
        self.taskLabel.backgroundColor = [UIColor clearColor];

        [self addSubview:self.priorityLabel];
        [self addSubview:self.todoIdLabel];
        [self addSubview:self.ageLabel];
        [self addSubview:self.taskLabel];
    }
    return self;
}

- (void)dealloc {
    self.priorityLabel = nil;
    self.ageLabel = nil;
    self.todoIdLabel = nil;
    self.taskLabel = nil;
    [super dealloc];
}

- (NSAttributedString*)attributedTaskText {
    NSAssert(self.taskLabel, @"Task cannot be nil");

    NSDictionary *taskAttributes = (self.task.completed) ?
        [[self class] completedTaskAttributes] : [[self class] taskStringAttributes];

    NSString* taskText = [self.task inScreenFormat];
    NSMutableAttributedString *taskString;
    taskString = [[[NSMutableAttributedString alloc] initWithString:taskText
                                                         attributes:taskAttributes] autorelease];

    NSDictionary* grayAttriubte = [NSDictionary dictionaryWithObject:(id)[UIColor grayColor].CGColor
                                                              forKey:(id)kCTForegroundColorAttributeName];
    [taskString addAttributesToProjectText:grayAttriubte];
    [taskString addAttributesToContextText:grayAttriubte];

    return [[[NSAttributedString alloc] initWithAttributedString:taskString] autorelease];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect todoIdFrame = CGRectMake(0, 16, 23, 13);
    CGRect priorityFrame = CGRectMake(28, VERTICAL_PADDING-2, 12, 21);
    CGRect ageFrame = CGRectMake(46, 27, 235, AGE_HEIGHT);
    CGRect taskFrame = CGRectMake(46, VERTICAL_PADDING,
                                  [[self class] taskTextWidth], 19);

    self.todoIdLabel.frame = todoIdFrame;
    self.priorityLabel.frame = priorityFrame;
    self.ageLabel.frame = ageFrame;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
// TODO ID label setup
	if ([defaults boolForKey:@"show_line_numbers_preference"]) {
		self.todoIdLabel.text = [NSString stringWithFormat:@"%02d", [self.task taskId] + 1];
		self.todoIdLabel.hidden = NO;
	} else {
		self.todoIdLabel.hidden = YES;
	}

// Priority label setup
    if ([defaults boolForKey:@"show_line_numbers_preference"]) {
        priorityFrame.origin.x = PRI_XPOS_SHORT;//28
    } else {
        priorityFrame.origin.x = PRI_XPOS_LONG;//10
    }
    priorityLabel.frame = priorityFrame;
    priorityLabel.text = [[self.task priority] listFormat];
	// Set the priority color
	PriorityName n = [[self.task priority] name];
	switch (n) {
		case PriorityA:
			//Set color to green #587058
			self.priorityLabel.textColor = [Color green];
			break;
		case PriorityB:
			//Set color to blue #587498
			self.priorityLabel.textColor = [Color blue];
			break;
		case PriorityC:
			//Set color to orange #E86850
			self.priorityLabel.textColor = [Color orange];
			break;
		case PriorityD:
			//Set color to gold #587058
			self.priorityLabel.textColor = [Color gold];
			break;			
		default:
			//Set color to black #000000
			self.priorityLabel.textColor = [Color black];
			break;
	}
	
    CGSize maxSize = CGSizeMake(CGRectGetWidth(taskFrame), CGFLOAT_MAX);
    CGSize labelSize = [[self.task inScreenFormat] sizeWithFont:[[self class] taskFont]
                                              constrainedToSize:maxSize
                                                  lineBreakMode:UILineBreakModeWordWrap];

    taskFrame.origin.x = [[self class] taskTextOriginX];
    taskFrame.size = labelSize;
    self.taskLabel.frame = taskFrame;
    self.taskLabel.text = [self attributedTaskText];

    // A little hack-y to align priority label with task ID
    todoIdFrame.origin.y = VERTICAL_PADDING + 3;
    self.todoIdLabel.frame = todoIdFrame;

	if ([defaults boolForKey:@"show_task_age_preference"] && ![self.task completed]) {
        ageFrame.origin.x = [[self class] taskTextOriginX];
        ageFrame.origin.y = CGRectGetMinY(taskFrame) + CGRectGetHeight(taskFrame);
        ageFrame.size.width = [[self class] taskTextWidth];
        self.ageLabel.frame = ageFrame;
		self.ageLabel.text = [self.task relativeAge];
		self.ageLabel.hidden = NO;
	} else {
		self.ageLabel.text = @"";
		self.ageLabel.hidden = YES;
	}
}

+ (NSString*)cellId { return NSStringFromClass(self); }
+ (UIFont*)taskFont { return [UIFont systemFontOfSize:14.0]; }

+ (BOOL)shouldShowTaskId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:@"show_line_numbers_preference"];
}

+ (BOOL)shouldShowTaskAge {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"show_task_age_preference"];
}

+ (CGFloat)taskTextWidth {
    return [self shouldShowTaskId] ? [self shortTaskWidth] : [self longTaskWidth];
}

+ (CGFloat)taskTextOriginX {
    return [self shouldShowTaskId] ? TEXT_XPOS_SHORT : TEXT_XPOS_LONG;
}

+ (CGFloat)heightForCellWithTask:(Task*)aTask {
    CGSize maxSize = CGSizeMake(self.taskTextWidth, CGFLOAT_MAX);
    CGSize labelSize = [[aTask inScreenFormat] sizeWithFont:[self taskFont]
                                          constrainedToSize:maxSize
                                              lineBreakMode:UILineBreakModeWordWrap];

    CGFloat ageLabelHeight = [self shouldShowTaskAge] ? AGE_HEIGHT : 0;
    return fmax(2*VERTICAL_PADDING+labelSize.height+ageLabelHeight, 50);
}

+ (NSDictionary*)taskStringAttributes {
    UIFont *taskFont = [[self class] taskFont];
    CGColorRef black = [UIColor blackColor].CGColor;
    CTFontRef font = CTFontCreateWithName((CFStringRef)taskFont.fontName,
                                          taskFont.pointSize,
                                          NULL);

    return [NSDictionary dictionaryWithObjectsAndKeys:
            (id)font, (id)kCTFontAttributeName,
            (id)black, (id)kCTForegroundColorAttributeName,
            nil];
}

+ (NSDictionary*)auxStringAttributes {
    UIFont *taskFont = [[self class] taskFont];
    CGColorRef gray = [UIColor grayColor].CGColor;
    CTFontRef font = CTFontCreateWithName((CFStringRef)taskFont.fontName,
                                          taskFont.pointSize,
                                          NULL);

    return [NSDictionary dictionaryWithObjectsAndKeys:
            (id)font, (id)kCTFontAttributeName,
            (id)gray, (id)kCTForegroundColorAttributeName,
            nil];
}

+ (NSDictionary*)completedTaskAttributes {
    UIFont *taskFont = [[self class] taskFont];
    CGColorRef black = [UIColor blackColor].CGColor;
    CTFontRef font = CTFontCreateWithName((CFStringRef)taskFont.fontName,
                                          taskFont.pointSize,
                                          NULL);

    return [NSDictionary dictionaryWithObjectsAndKeys:
            (id)font, (id)kCTFontAttributeName,
            (id)black, (id)kCTForegroundColorAttributeName,
            [NSNumber numberWithBool:YES], (id)kTTStrikethroughAttributeName,
            nil];
}

+ (CGFloat)shortTaskWidth {
    // TODO: This must be overridden by subclases! This method should never be called!
    [NSException exceptionWithName:@"IncompleteImplementationException"
                            reason:@"FlexiTaskCell shortTaskWidth: should never be called, "
     @"it should always be overridden by subclasses."
                          userInfo:nil];
    return 0;
}

+ (CGFloat)longTaskWidth {
    // TODO: This must be overridden by subclases! This method should never be called!
    [NSException exceptionWithName:@"IncompleteImplementationException"
                            reason:@"FlexiTaskCell longTaskWidth: should never be called, "
     @"it should always be overridden by subclasses."
                          userInfo:nil];
    return 0;
}

@end
