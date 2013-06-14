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

#import "Priority.h"

static NSArray* priorityArray = nil;

@implementation Priority

@synthesize name, code, listFormat, detailFormat, fileFormat;

- (id)initWithName:(PriorityName)theName withCode:(NSString*)theCode withListFormat:(NSString*)theListFormat withDetailFormat:(NSString*)theDetailFormat withFileFormat:(NSString*)theFileFormat {
	self = [super init];
	if (self) {
		name = theName;
        code = theCode;
        listFormat = theListFormat;
        detailFormat = theDetailFormat;
        fileFormat = theFileFormat;	
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

+(Priority *)priorityWithName:(PriorityName)theName :(NSString*)theCode:(NSString*)theListFormat:(NSString*)theDetailFormat:(NSString*)theFileFormat {
	return [[Priority alloc] initWithName:theName :theCode :theListFormat :theDetailFormat :theFileFormat];
}

+ (void)initialize {
	@synchronized(self) {
		if (!priorityArray) {
			priorityArray = [NSArray arrayWithObjects:
							  [Priority priorityWithName:PriorityNone :@"-" :@" " :@"" :@""],
							  [Priority priorityWithName:PriorityA :@"A" :@"A" :@"A" :@"(A)"],
							  [Priority priorityWithName:PriorityB :@"B" :@"B" :@"B" :@"(B)"],
							  [Priority priorityWithName:PriorityC :@"C" :@"C" :@"C" :@"(C)"],
							  [Priority priorityWithName:PriorityD :@"D" :@"D" :@"D" :@"(D)"],
							  [Priority priorityWithName:PriorityE :@"E" :@"E" :@"E" :@"(E)"],
							  [Priority priorityWithName:PriorityF :@"F" :@"F" :@"F" :@"(F)"],
							  [Priority priorityWithName:PriorityG :@"G" :@"G" :@"G" :@"(G)"],
							  [Priority priorityWithName:PriorityH :@"H" :@"H" :@"H" :@"(H)"],
							  [Priority priorityWithName:PriorityI :@"I" :@"I" :@"I" :@"(I)"],
							  [Priority priorityWithName:PriorityJ :@"J" :@"J" :@"J" :@"(J)"],
							  [Priority priorityWithName:PriorityK :@"K" :@"K" :@"K" :@"(K)"],
							  [Priority priorityWithName:PriorityL :@"L" :@"L" :@"L" :@"(L)"],
							  [Priority priorityWithName:PriorityM :@"M" :@"M" :@"M" :@"(M)"],
							  [Priority priorityWithName:PriorityN :@"N" :@"N" :@"N" :@"(N)"],
							  [Priority priorityWithName:PriorityO :@"O" :@"O" :@"O" :@"(O)"],
							  [Priority priorityWithName:PriorityP :@"P" :@"P" :@"P" :@"(P)"],
							  [Priority priorityWithName:PriorityQ :@"Q" :@"Q" :@"Q" :@"(Q)"],
							  [Priority priorityWithName:PriorityR :@"R" :@"R" :@"R" :@"(R)"],
							  [Priority priorityWithName:PriorityS :@"S" :@"S" :@"S" :@"(S)"],
							  [Priority priorityWithName:PriorityT :@"T" :@"T" :@"T" :@"(T)"],
							  [Priority priorityWithName:PriorityU :@"U" :@"U" :@"U" :@"(U)"],
							  [Priority priorityWithName:PriorityV :@"V" :@"V" :@"V" :@"(V)"],
							  [Priority priorityWithName:PriorityW :@"W" :@"W" :@"W" :@"(W)"],
							  [Priority priorityWithName:PriorityX :@"X" :@"X" :@"X" :@"(X)"],
							  [Priority priorityWithName:PriorityY :@"Y" :@"Y" :@"Y" :@"(Y)"],
							  [Priority priorityWithName:PriorityZ :@"Z" :@"Z" :@"Z" :@"(Z)"],
							  nil
							 ];
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
