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

#import "ByPriorityFilterTest.h"
#import "ByPriorityFilter.h"
#import "Task.h"

@implementation ByPriorityFilterTest

- (void)testConstructor_nilPriorities
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:nil];
	STAssertNil(filter.priorities, @"priorities shoud be nil");
	STAssertEquals(0U, filter.priorities.count, @"priorities count should be zero");
}

- (void)testConstructor_valid
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:[NSArray arrayWithObjects:[Priority byName:PriorityA], [Priority byName:PriorityB], nil]];
	STAssertNotNil(filter.priorities, @"priorities shoud not be nil");
	STAssertEquals(2U, filter.priorities.count, @"priorities count should be three");
	STAssertEquals([Priority byName:PriorityA], [filter.priorities objectAtIndex:0], @"first priority should be \"A\"");
	STAssertEquals([Priority byName:PriorityB], [filter.priorities objectAtIndex:1], @"second priority should be \"B\"");
}

- (void)testFilter_noFilterPriorities_noTaskPriorities
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:nil];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world"] autorelease]], @"apply was not true");
}

- (void)testFilter_oneFilterPriority_noTaskPriorities
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:[NSArray arrayWithObject:[Priority byName:PriorityA]]];
	STAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world"] autorelease]], @"apply was not false");
}

- (void)testFilter_noFilterPriority_oneTaskPriorities
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:nil];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"(A) hello world"] autorelease]], @"apply was not true");
}

- (void)testFilter_oneFilterPriority_sameTaskPriority
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:[NSArray arrayWithObject:[Priority byName:PriorityA]]];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"(A) hello world"] autorelease]], @"apply was not true");
}

- (void)testFilter_oneFilterPriority_differentTaskPriority
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:[NSArray arrayWithObject:[Priority byName:PriorityA]]];
	STAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"(B) hello world"] autorelease]], @"apply was not false");
}

- (void)testFilter_multipleFilterPriority_oneSameTaskPriority
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:[NSArray arrayWithObjects:[Priority byName:PriorityA], [Priority byName:PriorityB], nil]];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"(A) hello world"] autorelease]], @"apply was not true");
}

- (void)testFilter_multipleFilterPriority_oneDifferentTaskPriority
{
    ByPriorityFilter *filter = [[ByPriorityFilter alloc] initWithPriorities:[NSArray arrayWithObjects:[Priority byName:PriorityA], [Priority byName:PriorityB], nil]];
	STAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"(C) hello world"] autorelease]], @"apply was not false");
}

@end
