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
#import "RelativeDate.h"
#import "Util.h"

#define RELATIVE_DATE_FORMAT @"yyyy-MM-dd"

// Doesn't handle leap year, etc, but we don't need to be very
// accurate. This is just for human readable date displays.
#define SECOND 1
#define HOUR (3600 * SECOND)
#define DAY (24 * HOUR)
#define YEAR (365 * DAY)

@implementation RelativeDate

+ (NSString*)stringWithDate:(NSDate*)date fromDate:(NSDate*)fromDate withFormat:(NSString*)format {
	NSTimeInterval diff = [fromDate timeIntervalSinceDate:date];
	
	if (diff < 0 || diff >= YEAR) {
		// future or far in past,
		// just return yyyy-mm-dd
		return [Util stringFromDate:date withFormat:format];
	}
	
	if (diff >= 60 * DAY) {
		// N months ago
		long months = diff / (30 * DAY);
		return [NSString stringWithFormat:@"%ld months ago", months];
	}
	
	if (diff >= 30 * DAY) {
		// 1 month ago
		return @"1 month ago";
	}
	
	if (diff >= 2 * DAY) {
		// more than 2 days ago
		long days = diff / DAY;
		return [NSString stringWithFormat:@"%ld days ago", days];
	}
	
	if (diff >= 1 * DAY) {
		// 1 day ago
		return @"1 day ago";
	}
	
	// today
	return @"today";
}

+ (NSString*)stringWithDate:(NSDate*)date withFormat:(NSString*)format {
	NSDate* today = [NSDate date];
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDateComponents * comp = [cal components:( NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:today];
	today = [cal dateFromComponents:comp];
	
	return [RelativeDate stringWithDate:date fromDate:today withFormat:format];
}

+ (NSString*)stringWithDate:(NSDate*)date {
	return [RelativeDate stringWithDate:date withFormat:RELATIVE_DATE_FORMAT];
}

@end
