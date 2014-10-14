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

#import "TaskIo.h"
#import "TaskIoTest.h"
#import "DDFileReader.h"

@interface MockDDReader : DDFileReader
@property int counter;
@property (assign) NSArray *lines;

- (id)initWithStrings:(NSArray *) lines;
@end

@implementation MockDDReader

- (id)initWithStrings: (NSArray *) lines {
    self = [super init];
    if (self) {
        _counter = 0;
        _lines = lines;
    }
    return self;
}

-(NSString *)readLine {

    if( _counter >= [_lines count] )
    {
        return nil;
    }

    NSString *val = [_lines objectAtIndex: _counter];
    _counter++;

    return val;
}
@end

@implementation TaskIoTest

- (void)testNoLines
{
    MockDDReader *reader = [[MockDDReader alloc] initWithStrings:[[NSArray alloc] init]];
    NSMutableArray *items = [TaskIo loadTasksFromReader:reader];

    XCTAssertEqual([items count], 0u, @"Expecting 2 items");
}

- (void)testIgnoreBlankLines
{
    NSArray *lines = [[NSArray alloc] initWithObjects:@"First line", @"", @"Second line", @"", nil];
    MockDDReader *reader = [[MockDDReader alloc] initWithStrings:lines];
    NSMutableArray *items = [TaskIo loadTasksFromReader:reader];

    XCTAssertEqual([items count], 2u, @"Expecting 2 items");
    XCTAssertEqualObjects([[items objectAtIndex:0u] text], @"First line", @"Expecting 'First line'");
    XCTAssertEqualObjects([[items objectAtIndex:1u] text], @"Second line", @"Expecting 'Second line'");
}

@end
