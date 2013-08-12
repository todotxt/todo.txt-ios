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

#import "PriorityTextSplitterTest.h"
#import "Priority.h"
#import "PriorityTextSplitter.h"

@implementation PriorityTextSplitterTest

- (void)testSplit_empty
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@""];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.text, @"text should be blank");
}

- (void)testSplit_nil
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:nil];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"", result.text, @"text should be blank");
}

- (void)testSplit_withPriority
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"(A) test"];
	STAssertEquals(PriorityA, result.priority.name, @"priority should be A");
	STAssertEqualObjects(@"test", result.text, @"text should be \"test\"");
}

- (void)testSplit_withPrependedDate
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"2011-01-02 test"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"2011-01-02 test", result.text, @"text should be \"test\"");
}

- (void)testSplit_withPriorityAndPrependedDate
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"(A) 2011-01-02 test"];
	STAssertEquals(PriorityA, result.priority.name, @"priority should be A");
	STAssertEqualObjects(@"2011-01-02 test", result.text, @"text should be \"test\"");
}

- (void)testSplit_dateInterspersedInText
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"Call Mom 2011-03-02"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"Call Mom 2011-03-02", result.text, @"text should be \"Call Mom 2011-03-02\"");
}

- (void)testSplit_missingSpace
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"(A)2011-01-02 test"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"(A)2011-01-02 test", result.text, @"text should be \"(A)2011-01-02 test\"");
}

- (void)testSplit_outOfOrder
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"2011-01-02 (A) test"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"2011-01-02 (A) test", result.text, @"text should be \"(A) test\"");
}

- (void)testSplit_completed
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"x 2011-01-02 test 123"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"x 2011-01-02 test 123", result.text, @"text should be \"test 123\"");
}

- (void)testSplit_completedWithPrependedDate
{
	PriorityTextSplitter* result = [PriorityTextSplitter split:@"x 2011-01-02 2011-01-01 test 123"];
	STAssertEqualObjects([Priority NONE], result.priority, @"priority should be NONE");
	STAssertEqualObjects(@"x 2011-01-02 2011-01-01 test 123", result.text, @"text should be \"test 123\"");
}

@end
