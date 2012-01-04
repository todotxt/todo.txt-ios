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

#import "TextSplitterTest.h"
#import "Priority.h"
#import "TextSplitter.h"

@implementation TextSplitterTest

- (void)testSplit_empty
{
	TextSplitter* result = [TextSplitter split:@""];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.prependedDate, @"prependedDate should be blank");
	STAssertEqualObjects(@"", result.text, @"text should be blank");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_nil
{
	TextSplitter* result = [TextSplitter split:nil];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.prependedDate, @"prependedDate should be blank");
	STAssertEqualObjects(@"", result.text, @"text should be blank");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_withPriority
{
	TextSplitter* result = [TextSplitter split:@"(A) test"];
	STAssertEquals(PriorityA, result.priority.name, @"priority should be A");
	STAssertEqualObjects(@"", result.prependedDate, @"prependedDate should be blank");
	STAssertEqualObjects(@"test", result.text, @"text should be \"test\"");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_withPrependedDate
{
	TextSplitter* result = [TextSplitter split:@"2011-01-02 test"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"2011-01-02", result.prependedDate, @"prependedDate should be 2011-01-02");
	STAssertEqualObjects(@"test", result.text, @"text should be \"test\"");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_withPriorityAndPrependedDate
{
	TextSplitter* result = [TextSplitter split:@"(A) 2011-01-02 test"];
	STAssertEquals(PriorityA, result.priority.name, @"priority should be A");
	STAssertEqualObjects(@"2011-01-02", result.prependedDate, @"prependedDate should be 2011-01-02");
	STAssertEqualObjects(@"test", result.text, @"text should be \"test\"");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_dateInterspersedInText
{
	TextSplitter* result = [TextSplitter split:@"Call Mom 2011-03-02"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.prependedDate, @"prependedDate should be blank");
	STAssertEqualObjects(@"Call Mom 2011-03-02", result.text, @"text should be \"Call Mom 2011-03-02\"");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_missingSpace
{
	TextSplitter* result = [TextSplitter split:@"(A)2011-01-02 test"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.prependedDate, @"prependedDate should be blank");
	STAssertEqualObjects(@"(A)2011-01-02 test", result.text, @"text should be \"(A)2011-01-02 test\"");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_outOfOrder
{
	TextSplitter* result = [TextSplitter split:@"2011-01-02 (A) test"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"2011-01-02", result.prependedDate, @"prependedDate should be 2011-01-02");
	STAssertEqualObjects(@"(A) test", result.text, @"text should be \"(A) test\"");
	STAssertFalse(result.completed, @"completed should be false");
	STAssertEqualObjects(@"", result.completedDate, @"completedDate should be blank");
}

- (void)testSplit_completed
{
	TextSplitter* result = [TextSplitter split:@"x 2011-01-02 test 123"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.prependedDate, @"prependedDate should be blank");
	STAssertEqualObjects(@"test 123", result.text, @"text should be \"test 123\"");
	STAssertTrue(result.completed, @"completed should be true");
	STAssertEqualObjects(@"2011-01-02", result.completedDate, @"completedDate should be 2011-01-02");
}

- (void)testSplit_completedWithPrependedDate
{
	TextSplitter* result = [TextSplitter split:@"x 2011-01-02 2011-01-01 test 123"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"2011-01-01", result.prependedDate, @"prependedDate should be 2011-01-01");
	STAssertEqualObjects(@"test 123", result.text, @"text should be \"test 123\"");
	STAssertTrue(result.completed, @"completed should be true");
	STAssertEqualObjects(@"2011-01-02", result.completedDate, @"completedDate should be 2011-01-02");
}

@end
