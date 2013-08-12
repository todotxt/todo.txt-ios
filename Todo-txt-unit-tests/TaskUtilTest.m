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

#import "TaskUtilTest.h"
#import "TaskUtil.h"
#import "Task.h"

@implementation TaskUtilTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testHasContext
{
	STAssertFalse([TaskUtil taskHasContext:@"" context:@"home"], @"context in empty string");
	STAssertFalse([TaskUtil taskHasContext:@"hi @home" context:@"work"], @"work context in hi @home");
	STAssertTrue([TaskUtil taskHasContext:@"hi @home" context:@"home"], @"context in hi @home");
}

- (void)testHasProject
{
	STAssertFalse([TaskUtil taskHasProject:@"" project:@"reorganize"], @"project in empty string");
	STAssertTrue([TaskUtil taskHasProject:@"hi +reorganize" project:@"reorganize"], @"project in hi +reorganize");
}

- (NSArray *) allocTasks
{
	NSMutableArray *tasks = [[NSMutableArray alloc] init];
	
	Task *task = [[Task alloc] initWithId:1 withRawText:@"unprioritized"];
	[tasks addObject:task];
	task = [[Task alloc] initWithId:2 withRawText:@"x unprioritized and closed"];
	[tasks addObject:task];

	task = [[Task alloc] initWithId:3 withRawText:@"(B) prioritized"];
	[tasks addObject:task];
	task = [[Task alloc] initWithId:4 withRawText:@"x (B) prioritized and closed"];
	[tasks addObject:task];

	task = [[Task alloc] initWithId:5 withRawText:@"(A) priority A"];
	[tasks addObject:task];
	task = [[Task alloc] initWithId:6 withRawText:@"x (A) priority A and closed"];
	[tasks addObject:task];
	
	// 3 open, 2 prioritized, 1 A
	
	return tasks;
}

- (void)testBadgeCountNone
{
	NSArray *tasks = [self allocTasks];
	NSInteger count = [TaskUtil badgeCount:tasks which:@"none"];
	STAssertEquals(0, count, @"no badge count");
}

- (void)testBadgeCountAny
{
	NSArray *tasks = [self allocTasks];
	NSInteger count = [TaskUtil badgeCount:tasks which:@"any"];
	STAssertEquals(3, count, @"any badge count");
}

- (void)testBadgeCountPrioritized
{
	NSArray *tasks = [self allocTasks];
	NSInteger count = [TaskUtil badgeCount:tasks which:@"anyPriority"];
	STAssertEquals(2, count, @"any priority count");
}

- (void)testBadgeCountPriorityA
{
	NSArray *tasks = [self allocTasks];
	NSInteger count = [TaskUtil badgeCount:tasks which:@"priorityA"];
	STAssertEquals(1, count, @"priority A count");
}

@end
