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

#import "PlaceholderGenerator.h"

@interface PlaceholderGenerator ()
@property (nonatomic, copy) NSArray* placeholerList;
@end

@implementation PlaceholderGenerator

//
// Boring dispatch_once method of generating a singleton
//
+ (PlaceholderGenerator*)sharedGenerator {
    static dispatch_once_t onceToken;
    __strong static id _sharedObject = nil;
    dispatch_once(&onceToken, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

//
// PlacholderGenerator sources placeholders from a project file named
// placeholders.plist. PlaceholderGenerator assumes this plist contains a single
// array of placeholder strings to display in the TaskEditViewController. The
// array is loaded and stashed away in an instance variable.
//
- (id)init {
    if (self = [super init]) {
        // Load the placeholder list
        NSString* placeholderPlistPath;
        placeholderPlistPath = [[NSBundle mainBundle] pathForResource:@"placeholders"
                                                               ofType:@"plist"];

        NSAssert(placeholderPlistPath != nil,
                 @"Unable to find placeholder.plist in bundle.");

        NSArray* aPlaceholderList;
        aPlaceholderList = [NSArray arrayWithContentsOfFile:placeholderPlistPath];
        NSAssert(aPlaceholderList,
                 @"Unable to load placeholder list from file.");

        self.placeholerList = aPlaceholderList;
    }
    return self;
}

//
// Return a random placeholder string from self.placeholderList
//
- (NSString*)randomPlaceholder {
    NSUInteger randomIndex;
    randomIndex = arc4random() % [self.placeholerList count];
    return [self.placeholerList objectAtIndex:randomIndex];
}

@end
