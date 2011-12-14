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
#import "TaskUtil.h"
#import <QuartzCore/QuartzCore.h>

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
		if (newText.length > 0 && [newText characterAtIndex:(newText.length - 1)] != SINGLE_SPACE) {
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
		if (s.length > 0 && [s characterAtIndex:0] != SINGLE_SPACE) {
			[newText appendFormat:@"%c", SINGLE_SPACE];
		}	
		[newText appendString:s];
	}
	
	if (newText.length > 0 && [newText characterAtIndex:(newText.length - 1)] != SINGLE_SPACE) {
		[newText appendFormat:@"%c", SINGLE_SPACE];
	}
	
	return newText;
}

@implementation TaskEditViewController

@synthesize delegate, navItem, textView, accessoryView, task, helpView, helpContents, helpCloseButton, popOverController, actionSheetPicker;

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
	
	textView.placeholder = @"Call Mom @phone +FamilialPeace";
	
	[helpContents loadHTMLString:@"<html><head><style>body { -webkit-text-size-adjust: none; color: white; font-family: Helvetica; font-size: 14pt;} </style></head><body>"
	 "<p><strong>Projects</strong> start with a + sign and contain no spaces, like +KitchenRemodel or +Novel.</p>"
	 "<p><strong>Contexts</strong> (where you will complete a task) start with an @ sign, like @phone or @GroceryStore."
	 "<p>A task can include any number of projects or contexts.</p>"
	 "</body></html>"
						 baseURL:nil];
	helpCloseButton.layer.cornerRadius = 8.0f;
	helpCloseButton.layer.masksToBounds = YES;
	helpCloseButton.layer.borderWidth = 1.0f;
	helpCloseButton.layer.borderColor = [[UIColor whiteColor] CGColor];
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (task) {
		self.navItem.title = @"Edit Task";	
		self.navItem.rightBarButtonItem.title = @"Done";
		textView.text = [task inFileFormat];
	} else {
		self.navItem.title = @"Add Task";
		self.navItem.rightBarButtonItem.title = @"Add";
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
	// Close help view if necessary
	[self.popOverController dismissPopoverAnimated:NO];
	
	// Display help text
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		CGSize size;
		if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
			size = CGSizeMake(320, 380);
		} else {
			size = CGSizeMake(460, 300);			
		}
		const CGRect rect = (CGRect){CGPointZero,size};		
		helpView.frame  = rect;
		//spawn popovercontroller
		UIViewController *viewController = [[[UIViewController alloc] initWithNibName:nil bundle:nil] autorelease];
		viewController.view = helpView;
		viewController.contentSizeForViewInPopover = viewController.view.frame.size;
		self.popOverController = [[UIPopoverController alloc] initWithContentViewController:viewController];
		helpCloseButton.hidden = YES;
        [popOverController presentPopoverFromBarButtonItem:sender
                                       permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
	} else {
		[textView resignFirstResponder];
		
		CATransition *animation = [CATransition animation];
		[animation setDuration:0.25];
		[animation setType:kCATransitionFade];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
		[[self.view layer] addAnimation:animation forKey:kCATransitionReveal];
		
		CGSize size;
		if (self.interfaceOrientation == UIDeviceOrientationPortrait) {
			size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
		} else {
			size = CGSizeMake(self.view.frame.size.height, self.view.frame.size.width);			
		}
		const CGRect rect = (CGRect){CGPointZero,size};		
		helpView.frame  = rect;
		helpCloseButton.hidden = NO;
		[self.view addSubview:helpView];
	}
}

- (IBAction)helpCloseButtonPressed:(id)sender {
	CATransition *animation = [CATransition animation];
    [animation setDuration:0.25];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.view layer] addAnimation:animation forKey:kCATransitionReveal];
	
	[helpView removeFromSuperview];

	[textView becomeFirstResponder];
}

- (void) priorityWasSelected:(NSNumber *)selectedIndex:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		Priority *selectedPriority = [Priority byName:(PriorityName)selectedIndex.intValue];
		NSString *newText = nil;
		if (selectedPriority == [Priority NONE]) {
			newText = [NSString stringWithString:[[PriorityTextSplitter split:textView.text] text]];
		} else {
			newText = [NSString stringWithFormat:@"%@ %@",
								 [selectedPriority fileFormat],
								 [[PriorityTextSplitter split:textView.text] text]];
		}
		curSelectedRange = calculateSelectedRange(curSelectedRange, textView.text, newText);
		textView.text = newText;
		textView.selectedRange = curSelectedRange;
	}
	[textView becomeFirstResponder];
}

- (void) projectWasSelected:(NSNumber *)selectedIndex:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
		NSString *item = [[taskBag projects] objectAtIndex:selectedIndex.intValue];
		
		if (! [TaskUtil taskHasProject:textView.text project:item]) {
			item = [NSString stringWithFormat:@"+%@", item];
			NSString *newText = insertPadded(textView.text, curSelectedRange, item);
			curSelectedRange = calculateSelectedRange(curSelectedRange, textView.text, newText);
			textView.text = newText;
			textView.selectedRange = curSelectedRange;
		}
	}	
	[textView becomeFirstResponder];
}

- (void) contextWasSelected:(NSNumber *)selectedIndex:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
		NSString *item = [[taskBag contexts] objectAtIndex:selectedIndex.intValue];
		
		if (! [TaskUtil taskHasContext:textView.text context:item]) {
			item = [NSString stringWithFormat:@"@%@", item];
			NSString *newText = insertPadded(textView.text, curSelectedRange, item);
			curSelectedRange = calculateSelectedRange(curSelectedRange, textView.text, newText);
			textView.text = newText;
			textView.selectedRange = curSelectedRange;
		}
	}	
	[textView becomeFirstResponder];
}

- (IBAction) keyboardAccessoryButtonPressed:(id)sender {
	
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
    
	[actionSheetPicker actionPickerCancel];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //For ipad, we have ample space and it is not necessary to hide the keyboard
        todo_txt_touch_iosAppDelegate *appdelegate = (todo_txt_touch_iosAppDelegate*)[[UIApplication sharedApplication] delegate];
        appdelegate.lastClickedButton = sender;
		curSelectedRange = textView.selectedRange;
    } else {
        [textView resignFirstResponder];
    }
    
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
 
	if([button.title isEqualToString:@"Context"]) { // Context 
		self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
													  data:[taskBag contexts]
											 selectedIndex:0
													target:self 
													action:@selector(contextWasSelected::) 
													 title:@"Select Context"
													  rect:CGRectZero
											 barButtonItem:button];			
	} else if([button.title isEqualToString:@"Priority"]) { // Priority 
		NSInteger curPriority = (NSInteger)[[[PriorityTextSplitter split:textView.text] priority] name];
		self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
                                                  data:[Priority allCodes]
                                         selectedIndex:curPriority
                                                target:self 
                                                action:@selector(priorityWasSelected::) 
												 title:@"Select Priority"
												  rect:CGRectZero
										 barButtonItem:button];
        
    } else if([button.title isEqualToString:@"Project"]) { // Priority 
		self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
                                              data:[taskBag projects]
                                     selectedIndex:0
                                            target:self 
                                            action:@selector(projectWasSelected::) 
											 title:@"Select Project"
											  rect:CGRectZero
									 barButtonItem:button];			
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
	self.navItem = nil;
	self.task = nil;
	self.helpView = nil;
	self.helpContents = nil;
	self.helpCloseButton = nil;
	self.popOverController = nil;
	self.actionSheetPicker = nil;
}

- (void)dealloc {
	[navItem release];
	[textView release];
	[helpView release];
	[helpContents release];
	[helpCloseButton release];
	[popOverController release];
	[actionSheetPicker release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[popOverController dismissPopoverAnimated:NO];
	[actionSheetPicker actionPickerCancel];
	self.actionSheetPicker = nil;
}


@end
