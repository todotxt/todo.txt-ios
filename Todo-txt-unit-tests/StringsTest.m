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

#import "StringsTest.h"
#import "Strings.h"

@implementation StringsTest

- (void)testInsertPadded_nil
{
    STAssertEqualObjects(@"thistest", [Strings insertPaddedString:@"thistest" atRange:NSMakeRange(4, 0) withString:nil], @"Nil argument should not change original string");
}

- (void)testInsertPadded_blank
{
    STAssertEqualObjects(@"thistest", [Strings insertPaddedString:@"thistest" atRange:NSMakeRange(4, 0) withString:@""], @"Blank argument should not change original string");
}

- (void)testInsertPadded_invalidInsertionPoint_tooSmall
{
    STAssertThrows([Strings insertPaddedString:@"thistest" atRange:NSMakeRange(-1, 0) withString:@"is"], @"NEgative insertion point should throw an exception");
}

- (void)testInsertPadded_invalidInsertionPoint_toolarge
{
    STAssertThrows([Strings insertPaddedString:@"thistest" atRange:NSMakeRange(99, 0) withString:@"is"], @"Insertion point past the end of the string should throw an exception");
}

- (void)testInsertPadded_simple
{
    STAssertEqualObjects(@"this is test", [Strings insertPaddedString:@"thistest" atRange:NSMakeRange(4, 0) withString:@"is"], @"Simple insertion failed");
}

- (void)testInsertPadded_simpleBegin
{
    STAssertEqualObjects(@"is thistest", [Strings insertPaddedString:@"thistest" atRange:NSMakeRange(0, 0) withString:@"is"], @"Simple insertion at beginning failed");
}

- (void)testInsertPadded_simpleEnd
{
    STAssertEqualObjects(@"thistest is ", [Strings insertPaddedString:@"thistest" atRange:NSMakeRange(8, 0) withString:@"is"], @"Simple insertion at end failed");
}

- (void)testInsertPadded_prepadded
{
    STAssertEqualObjects(@"this is test", [Strings insertPaddedString:@"this test" atRange:NSMakeRange(4, 0) withString:@"is"], @"Prepadded insertion failed");
}

- (void)testInsertPadded_prepaddedBegin
{
    STAssertEqualObjects(@"is this test", [Strings insertPaddedString:@" this test" atRange:NSMakeRange(0, 0) withString:@"is"], @"Prepadded insertion at beginning failed");
}

- (void)testInsertPadded_prepaddedEnd1
{
    STAssertEqualObjects(@"this test is ", [Strings insertPaddedString:@"this test " atRange:NSMakeRange(9, 0) withString:@"is"], @"Prepadded insertion at end failed");
}

- (void)testInsertPadded_prepaddedEnd2
{
    STAssertEqualObjects(@"this test is ", [Strings insertPaddedString:@"this test " atRange:NSMakeRange(10, 0) withString:@"is"], @"Prepadded insertion at end failed");
}

- (void)testCalculate_nilPrior
{
    STAssertEquals(NSMakeRange(7, 0), [Strings calculateSelectedRange:NSMakeRange(0, 0)	oldText:nil newText:@"123test"], @"Selected Range with nil Prior text should be length of new string");
}

- (void)testCalculate_nilNew
{
    STAssertEquals(NSMakeRange(0, 0), [Strings calculateSelectedRange:NSMakeRange(0, 0)	oldText:@"test" newText:nil], @"Selected Range with nil Prior text should be 0");
}

- (void)testCalculate_simpleBegin
{
    STAssertEquals(NSMakeRange(3, 0), [Strings calculateSelectedRange:NSMakeRange(0, 0)	oldText:@"test" newText:@"123test"], @"Selected Range should be 3");
}

- (void)testCalculate_simpleEnd
{
    STAssertEquals(NSMakeRange(7, 0), [Strings calculateSelectedRange:NSMakeRange(4, 0)	oldText:@"test" newText:@"123test"], @"Selected Range should be 7");
}

- (void)testCalculate_emptyPrior
{
    STAssertEquals(NSMakeRange(7, 0), [Strings calculateSelectedRange:NSMakeRange(0, 0)	oldText:@"" newText:@"123test"], @"Selected Range with empty Prior text should be length of new string");
}

- (void)testCalculate_emptyNew
{
    STAssertEquals(NSMakeRange(0, 0), [Strings calculateSelectedRange:NSMakeRange(0, 0)	oldText:@"test" newText:@""], @"Selected Range with nil Prior text should be 0");
}

- (void)testCalculate_nonsense1
{
    STAssertEquals(NSMakeRange(7, 0), [Strings calculateSelectedRange:NSMakeRange(99, 0) oldText:@"test" newText:@"test123"], @"Selected Range with bogus prior range should be length of new string");
}

@end
