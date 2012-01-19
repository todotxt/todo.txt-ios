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
#import "Color.h"

@implementation UIColor(HexValues)

+ (UIColor*) colorWithHex:(NSUInteger)hexValue {
	
	return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
						   green:((float)((hexValue & 0xFF00) >> 8))/255.0 
							blue:((float)(hexValue & 0xFF))/255.0 
						   alpha:1.0];
}

@end

@implementation Color

+ (UIColor*) green {
	static const UIColor *sGreen = nil;
	if(!sGreen) sGreen = [[UIColor colorWithHex:0x587058] retain];
	return (UIColor*)sGreen;
}

+ (UIColor*) blue {
	static UIColor *sBlue = nil;
	if(!sBlue) sBlue = [[UIColor colorWithHex:0x587498] retain];
	return sBlue;
}

+ (UIColor*) gold {
	static UIColor *sGold = nil;
	if(!sGold) sGold = [[UIColor colorWithHex:0xFFD800] retain];
	return sGold;
}

+ (UIColor*) orange {
	static UIColor *sOrange = nil;
	if(!sOrange) sOrange = [[UIColor colorWithHex:0xE86850] retain];
	return sOrange;
}

+ (UIColor*) black {
	static UIColor *sBlack = nil;
	if(!sBlack) sBlack = [[UIColor colorWithHex:0x000000] retain];
	return sBlack;
}



@end
