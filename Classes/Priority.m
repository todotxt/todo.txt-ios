/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2012 Todo.txt contributors (http://todotxt.com)
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

#import "Priority.h"

static NSArray* priorityArray = nil;

@implementation Priority

@synthesize name, code, listFormat, detailFormat, fileFormat;

- (id)initWithName:(PriorityName)theName withCode:(NSString*)theCode withListFormat:(NSString*)theListFormat withDetailFormat:(NSString*)theDetailFormat withFileFormat:(NSString*)theFileFormat {
	self = [super init];
	if (self) {
		name = theName;
        code = [theCode retain];
        listFormat = [theListFormat retain];
        detailFormat = [theDetailFormat retain];
        fileFormat = [theFileFormat retain];	
	}
	return self;
}

- (BOOL) isEqual:(id)object {
	if (![object isKindOfClass:[Priority class]]) {
		return NO;
	}
	
	Priority *pri2 = (Priority*)object;
	return [code isEqualToString:pri2.code];
}

- (NSUInteger)hash {
	return [code hash];
}

+(Priority *)priorityWithName:(PriorityName)theName withCode:(NSString*)theCode withListFormat:(NSString*)theListFormat withDetailFormat:(NSString*)theDetailFormat withFileFormat:(NSString*)theFileFormat {
	return [[[Priority alloc] initWithName:theName withCode:theCode withListFormat:theListFormat withDetailFormat:theDetailFormat withFileFormat:theFileFormat] autorelease];
}

+ (void)initialize {
	@synchronized(self) {
		if (!priorityArray) {
			priorityArray = [[NSArray arrayWithObjects:
							  [Priority priorityWithName:PriorityNone withCode:@"-" withListFormat:@" " withDetailFormat:@"" withFileFormat:@""],
							  [Priority priorityWithName:PriorityA withCode:@"A" withListFormat:@"A" withDetailFormat:@"A" withFileFormat:@"(A)"],
							  [Priority priorityWithName:PriorityB withCode:@"B" withListFormat:@"B" withDetailFormat:@"B" withFileFormat:@"(B)"],
							  [Priority priorityWithName:PriorityC withCode:@"C" withListFormat:@"C" withDetailFormat:@"C" withFileFormat:@"(C)"],
							  [Priority priorityWithName:PriorityD withCode:@"D" withListFormat:@"D" withDetailFormat:@"D" withFileFormat:@"(D)"],
							  [Priority priorityWithName:PriorityE withCode:@"E" withListFormat:@"E" withDetailFormat:@"E" withFileFormat:@"(E)"],
							  [Priority priorityWithName:PriorityF withCode:@"F" withListFormat:@"F" withDetailFormat:@"F" withFileFormat:@"(F)"],
							  [Priority priorityWithName:PriorityG withCode:@"G" withListFormat:@"G" withDetailFormat:@"G" withFileFormat:@"(G)"],
							  [Priority priorityWithName:PriorityH withCode:@"H" withListFormat:@"H" withDetailFormat:@"H" withFileFormat:@"(H)"],
							  [Priority priorityWithName:PriorityI withCode:@"I" withListFormat:@"I" withDetailFormat:@"I" withFileFormat:@"(I)"],
							  [Priority priorityWithName:PriorityJ withCode:@"J" withListFormat:@"J" withDetailFormat:@"J" withFileFormat:@"(J)"],
							  [Priority priorityWithName:PriorityK withCode:@"K" withListFormat:@"K" withDetailFormat:@"K" withFileFormat:@"(K)"],
							  [Priority priorityWithName:PriorityL withCode:@"L" withListFormat:@"L" withDetailFormat:@"L" withFileFormat:@"(L)"],
							  [Priority priorityWithName:PriorityM withCode:@"M" withListFormat:@"M" withDetailFormat:@"M" withFileFormat:@"(M)"],
							  [Priority priorityWithName:PriorityN withCode:@"N" withListFormat:@"N" withDetailFormat:@"N" withFileFormat:@"(N)"],
							  [Priority priorityWithName:PriorityO withCode:@"O" withListFormat:@"O" withDetailFormat:@"O" withFileFormat:@"(O)"],
							  [Priority priorityWithName:PriorityP withCode:@"P" withListFormat:@"P" withDetailFormat:@"P" withFileFormat:@"(P)"],
							  [Priority priorityWithName:PriorityQ withCode:@"Q" withListFormat:@"Q" withDetailFormat:@"Q" withFileFormat:@"(Q)"],
							  [Priority priorityWithName:PriorityR withCode:@"R" withListFormat:@"R" withDetailFormat:@"R" withFileFormat:@"(R)"],
							  [Priority priorityWithName:PriorityS withCode:@"S" withListFormat:@"S" withDetailFormat:@"S" withFileFormat:@"(S)"],
							  [Priority priorityWithName:PriorityT withCode:@"T" withListFormat:@"T" withDetailFormat:@"T" withFileFormat:@"(T)"],
							  [Priority priorityWithName:PriorityU withCode:@"U" withListFormat:@"U" withDetailFormat:@"U" withFileFormat:@"(U)"],
							  [Priority priorityWithName:PriorityV withCode:@"V" withListFormat:@"V" withDetailFormat:@"V" withFileFormat:@"(V)"],
							  [Priority priorityWithName:PriorityW withCode:@"W" withListFormat:@"W" withDetailFormat:@"W" withFileFormat:@"(W)"],
							  [Priority priorityWithName:PriorityX withCode:@"X" withListFormat:@"X" withDetailFormat:@"X" withFileFormat:@"(X)"],
							  [Priority priorityWithName:PriorityY withCode:@"Y" withListFormat:@"Y" withDetailFormat:@"Y" withFileFormat:@"(Y)"],
							  [Priority priorityWithName:PriorityZ withCode:@"Z" withListFormat:@"Z" withDetailFormat:@"Z" withFileFormat:@"(Z)"],
							  nil
							 ] retain];
		}
	}
}

+ (Priority*)byName:(PriorityName)name {
	return [priorityArray objectAtIndex:name];
}

+ (Priority*)NONE {
	return [Priority byName:PriorityNone];
}

+ (Priority*)byCode:(NSString*)code {
	for (int i = 0; i < [priorityArray count]; i++) {
		Priority *priority = [priorityArray objectAtIndex:i];
		if ([[priority code] caseInsensitiveCompare:code] == NSOrderedSame) {
			return priority;
		}
	}
	return [Priority NONE];
}

+ (NSArray*)all {
	return priorityArray;
}

+ (NSArray*)allCodes {
	NSMutableArray *ret = [NSMutableArray arrayWithCapacity:priorityArray.count];
	for(Priority *p in priorityArray) {
		[ret addObject:p.code];
	}
	return ret;
}

@end
