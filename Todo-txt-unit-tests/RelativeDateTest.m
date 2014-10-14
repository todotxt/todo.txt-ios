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

#import "RelativeDateTest.h"
#import "RelativeDate.h"
#import "Util.h"

@implementation RelativeDateTest

static NSDate * toDate(NSInteger year, NSInteger month, NSInteger day) {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setYear:year];
    [components setMonth:month];
    [components setDay:day];
    return [calendar dateFromComponents:components];
}

- (void)testNow
{
	NSDate* today = [NSDate date];
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents * comp = [cal components:( NSYearCalendarUnit| NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:today];
	today = [cal dateFromComponents:comp];

	NSString* actual = [RelativeDate stringWithDate:today fromDate:today withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"today", actual, @"Today's date should return 'today'");
}

- (void)test1DayFromNow
{
	NSDate *date = toDate(2013, 01, 02);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"2013-01-02", actual, @"Date in the future should return the actual date");
}

- (void)testToday
{
	NSDate *date = toDate(2013, 01, 01);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"today", actual, @"Same date should return 'today'");
}

- (void)test1DayAgo
{
	NSDate *date = toDate(2012, 12, 31);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"1 day ago", actual, @"Previous day should return '1 day ago'");
}

- (void)test2DaysAgo
{
	NSDate *date = toDate(2012, 12, 30);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"2 days ago", actual, @"Less than 1 month should return 'N days ago'");
}

- (void)test29DaysAgo
{
	NSDate *date = toDate(2012, 12, 03);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"29 days ago", actual, @"Less than 1 month should return 'N days ago'");
}

- (void)test30DaysAgo
{
	NSDate *date = toDate(2012, 12, 02);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"1 month ago", actual, @"Less than 60 days should return '1 month ago'");
}

- (void)test59DaysAgo
{
	NSDate *date = toDate(2012, 11, 03);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"1 month ago", actual, @"Less than 60 days should return '1 month ago'");
}

- (void)test60DaysAgo
{
	NSDate *date = toDate(2012, 11, 02);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"2 months ago", actual, @"Less than 365 days should return 'N months ago'");
}

- (void)test364DaysAgo
{
	NSDate *date = toDate(2012, 01, 03);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"12 months ago", actual, @"Less than 365 days should return 'N months ago'");
}

- (void)test365DaysAgo
{
	NSDate *date = toDate(2012, 01, 02);
	NSDate *fromDate = toDate(2013, 01, 01);
	NSString* actual = [RelativeDate stringWithDate:date fromDate:fromDate withFormat:@"yyyy-MM-dd"];
	
    XCTAssertEqualObjects(@"2012-01-02", actual, @"More than 365 days should return the actual date");
}

@end
