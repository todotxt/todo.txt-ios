/**
 *
 * Todo.txt-Touch-iOS/Classes/todo_txt_touch_iosAppDelegate.h
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
 * @author Gina Trapani <ginatrapani[at]gmail[dot]com>
 * @author Shawn McGuire <mcguiresm[at]gmail[dot]com> 
 * @license http://www.gnu.org/licenses/gpl.html
 * @copyright 2009-2011 Gina Trapani, Shawn McGuire
 *
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

#import "Task.h"
#import "TextSplitter.h"
#import "ContextParser.h"
#import "ProjectParser.h"
#import "RelativeDate.h"
#import "Util.h"
#import "TestFlight.h"

#define COMPLETED_TXT @"x "
#define TASK_DATE_FORMAT @"yyyy-MM-dd"

@implementation Task

@synthesize originalText, originalPriority;
@synthesize taskId, priority, deleted, completed, text;
@synthesize completionDate, prependedDate, relativeAge;
@synthesize contexts, projects;	

- (void)populateWithTaskId:(NSUInteger)newId withRawText:(NSString*)rawText withDefaultPrependedDate:(NSDate*)date {
	taskId = newId;
	
	TextSplitter *splitResult = [TextSplitter split:rawText];
	
	priority = [splitResult priority];
	text = [[splitResult text] retain];
	prependedDate = [[splitResult prependedDate] retain];
	completed = [splitResult completed];
	completionDate = [[splitResult completedDate] retain];
	
	contexts = [[ContextParser parse:text] retain];
	projects = [[ProjectParser parse:text] retain];
	deleted = [text length] == 0;
	
	if (date && [prependedDate length] == 0) {
		prependedDate = [Util stringFromDate:date withFormat:TASK_DATE_FORMAT];
	}
	
	if ([prependedDate length] > 0) {
		relativeAge = [[RelativeDate 
						stringWithDate:[Util dateFromString:prependedDate 
										withFormat:TASK_DATE_FORMAT]] retain];
	}
	
}

- (id)initWithId:(NSUInteger)newID withRawText:(NSString*)rawText withDefaultPrependedDate:(NSDate*)date {
	self = [super init];

	if (self) {
		[self populateWithTaskId:newID withRawText:rawText withDefaultPrependedDate:date];
		originalPriority = priority;
		originalText = text;
	}
	
	return self;
}

- (id)initWithId:(NSUInteger)taskID withRawText:(NSString*)rawText {
	return [self initWithId:taskID withRawText:rawText withDefaultPrependedDate:nil];
}

- (void)update:(NSString*)rawText {
	[self populateWithTaskId:taskId withRawText:rawText withDefaultPrependedDate:nil];
}

- (void)markComplete:(NSDate*)date {
	if (!completed) {
		priority = [Priority NONE];
		completionDate = [[Util stringFromDate:date withFormat:TASK_DATE_FORMAT] retain];
		deleted = NO;
		completed = YES;		
	}
}

- (void)markIncomplete {
	if (completed) {
		[completionDate release];
		completionDate = nil;
		completed = NO;
	}
}

- (void)deleteTask {
	[self update:@""];
}

- (NSString*)inScreenFormat{
	NSMutableString *ret = [NSMutableString stringWithCapacity:[text length] + 32];
	
	if (completed) {
		[ret appendString:COMPLETED_TXT];
		[ret appendString:completionDate];
		[ret appendString:@" "];
		if ([prependedDate length] > 0) {
			[ret appendString:prependedDate];
			[ret appendString:@" "];
		}		
	}
	
	[ret appendString:text];
	
	return [[ret copy] autorelease];
}

- (NSString*)inFileFormat{
	NSMutableString *ret = [NSMutableString stringWithCapacity:[text length] + 32];
	
	if (completed) {
		[ret appendString:COMPLETED_TXT];
		[ret appendString:completionDate];
		[ret appendString:@" "];
	} else {
		if (priority != [Priority NONE]) {
			[ret appendString:[priority fileFormat]];
			[ret appendString:@" "];
		}
	}
	
	if ([prependedDate length] > 0) {
		[ret appendString:prependedDate];
		[ret appendString:@" "];
	}

	[ret appendString:text];
	
	return [[ret copy] autorelease];
}

- (void)copyInto:(Task*)destination {
	[destination populateWithTaskId:taskId withRawText:[self inFileFormat] withDefaultPrependedDate:nil];
}

- (BOOL)isEqual:(id)anObject{
	if (self == anObject) {
		return YES;
	}
	
	if (anObject == nil || ![anObject isKindOfClass:[Task class]]) {
		return NO;
	}
	
	Task *task = (Task *)anObject;
	
	if (completed != [task completed]) {
		return NO;
	}
	
	if (deleted != [task deleted]) {
		return NO;
	}
	
	if (taskId != [task taskId]) {
		return NO;
	}
	
	if (priority != [task priority]) {
		return NO;
	}
	
	if (![contexts isEqualToArray:[task contexts]]) {
		return NO;
	}
	
	if (![prependedDate isEqualToString:[task prependedDate]]) {
		return NO;
	}
	
	if (![projects isEqualToArray:[task contexts]]) {
		return NO;
	}
	
	if (![text isEqualToString:[task text]]) {
		return NO;
	}
	
	return YES;
}

- (NSUInteger)hash{
	NSUInteger result = taskId;
	result = 31 * result + [priority hash];
	result = 31 * result + (deleted ? 1 : 0);
	result = 31 * result + (completed ? 1 : 0);
	result = 31 * result + [text hash];
	result = 31 * result + [prependedDate hash];
	result = 31 * result + [contexts hash];
	result = 31 * result + [projects hash];
	return result;
}

- (NSComparisonResult) compareByIdAscending:(Task*)other {
	if (taskId < other.taskId) {
		return NSOrderedAscending;
	} else if (taskId > other.taskId) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (NSComparisonResult) compareByIdDescending:(Task*)other {
	if (other.taskId < taskId) {
		return NSOrderedAscending;
	} else if (other.taskId > taskId) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}

- (NSComparisonResult) compareByTextAscending:(Task*)other {
	NSComparisonResult ret = [text caseInsensitiveCompare:other.text];
	if (ret == NSOrderedSame) {
		ret = [self compareByIdAscending:other];
	}
	return ret;
}

- (NSComparisonResult) compareByPriority:(Task*)other {
	if (completed && [other completed]) {
		return [self compareByIdAscending:other];
	}
	
	if (completed || [other completed]) {
		if (completed) {
			return NSOrderedDescending;
		} else {
			return NSOrderedAscending;
		}
	}
	
	if (priority == PriorityNone && [other priority] == PriorityNone) {
		return [self compareByIdAscending:other];
	}
	
	if (priority == [Priority NONE] || [other priority] == [Priority NONE]) {
		if (priority == [Priority NONE]) {
			return NSOrderedDescending;
		} else {
			return NSOrderedAscending;
		}
	}
	
	if (priority.name < other.priority.name) {
		return NSOrderedAscending;
	} else if (priority.name > other.priority.name) {
		return NSOrderedDescending;
	} else {
		return [self compareByIdAscending:other];
	}
}

@end
