/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2012 Todo.txt contributors (http://todotxt.com)
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

#import "TextSplitter.h"
#import "PriorityTextSplitter.h"

static NSRegularExpression* completedPattern = nil;
static NSRegularExpression* completedPrependedDatesPattern = nil;
static NSRegularExpression* singleDatePattern = nil;

@implementation TextSplitter

@synthesize priority, text, prependedDate, completed, completedDate;

+ (void)initialize {
	completedPattern = [[NSRegularExpression alloc] 
						initWithPattern:@"^([X,x] )(.*)"
						options:0 
						error:nil];
	completedPrependedDatesPattern = [[NSRegularExpression alloc] 
		initWithPattern:@"^(\\d{4}-\\d{2}-\\d{2}) (\\d{4}-\\d{2}-\\d{2}) (.*)" 
		options:0 
		error:nil];
	singleDatePattern = [[NSRegularExpression alloc] 
						 initWithPattern:@"^(\\d{4}-\\d{2}-\\d{2}) (.*)" 
						 options:0 
						 error:nil];
}

- (id) init {
	self = [super init];
	if (self) {
		priority = [Priority NONE];
		text = [[NSString alloc] init];
		prependedDate = [[NSString alloc] init];
		completed = NO;
		completedDate = [[NSString alloc] init];
	}
	return self;
}

- (id) initWithPriority:(Priority*)thePriority 
			   withText:(NSString*)theText 
	  withPrependedDate:(NSString*)thePrependedDate 
		  withCompleted:(BOOL)isCompleted 
	 withCompletionDate:(NSString*)theCompletionDate {
	self = [super init];
	if (self) {
		priority = thePriority;
		text = [theText retain];
		prependedDate = [thePrependedDate retain];
		completed = isCompleted;
		completedDate = [theCompletionDate retain];
	}
	return self;
}


+ (TextSplitter*) split:(NSString*)inputText {
	if (!inputText) {
		return [[[TextSplitter alloc] init] autorelease];
	}
	
	NSTextCheckingResult *completedMatch = 
		[completedPattern firstMatchInString:inputText
			options:0
			range:NSMakeRange(0, [inputText length])];
	BOOL completed;
	NSString *text;
	if (completedMatch) {
		completed = YES;
		text = [inputText substringWithRange:[completedMatch rangeAtIndex:2]];
	} else {
		completed = NO;
		text = inputText;
	}
	
	Priority *priority = [Priority NONE];
	if(!completed) {
		PriorityTextSplitter *prioritySplitResult = [PriorityTextSplitter split:text];
		priority = [prioritySplitResult priority];
		text = [prioritySplitResult text];
	}
	
	NSString *completedDate = [NSString string];
	NSString *prependedDate = [NSString string];
	if (completed) {
		NSTextCheckingResult *completedAndPrependedMatch = 
			[completedPrependedDatesPattern firstMatchInString:text
									 options:0
									 range:NSMakeRange(0, [text length])];
		if (completedAndPrependedMatch) {
			completedDate = [text substringWithRange:[completedAndPrependedMatch rangeAtIndex:1]];
			prependedDate = [text substringWithRange:[completedAndPrependedMatch rangeAtIndex:2]];
			text = [text substringWithRange:[completedAndPrependedMatch rangeAtIndex:3]];
		} else {
			NSTextCheckingResult *completionDateMatch = 
				[singleDatePattern firstMatchInString:text
								 options:0
								 range:NSMakeRange(0, [text length])];
			if (completionDateMatch) {
				completedDate = [text substringWithRange:[completionDateMatch rangeAtIndex:1]];
				text = [text substringWithRange:[completionDateMatch rangeAtIndex:2]];
			}
		}
	} else {
		NSTextCheckingResult *prependedDateMatch = 
		[singleDatePattern firstMatchInString:text
									  options:0
										range:NSMakeRange(0, [text length])];
		if (prependedDateMatch) {
			prependedDate = [text substringWithRange:[prependedDateMatch rangeAtIndex:1]];
			text = [text substringWithRange:[prependedDateMatch rangeAtIndex:2]];
		}
	}		
	
	return [[[TextSplitter alloc] initWithPriority:priority 
										  withText:text 
								 withPrependedDate:prependedDate 
									 withCompleted:completed 
								withCompletionDate:completedDate] autorelease];
}

- (void)dealloc {
	[text release];
	[prependedDate release];
	[completedDate release];
    [super dealloc];
}

@end
