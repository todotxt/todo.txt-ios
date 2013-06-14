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
#import <CoreText/CoreText.h>
#import "AttributedLabel.h"

@implementation AttributedLabel
@synthesize text=_text;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setText:(NSAttributedString *)someText {
    if (_text != someText) {
        [someText retain];
        [_text release];
        _text = someText;
        [self setNeedsDisplay];
    }
}

//
// Many thanks to CocoaNetics for the excellent writeup on creating
// strikethrough text!
// http://www.cocoanetics.com/2011/01/befriending-core-text/
//
- (void)drawRect:(CGRect)rect {
    // layout master
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.text);

    // rect format
    CGMutablePathRef textPath = CGPathCreateMutable();
    CGPathAddRect(textPath, NULL, self.bounds);
    // rect frame
    CTFrameRef textFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), textPath, NULL);

	// now for the actual drawing
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	// draw
    CTFrameDraw(textFrame, context);

    // reset text position
    CGContextSetTextPosition(context, 0, 0);

    // get lines
    CFArrayRef leftLines = CTFrameGetLines(textFrame);
    CGPoint *origins = malloc(sizeof(CGPoint)*[(NSArray *)leftLines count]);
    CTFrameGetLineOrigins(textFrame,
                          CFRangeMake(0, 0), origins);
    NSInteger lineIndex = 0;

    for (id oneLine in (NSArray *)leftLines)
    {
        CFArrayRef runs = CTLineGetGlyphRuns((CTLineRef)oneLine);
        CGRect lineBounds = CTLineGetImageBounds((CTLineRef)oneLine, context);

        lineBounds.origin.x += origins[lineIndex].x;
        lineBounds.origin.y += origins[lineIndex].y;
        lineIndex++;
        CGFloat offset = 0;

        for (id oneRun in (NSArray *)runs)
        {
            CGFloat ascent = 0;
            CGFloat descent = 0;

            CGFloat width = CTRunGetTypographicBounds((CTRunRef) oneRun,
                                                      CFRangeMake(0, 0),
                                                      &ascent,
                                                      &descent, NULL);

            NSDictionary *attributes = (NSDictionary *)CTRunGetAttributes((CTRunRef) oneRun);

            BOOL strikeOut = [[attributes objectForKey:kTTStrikethroughAttributeName] boolValue];

            if (strikeOut)
            {
                CGRect bounds = CGRectMake(lineBounds.origin.x + offset,
                                           lineBounds.origin.y,
                                           width, ascent + descent);

                // don't draw too far to the right
                if (bounds.origin.x + bounds.size.width > CGRectGetMaxX(lineBounds))
                {
                    bounds.size.width = CGRectGetMaxX(lineBounds) - bounds.origin.x;
                }

                // get text color or use black
                id color = [attributes objectForKey:(id)kCTForegroundColorAttributeName];

                if (color)
                {
                    CGContextSetStrokeColorWithColor(context, (CGColorRef)color);
                }
                else
                {
                    CGContextSetGrayStrokeColor(context, 0, 1.0);
                }

                CGFloat y = roundf(bounds.origin.y + bounds.size.height / 2.0);
                CGContextMoveToPoint(context, bounds.origin.x, y);
                CGContextAddLineToPoint(context, bounds.origin.x + bounds.size.width, y);

                CGContextStrokePath(context);
            }

            offset += width;
        }
    }

    // cleanup
    free(origins);
    CGPathRelease(textPath);
    CFRelease(textFrame);
    CFRelease(framesetter);
}

@end
