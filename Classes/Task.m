/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2013 Todo.txt contributors (http://todotxt.com)
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
#import "Task.h"
#import "TextSplitter.h"
#import "ContextParser.h"
#import "ProjectParser.h"
#import "RelativeDate.h"
#import "Util.h"

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
	text = [splitResult text];
	prependedDate = [splitResult prependedDate];
	completed = [splitResult completed];
	completionDate = [splitResult completedDate];
	
	contexts = [ContextParser parse:text];
	projects = [ProjectParser parse:text];
	deleted = [text length] == 0;
	
	if (date && [prependedDate length] == 0) {
		prependedDate = [Util stringFromDate:date withFormat:TASK_DATE_FORMAT];
	}
	
	if ([prependedDate length] > 0) {
		relativeAge = [RelativeDate 
						stringWithDate:[Util dateFromString:prependedDate 
										withFormat:TASK_DATE_FORMAT]];
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
		completionDate = [Util stringFromDate:date withFormat:TASK_DATE_FORMAT];
		deleted = NO;
		completed = YES;		
	}
}

- (void)markIncomplete {
	if (completed) {
		completionDate = [NSString string];
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
	
	return [ret copy];
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
	
	return [ret copy];
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
	
	if (![projects isEqualToArray:[task projects]]) {
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

/**
  * Returns the fully extended priority order: A - Z, None, Completed
  *
  * @return fullyExtendedPriority
  */
- (NSUInteger) sortPriority {
	if (completed) {
		return [[Priority all] count];
	}
	NSUInteger intVal = (NSUInteger) priority.name;
	return (priority != [Priority NONE] ? intVal - 1 : [[Priority all] count] - 1);
}

- (NSString*) ascSortDate {
	if (completed) {
		return @"9999-99-99";
	}
	if ([prependedDate length] == 0) {
		return @"9999-99-98";
	}
	return prependedDate;
}

- (NSString*) descSortDate {
	if (completed) {
		return @"0000-00-00";
	}
	if ([prependedDate length] == 0) {
		return @"9999-99-99";
	}
	return prependedDate;
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
	if (!completed && [other completed]) {
		return NSOrderedAscending;
	}
	if (completed && !other.completed) {
		return NSOrderedDescending;
	}
	
	NSComparisonResult ret = [text caseInsensitiveCompare:other.text];
	if (ret == NSOrderedSame) {
		ret = [self compareByIdAscending:other];
	}
	return ret;
}

- (NSComparisonResult) compareByPriority:(Task*)other {
	NSUInteger thisPri = [self sortPriority];
	NSUInteger otherPri = [other sortPriority];
	
	if (thisPri < otherPri) {
		return NSOrderedAscending;
	} else if (thisPri > otherPri) {
		return NSOrderedDescending;
	} else {
		return [self compareByIdAscending:other];
	}
}

- (NSComparisonResult) compareByDateAscending:(Task*)other {
	NSComparisonResult res = [[self ascSortDate] compare:[other ascSortDate]];
	if (res != NSOrderedSame) {
		return res;
	}
	return [self compareByIdAscending:other];
}

- (NSComparisonResult) compareByDateDescending:(Task*)other {
	NSComparisonResult res = [[other descSortDate] compare:[self descSortDate]];
	if (res != NSOrderedSame) {
		return res;
	}
	return [self compareByIdDescending:other];
}

- (NSArray *)rangesOfContexts
{
    return [ContextParser rangesOfContextsForString:self.text];
}

- (NSArray *)rangesOfProjects
{
    return [ProjectParser rangesOfProjectsForString:self.text];
}

@end
