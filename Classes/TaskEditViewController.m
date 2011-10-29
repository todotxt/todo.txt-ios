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

#import "TaskEditViewController.h"
#import "TaskBag.h"
#import "Task.h"
#import "AsyncTask.h"
#import "todo_txt_touch_iosAppDelegate.h"
#import "ActionSheetPicker.h"
#import "PriorityTextSplitter.h"
#import "TestFlight.h"

#define SINGLE_SPACE ' '

NSRange calculateSelectedRange(NSRange oldRange, NSString *oldText, NSString* newText) {
	NSUInteger length = oldRange.length;
	
	if (newText == nil) {
		return NSMakeRange(0, length);
	}
	
	if (oldText == nil) {
		return NSMakeRange(newText.length, 0);
	}
	
	NSInteger pos = oldRange.location + (newText.length - oldText.length);
	pos = pos < 0 ? 0 : pos;
	pos = pos > newText.length ? newText.length : pos;

	return NSMakeRange(pos, length);
}

NSString* insertPadded(NSString *s, NSRange insertAt, NSString *stringToInsert) {
	NSMutableString *newText = [NSMutableString stringWithCapacity:(s.length + stringToInsert.length + 2)];
	
	if (insertAt.location > 0) {
		[newText appendString:[s substringToIndex:(insertAt.location)]];
		if ([newText characterAtIndex:(newText.length - 1)] != SINGLE_SPACE) {
			[newText appendFormat:@"%c", SINGLE_SPACE];
		}
		[newText appendString:stringToInsert];
		NSUInteger pos = NSMaxRange(insertAt);
		NSString *postItem = [s substringFromIndex:pos];
		if (postItem.length > 0) {
			if ([postItem characterAtIndex:0] != SINGLE_SPACE) {
				[newText appendFormat:@"%c", SINGLE_SPACE];
			}
			[newText appendString:postItem];
		}
	} else {
		[newText appendString:stringToInsert];
		if (s.length > 0 && [s characterAtIndex:(s.length - 1)] != SINGLE_SPACE) {
			[newText appendFormat:@"%c", SINGLE_SPACE];
		}	
		[newText appendString:s];
	}
	
	return newText;
}

@implementation TaskEditViewController

@synthesize delegate, textView, accessoryView, task;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	curInput = [[NSString alloc] init];	
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (task) {
		self.title = @"Edit Task";	
		textView.text = [task inFileFormat];
	} else {
		self.title = @"Add Task";
	}
	curSelectedRange = textView.selectedRange;
	[textView becomeFirstResponder];
	
}

#pragma mark -
#pragma mark Text view delegate methods

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	textView.selectedRange = curSelectedRange;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    /*
     You can create the accessory view programmatically (in code), in the same nib file as the view controller's main view, or from a separate nib file. This example illustrates the latter; it means the accessory view is loaded lazily -- only if it is required.
     */
    
    if (textView.inputAccessoryView == nil) {
        [[NSBundle mainBundle] loadNibNamed:@"TaskEditAccessoryView" owner:self options:nil];
        // Loading the AccessoryView nib file sets the accessoryView outlet.
        textView.inputAccessoryView = accessoryView;    
        // After setting the accessory view for the text view, we no longer need a reference to the accessory view.
        self.accessoryView = nil;
    }

    textView.keyboardType = UIKeyboardTypeDefault;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
	curSelectedRange = textView.selectedRange;
    [aTextView resignFirstResponder];
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self dismissModalViewControllerAnimated:YES];	
}

-(void)exitController {
	if ([delegate respondsToSelector:@selector(taskEditViewController:didUpdateTask:)]) {
        [delegate taskEditViewController:self didUpdateTask:task];
    }
	[self dismissModalViewControllerAnimated:YES];
}

- (void) addEditTask {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	
	// FIXME: synchronize?
	if (task) {
		[task update:curInput];
		Task *newTask = [taskBag update:task];
		[task release];
		task = [newTask retain];
	} else {
		[taskBag addAsTask:curInput];
	}
	
	//TODO: toast?
	[todo_txt_touch_iosAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:NO];
}

- (IBAction)doneButtonPressed:(id)sender {
	curInput = [[[[textView text] 
		componentsSeparatedByCharactersInSet:
			[NSCharacterSet whitespaceAndNewlineCharacterSet]]
			   componentsJoinedByString:@" "] retain];
	
	if (curInput.length == 0) {
		[self exitController];
		return;
	}
	
	//TODO: progress dialog
	[AsyncTask runTask:@selector(addEditTask) onTarget:self];
    
}

- (IBAction)helpButtonPressed:(id)sender {
	// Display help text
}

- (void) priorityWasSelected:(NSNumber *)selectedIndex:(id)element {
	Priority *selectedPriority = [Priority byName:(PriorityName)selectedIndex.intValue];
	NSString *newText = [NSString stringWithFormat:@"%@ %@",
						 [selectedPriority fileFormat],
						 [[PriorityTextSplitter split:textView.text] text]];
	curSelectedRange = calculateSelectedRange(curSelectedRange, textView.text, newText);
	textView.text = newText;

	[textView becomeFirstResponder];
}

- (void) projectWasSelected:(NSNumber *)selectedIndex:(id)element {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	NSString *item = [[taskBag projects] objectAtIndex:selectedIndex.intValue];
	item = [NSString stringWithFormat:@"+%@", item];
	NSString *newText = insertPadded(textView.text, curSelectedRange, item);
	curSelectedRange = calculateSelectedRange(curSelectedRange, textView.text, newText);
	textView.text = newText;
	
	[textView becomeFirstResponder];
}

- (void) contextWasSelected:(NSNumber *)selectedIndex:(id)element {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	NSString *item = [[taskBag contexts] objectAtIndex:selectedIndex.intValue];
	item = [NSString stringWithFormat:@"@%@", item];
	NSString *newText = insertPadded(textView.text, curSelectedRange, item);
	curSelectedRange = calculateSelectedRange(curSelectedRange, textView.text, newText);
	textView.text = newText;
	
	[textView becomeFirstResponder];
}

- (IBAction)segmentControlPressed:(id)sender {
	[textView resignFirstResponder];

	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
	
	switch (segmentedControl.selectedSegmentIndex) {
		case 0: // Priority
			[ActionSheetPicker displayActionPickerWithView:self.view 
													  data:[Priority allCodes]
											 selectedIndex:0
													target:self 
													action:@selector(priorityWasSelected::) 
													 title:@"Select Priority"];
			break;
		case 1: // Project
			[ActionSheetPicker displayActionPickerWithView:self.view 
													  data:[taskBag projects]
											 selectedIndex:0
													target:self 
													action:@selector(projectWasSelected::) 
													 title:@"Select Project"];			
			break;
		case 2: // Context
			[ActionSheetPicker displayActionPickerWithView:self.view 
													  data:[taskBag contexts]
											 selectedIndex:0
													target:self 
													action:@selector(contextWasSelected::) 
													 title:@"Select Context"];			
			break;			
	}
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[curInput release];
	curInput = nil;
	[task release];
}

- (void)dealloc {		
	[textView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 return YES;
}

@end
