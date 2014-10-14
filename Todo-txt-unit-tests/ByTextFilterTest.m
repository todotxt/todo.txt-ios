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

#import "ByTextFilterTest.h"
#import "ByTextFilter.h"
#import "Task.h"

@implementation ByTextFilterTest

- (void)testConstructor_nullText_false
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:nil caseSensitive:NO];
	XCTAssertNil(filter.text, @"text should be nil");
    XCTAssertFalse(filter.caseSensitive, @"caseSensitive should be false");
}

- (void)testConstructor_nullText_true
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:nil caseSensitive:YES];
	XCTAssertNil(filter.text, @"text should be nil");
    XCTAssertTrue(filter.caseSensitive, @"caseSensitive should be true");
}

- (void)testConstructor_valid_false
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:NO];
	XCTAssertNotNil(filter.text, @"text should not be nil");
	XCTAssertEqualObjects(@"ABC", filter.text, @"should be equal");
    XCTAssertFalse(filter.caseSensitive, @"caseSensitive should be false");
}

- (void)testConstructor_valid_true
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:YES];
	XCTAssertNotNil(filter.text, @"text should not be nil");
	XCTAssertEqualObjects(@"abc", filter.text, @"should be equal");
    XCTAssertTrue(filter.caseSensitive, @"caseSensitive should be true");
}

- (void)testFilter_noText_noTaskText
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"" caseSensitive:NO];
    XCTAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@""] autorelease]], @"apply was not true");
}

- (void)testFilter_noText_hasTaskText
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"" caseSensitive:NO];
    XCTAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"abc"] autorelease]], @"apply was not true");
}

- (void)testFilter_abcText_noTaskText
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:NO];
    XCTAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@""] autorelease]], @"apply was not false");
}

- (void)testFilter_abcText_notContainedTaskText
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:NO];
    XCTAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello world"] autorelease]], @"apply was not false");
}

- (void)testFilter_abcText_containsTaskText_wrongCase_caseSensitive
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:YES];
    XCTAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello ABC world"] autorelease]], @"apply was not false");
}

- (void)testFilter_abcText_containsTaskText_wrongCase_caseInSensitive
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:NO];
    XCTAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"hello ABC world"] autorelease]], @"apply was not true");
}

- (void)testFilter_abcText_containsTaskTextNotPadded_wrongCase_caseInSensitive
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:@"abc" caseSensitive:NO];
    XCTAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:@"helloABCworld"] autorelease]], @"apply was not true");
}

- (void)shouldMatch:(NSString *)pattern rawText:(NSString *)rawText cs:(BOOL)cs
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:pattern caseSensitive:cs];
    XCTAssertTrue([filter apply:[[[Task alloc] initWithId:1 withRawText:rawText] autorelease]], @"'%@' should match '%@'", pattern, rawText);
}

- (void)shouldNotMatch:(NSString *)pattern rawText:(NSString *)rawText cs:(BOOL)cs
{
	ByTextFilter *filter = [[ByTextFilter alloc] initWithText:pattern caseSensitive:cs];
    XCTAssertFalse([filter apply:[[[Task alloc] initWithId:1 withRawText:rawText] autorelease]], @"'%@' should not match '%@'", pattern, rawText);
}

- (void)testFilter_andCaseSensitive
{
	[self shouldMatch:@"abc xyz" rawText:@"abc xyz" cs:YES];
	[self shouldMatch:@"abc xyz" rawText:@"abcxyz"  cs:YES];
	[self shouldMatch:@"abc xyz" rawText:@"xyz abc" cs:YES];
	[self shouldNotMatch:@"abc xyz" rawText:@"xyz"  cs:YES];
	[self shouldNotMatch:@"abc xyz" rawText:@"ABC xyz"  cs:YES];
}

- (void)testFilter_andCaseInsensitive
{
	[self shouldMatch:@"abc xyz" rawText:@"abc xyz" cs:NO];
	[self shouldMatch:@"abc xyz" rawText:@"abcxyz"  cs:NO];
	[self shouldMatch:@"abc xyz" rawText:@"xyz abc" cs:NO];
	[self shouldNotMatch:@"abc xyz" rawText:@"xyz"  cs:NO];
	[self shouldMatch:@"abc xyz" rawText:@"ABC xyz"  cs:NO];
}

- (void)testFilter_andIgnoreWhitespace
{
	[self shouldMatch:@"abc " rawText:@"abc" cs:YES];
	[self shouldMatch:@" abc" rawText:@"abc" cs:YES];
	[self shouldMatch:@" abc " rawText:@"abc" cs:YES];
}

@end
