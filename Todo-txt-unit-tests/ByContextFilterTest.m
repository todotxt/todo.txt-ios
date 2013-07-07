/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2012 Todo.txt contributors (http://todotxt.com)
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

#import "ByContextFilterTest.h"
#import "ByContextFilter.h"
#import "Task.h"

@implementation ByContextFilterTest

- (void)testConstructor_nilContexts
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:nil];
	STAssertNil(filter.contexts, @"contexts shoud be nil");
	STAssertEquals(0U, filter.contexts.count, @"contexts count should be zero");
}

- (void)testConstructor_valid
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObjects:@"abc", @"123", @"hello", nil]];
	STAssertNotNil(filter.contexts, @"contexts shoud not be nil");
	STAssertEquals(3U, filter.contexts.count, @"contexts count should be three");
	STAssertEqualObjects(@"abc", [filter.contexts objectAtIndex:0], @"first context should be \"abc\"");
	STAssertEqualObjects(@"123", [filter.contexts objectAtIndex:1], @"second context should be \"123\"");
	STAssertEqualObjects(@"hello", [filter.contexts objectAtIndex:2], @"third context should be \"hello\"");
}

- (void)testFilter_noFilterContexts_noTaskContexts
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:nil];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world"] autorelease]], @"apply was not true");
}

- (void)testFilter_oneFilterContext_noTaskContexts
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObject:@"abc"]];
	STAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world"] autorelease]], @"apply was not false");
}

- (void)testFilter_noFilterContext_oneTaskContexts
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:nil];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @abc"] autorelease]], @"apply was not true");
}

- (void)testFilter_oneFilterContext_sameTaskContext
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObject:@"abc"]];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @abc"] autorelease]], @"apply was not true");
}

- (void)testFilter_oneFilterContext_differentTaskContext
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObject:@"abc"]];
	STAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @123"] autorelease]], @"apply was not false");
}

- (void)testFilter_multipleFilterContext_oneSameTaskContext
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObjects:@"abc", @"123", @"hello", nil]];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @123"] autorelease]], @"apply was not true");
}

- (void)testFilter_multipleFilterContext_multipleTaskContext
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObjects:@"abc", @"123", @"hello", nil]];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @123 @goodbye"] autorelease]], @"apply was not true");
}

- (void)testFilter_multipleFilterContext_multipleSameTaskContext
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObjects:@"abc", @"123", @"hello", nil]];
	STAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @123 @hello"] autorelease]], @"apply was not true");
}

- (void)testFilter_multipleFilterContext_multipleDifferentTaskContext
{
    ByContextFilter *filter = [[ByContextFilter alloc] initWithContexts:[NSArray arrayWithObjects:@"abc", @"123", @"hello", nil]];
	STAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world @xyz @goodbye"] autorelease]], @"apply was not false");
}

@end
