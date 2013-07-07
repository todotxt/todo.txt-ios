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

#import "TaskViewCell.h"
#import "AttributedLabel.h"

@interface TaskViewCell ()
@property (retain, readwrite) AttributedLabel *taskLabel;

@end

@implementation TaskViewCell

#define LABELTAG 3
#define TEXTLEFTLONG 47
#define TEXTLEFTSHORT 29

@synthesize taskLabel;


- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];

	if (self) {
		for (UIView *subview in [self.contentView subviews]) {
			if (subview.tag == LABELTAG) {
				[subview removeFromSuperview];
			}
		}
		
		self.taskLabel = [[[AttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
        self.taskLabel.backgroundColor = [UIColor clearColor];
		
		self.taskLabel.tag = LABELTAG;
		
		[self.contentView addSubview:self.taskLabel];
    }

	return(self);
}

- (void)dealloc {
	self.taskLabel = nil;
	[super dealloc];
}

- (void)nudge:(UIView *)label numberedxpos:(CGFloat)numberedxpos barexpos:(CGFloat)barexpos ypos:(CGFloat)ypos height:(CGFloat)height
{
	
	CGRect frame = label.frame;
	frame.origin.x = barexpos;
	
	if (ypos >= 0)
	{
		frame.origin.y = ypos;
	}
	
	if (height >= 0)
	{
		frame.size.height = height;
	}
	
	label.frame = frame;
}


- (void)nudge:(UIView *)label numberedxpos:(CGFloat)numberedxpos barexpos:(CGFloat)barexpos
{
	[self nudge:label numberedxpos:numberedxpos barexpos:barexpos ypos:-1 height:-1];
}


- (void)nudge:(UIView *)label xpos:(CGFloat)xpos ypos:(CGFloat)ypos
{
	[self nudge:label numberedxpos:xpos barexpos:xpos ypos:ypos height:-1];
}

- (void)nudge:(UIView *)label xpos:(CGFloat)xpos
{
	[self nudge:label numberedxpos:xpos barexpos:xpos];
}


- (void)layoutSubviews
{
	[super layoutSubviews];
	
	UILabel *priority = (UILabel *)[self viewWithTag:2];
	UIView *text = (UIView *)[self viewWithTag:LABELTAG];
	
	CGFloat maxWidth = 999;
	CGFloat maxHeight = 9999;
	CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
		
	CGSize expectedLabelSize = [[priority text] 
								sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f]
								constrainedToSize:maximumLabelSize 
								lineBreakMode:UILineBreakModeWordWrap]; 

	[self nudge:text numberedxpos:TEXTLEFTLONG barexpos:TEXTLEFTSHORT];
	[self nudge:priority numberedxpos:30 barexpos:12 ypos:text.frame.origin.y height:expectedLabelSize.height];
	
	UILabel *date = (UILabel *)[self viewWithTag:4];
	CGFloat dateTop = text.frame.origin.y + text.frame.size.height;
	[self nudge:date numberedxpos:TEXTLEFTLONG barexpos:TEXTLEFTSHORT ypos:dateTop height:-1];
}


@end
