/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011 Todo.txt contributors (http://todotxt.com)
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

#import "OrFilterTest.h"
#import "OrFilter.h"
#import "ByPriorityFilter.h"
#import "ByProjectFilter.h"
#import "ByContextFIlter.h"
#import "ByTextFilter.h"
#import "Task.h"

@implementation OrFilterTest

- (void)testNoFilters
{
	OrFilter *orFilter = [[[OrFilter alloc] init] autorelease];
	STAssertTrue([orFilter apply:[[[Task alloc] initWithId:1 withRawText:@"(A) abc 123"] autorelease]], @"apply was not true");
}

- (void)testMultipleFilters_matchesBoth
{
	OrFilter *orFilter = [[[OrFilter alloc] init] autorelease];
	[orFilter addFilter:[[ByPriorityFilter alloc] initWithPriorities:[[NSArray arrayWithObject:[Priority byName:PriorityA]] autorelease]]];
	[orFilter addFilter:[[[ByTextFilter alloc] initWithText:@"abc" caseSensitive:false] autorelease]];
	STAssertTrue([orFilter apply:[[[Task alloc] initWithId:1 withRawText:@"(A) abc 123"] autorelease]], @"apply was not true");
}

- (void)testMultipleFilters_matchesOnlyOne
{
	OrFilter *orFilter = [[[OrFilter alloc] init] autorelease];
	[orFilter addFilter:[[ByPriorityFilter alloc] initWithPriorities:[[NSArray arrayWithObject:[Priority byName:PriorityA]] autorelease]]];
	[orFilter addFilter:[[[ByTextFilter alloc] initWithText:@"abc" caseSensitive:false] autorelease]];
	STAssertTrue([orFilter apply:[[[Task alloc] initWithId:1 withRawText:@"(A) hello world"] autorelease]], @"apply was not true");
}

- (void)testMultipleFilters_matchesNone
{
	OrFilter *orFilter = [[[OrFilter alloc] init] autorelease];
	[orFilter addFilter:[[ByPriorityFilter alloc] initWithPriorities:[[NSArray arrayWithObject:[Priority byName:PriorityA]] autorelease]]];
	[orFilter addFilter:[[[ByTextFilter alloc] initWithText:@"abc" caseSensitive:false] autorelease]];
	STAssertFalse([orFilter apply:[[[Task alloc] initWithId:1 withRawText:@"(B) hello world"] autorelease]], @"apply was not false");
}

@end
