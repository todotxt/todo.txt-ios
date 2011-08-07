/**
 *
 * Todo.txt-Touch-iOS/Classes/todo_txt_touch_iosAppDelegate.h
 *
 * Copyright (c) 2009-2011 Gina Trapani, Shawn McGuire
 *
 * LICENSE:
 *
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file (http://todotxt.com).
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
 * @author Gina Trapani <ginatrapani[at]gmail[dot]com>
 * @author Shawn McGuire <mcguiresm[at]gmail[dot]com> 
 * @license http://www.gnu.org/licenses/gpl.html
 * @copyright 2009-2011 Gina Trapani, Shawn McGuire
 *
 *
 * Copyright (c) 2011 Gina Trapani and contributors, http://todotxt.com
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

@synthesize code, listFormat, detailFormat, fileFormat;

- (id)initWithCode:(NSString*)theCode:(NSString*)theListFormat:(NSString*)theDetailFormat:(NSString*)theFileFormat {
	self = [super init];
	if (self) {
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

+ (void)initialize {
	@synchronized(self) {
		if (!priorityArray) {
			priorityArray = [[NSArray arrayWithObjects:
							 [[[Priority alloc] initWithCode:@"-" :@" " :@"" :@""] autorelease],
							 [[[Priority alloc] initWithCode:@"A" :@"A" :@"A" :@"(A)"] autorelease],
							 [[[Priority alloc] initWithCode:@"B" :@"B" :@"B" :@"(B)"] autorelease],
							 [[[Priority alloc] initWithCode:@"C" :@"C" :@"C" :@"(C)"] autorelease],
							 [[[Priority alloc] initWithCode:@"D" :@"D" :@"D" :@"(D)"] autorelease],
							 [[[Priority alloc] initWithCode:@"E" :@"E" :@"E" :@"(E)"] autorelease],
							 [[[Priority alloc] initWithCode:@"F" :@"F" :@"F" :@"(F)"] autorelease],
							 [[[Priority alloc] initWithCode:@"G" :@"G" :@"G" :@"(G)"] autorelease],
							 [[[Priority alloc] initWithCode:@"H" :@"H" :@"H" :@"(H)"] autorelease],
							 [[[Priority alloc] initWithCode:@"I" :@"I" :@"I" :@"(I)"] autorelease],
							 [[[Priority alloc] initWithCode:@"J" :@"J" :@"J" :@"(J)"] autorelease],
							 [[[Priority alloc] initWithCode:@"K" :@"K" :@"K" :@"(K)"] autorelease],
							 [[[Priority alloc] initWithCode:@"L" :@"L" :@"L" :@"(L)"] autorelease],
							 [[[Priority alloc] initWithCode:@"M" :@"M" :@"M" :@"(M)"] autorelease],
							 [[[Priority alloc] initWithCode:@"N" :@"N" :@"N" :@"(N)"] autorelease],
							 [[[Priority alloc] initWithCode:@"O" :@"O" :@"O" :@"(O)"] autorelease],
							 [[[Priority alloc] initWithCode:@"P" :@"P" :@"P" :@"(P)"] autorelease],
							 [[[Priority alloc] initWithCode:@"Q" :@"Q" :@"Q" :@"(Q)"] autorelease],
							 [[[Priority alloc] initWithCode:@"R" :@"R" :@"R" :@"(R)"] autorelease],
							 [[[Priority alloc] initWithCode:@"S" :@"S" :@"S" :@"(S)"] autorelease],
							 [[[Priority alloc] initWithCode:@"T" :@"T" :@"T" :@"(T)"] autorelease],
							 [[[Priority alloc] initWithCode:@"U" :@"U" :@"U" :@"(U)"] autorelease],
							 [[[Priority alloc] initWithCode:@"V" :@"V" :@"V" :@"(V)"] autorelease],
							 [[[Priority alloc] initWithCode:@"W" :@"W" :@"W" :@"(W)"] autorelease],
							 [[[Priority alloc] initWithCode:@"X" :@"X" :@"X" :@"(X)"] autorelease],
							 [[[Priority alloc] initWithCode:@"Y" :@"Y" :@"Y" :@"(Y)"] autorelease],
							 [[[Priority alloc] initWithCode:@"Z" :@"Z" :@"Z" :@"(Z)"] autorelease],
							 nil
							 ] retain];
		}
	}
}

+ (Priority*)priorityWithName:(PriorityName)name {
	return [priorityArray objectAtIndex:name];
}

+ (Priority*)NONE {
	return [Priority priorityWithName:PriorityNone];
}

+ (Priority*)priorityWithCode:(NSString*)code {
	for (int i = 0; i < [priorityArray count]; i++) {
		Priority *priority = [priorityArray objectAtIndex:i];
		if ([[priority code] caseInsensitiveCompare:code] == NSOrderedSame) {
			return priority;
		}
	}
	return [Priority NONE];
}

@end
