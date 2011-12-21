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
#import "RelativeDate.h"
#import "Util.h"

#define RELATIVE_DATE_FORMAT @"yyyy-MM-dd"

@implementation RelativeDate

static NSInteger currentMonth() {
	NSDate *now = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components =
	[gregorian components:(NSMonthCalendarUnit) fromDate:now];
	NSInteger month = [components month];
	[gregorian release];
	return month;
}

static NSString* computeRelativeDate(NSDate* date, int years,
									 int months, int days, int hours, 
									 int minutes, int seconds, 
									 NSString* format) {
	
	NSString * formattedDate = [Util stringFromDate:date withFormat:format];
	
	if (years == 0 && months == 0) {
		if (days < -1) {
			return [NSString stringWithFormat:@"%d days ago", abs(days)];
		} else if (days == -1) {
			return [NSString stringWithString:@"1 day ago"];
		} else if (days == 0) {
			return [NSString stringWithString:@"today"];
		}
	} else if (years == 0 || years == -1) {
		if (years == -1) {
			months = 11 - months + currentMonth();
			if (months == 1) {
				return [NSString stringWithString:@"1 month ago"];
			} else {
				return [NSString stringWithFormat:@"%d months ago", months];
			}
		} else {
			if (months != -1) {
				return [NSString stringWithFormat:@"%d months ago", abs(months)];
			} else {
				return [NSString stringWithString:@"1 month ago"];
			}
		}
	} else {
		return formattedDate;
	}

	return formattedDate;
}

+ (NSString*)stringWithDate:(NSDate*)date withFormat:(NSString*)format {
	NSDate *now = [NSDate date];
	NSCalendar *gregorian = [[NSCalendar alloc]
							 initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *nowComponents =
	[gregorian components:(NSYearCalendarUnit | 
						   NSMonthCalendarUnit |
						   NSDayCalendarUnit |
						   NSHourCalendarUnit |
						   NSMinuteCalendarUnit |
						   NSSecondCalendarUnit) fromDate:now];

	NSDateComponents *dateComponents =
	[gregorian components:(NSYearCalendarUnit | 
						   NSMonthCalendarUnit |
						   NSDayCalendarUnit |
						   NSHourCalendarUnit |
						   NSMinuteCalendarUnit |
						   NSSecondCalendarUnit) fromDate:date];
	
	int years = [dateComponents year] - [nowComponents year];
	int months = [dateComponents month] - [nowComponents month];
	int days = [dateComponents day] - [nowComponents day];
	int hours = [dateComponents hour] - [nowComponents hour];
	int minutes = [dateComponents minute] - [nowComponents minute];
	int seconds = [dateComponents second] - [nowComponents second];
	
	[gregorian release];
	
	return computeRelativeDate(date, years, months, days, hours, 
							   minutes, seconds, format);
}

+ (NSString*)stringWithDate:(NSDate*)date {
	return [RelativeDate stringWithDate:date withFormat:RELATIVE_DATE_FORMAT];
}

@end
