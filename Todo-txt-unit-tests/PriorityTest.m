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

#import "PriorityTest.h"
#import "Priority.h"

@implementation PriorityTest

- (void)testAccessors_simple
{
	STAssertEquals(@"A", [Priority byName:PriorityA].code, @"should be A");
	STAssertEquals(@"A", [Priority byName:PriorityA].listFormat, @"should be A");
	STAssertEquals(@"A", [Priority byName:PriorityA].detailFormat, @"should be A");
	STAssertEquals(@"(A)", [Priority byName:PriorityA].fileFormat, @"should be (A)");
}

- (void)testToPriority_A {
	STAssertEquals([Priority byName:PriorityA], [Priority byCode:@"A"], @"Should be the same object");
}

- (void)testToPriority_Z {
	STAssertEquals([Priority byName:PriorityZ], [Priority byCode:@"Z"], @"Should be the same object");
}

- (void)testToPriority_invalid {
	STAssertEquals([Priority NONE], [Priority byCode:@"9"], @"Invalid Priority should return NONE");
}

- (void)testRange_all {
	NSArray *all = [Priority all];
	STAssertEquals(27U, all.count, @"Should be 27 priorities, including NONE");
	STAssertEquals([Priority NONE], [all objectAtIndex:0], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityA], [all objectAtIndex:1], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityB], [all objectAtIndex:2], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityC], [all objectAtIndex:3], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityD], [all objectAtIndex:4], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityE], [all objectAtIndex:5], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityF], [all objectAtIndex:6], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityG], [all objectAtIndex:7], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityH], [all objectAtIndex:8], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityI], [all objectAtIndex:9], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityJ], [all objectAtIndex:10], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityK], [all objectAtIndex:11], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityL], [all objectAtIndex:12], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityM], [all objectAtIndex:13], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityN], [all objectAtIndex:14], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityO], [all objectAtIndex:15], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityP], [all objectAtIndex:16], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityQ], [all objectAtIndex:17], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityR], [all objectAtIndex:18], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityS], [all objectAtIndex:19], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityT], [all objectAtIndex:20], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityU], [all objectAtIndex:21], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityV], [all objectAtIndex:22], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityW], [all objectAtIndex:23], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityX], [all objectAtIndex:24], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityY], [all objectAtIndex:25], @"Invalid Priority in *all* list");
	STAssertEquals([Priority byName:PriorityZ], [all objectAtIndex:26], @"Invalid Priority in *all* list");
}

- (void)testRange_allCodes {
	NSArray *allCodes = [Priority allCodes];
	STAssertEquals(27U, allCodes.count, @"Should be 27 priorities, including NONE");
	STAssertEqualObjects([[Priority NONE] code], [allCodes objectAtIndex:0], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityA] code], [allCodes objectAtIndex:1], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityB] code], [allCodes objectAtIndex:2], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityC] code], [allCodes objectAtIndex:3], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityD] code], [allCodes objectAtIndex:4], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityE] code], [allCodes objectAtIndex:5], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityF] code], [allCodes objectAtIndex:6], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityG] code], [allCodes objectAtIndex:7], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityH] code], [allCodes objectAtIndex:8], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityI] code], [allCodes objectAtIndex:9], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityJ] code], [allCodes objectAtIndex:10], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityK] code], [allCodes objectAtIndex:11], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityL] code], [allCodes objectAtIndex:12], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityM] code], [allCodes objectAtIndex:13], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityN] code], [allCodes objectAtIndex:14], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityO] code], [allCodes objectAtIndex:15], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityP] code], [allCodes objectAtIndex:16], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityQ] code], [allCodes objectAtIndex:17], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityR] code], [allCodes objectAtIndex:18], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityS] code], [allCodes objectAtIndex:19], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityT] code], [allCodes objectAtIndex:20], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityU] code], [allCodes objectAtIndex:21], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityV] code], [allCodes objectAtIndex:22], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityW] code], [allCodes objectAtIndex:23], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityX] code], [allCodes objectAtIndex:24], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityY] code], [allCodes objectAtIndex:25], @"Invalid Priority in *allCodes* list");
	STAssertEquals([[Priority byName:PriorityZ] code], [allCodes objectAtIndex:26], @"Invalid Priority in *allCodes* list");
}


@end
