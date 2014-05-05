/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2013 Todo.txt contributors (http://todotxt.com)
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

#import "TaskEditViewController.h"
#import "TaskBag.h"
#import "Task.h"
#import "AsyncTask.h"
#import "TodoTxtAppDelegate.h"
#import "ActionSheetPicker.h"
#import "PlaceholderGenerator.h"
#import "PriorityTextSplitter.h"
#import "TaskUtil.h"
#import "Strings.h"

#import <QuartzCore/QuartzCore.h>

#import <ReactiveCocoa/ReactiveCocoa.h>

static NSString * const kTaskDelimiter = @"\n";
static NSString * const kHelpPopoverSegueIdentifier = @"TaskEditHelpPopoverSegue";
static NSString * const kHelpString = @"<html><head><style>body { -webkit-text-size-adjust: none; color: white; font-family: Helvetica; font-size: 14pt;} </style></head><body>"
"<p><strong>Projects</strong> start with a + sign and contain no spaces, like +KitchenRemodel or +Novel.</p>"
"<p><strong>Contexts</strong> (where you will complete a task) start with an @ sign, like @phone or @GroceryStore."
"<p>A task can include any number of projects or contexts.</p>"
"</body></html>";
static NSString *accessability = @"Task Details";

@interface TaskEditViewController () <UIPopoverControllerDelegate>

@property (nonatomic, weak) IBOutlet SSTextView *textView;
// helpView must be strong because it will not always be in a view hierarchy
@property (nonatomic, strong) IBOutlet UIView *helpView;
@property (nonatomic, weak) IBOutlet UIWebView *helpContents;
@property (nonatomic, weak) IBOutlet UIButton *helpCloseButton;
@property (nonatomic, strong) UIPopoverController *helpPopoverController;
@property (nonatomic, strong) ActionSheetPicker *actionSheetPicker;
@property (nonatomic, strong) NSString *curInput;
@property (nonatomic) NSRange curSelectedRange;
@property (nonatomic) BOOL shouldShowPopover;

// TODO: refactor app delegate and remove me
@property (nonatomic, weak) TodoTxtAppDelegate *appDelegate;

@end

@implementation TaskEditViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.appDelegate = (TodoTxtAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (![self.appDelegate isManualMode]) {
		[self.appDelegate syncClient];
	}
	
	self.curInput = [[NSString alloc] init];	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:)
												 name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:)
												 name:UIKeyboardWillHideNotification object:nil];
	
    // Fill in placeholder & 
	self.textView.placeholder = [[PlaceholderGenerator sharedGenerator] randomPlaceholder];
    
    self.textView.isAccessibilityElement = YES;
    self.textView.accessibilityLabel = accessability;
    
    // Setup specific to the iPhone.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // Create the help view for iPhone, a transparent view the same size as
        // the view controller's view, with a web view and a close button.
        CGRect frame = CGRectMake(0, 0, 0, 0);
        frame.size = self.view.frame.size;
        
        UIView *helpView = [[UIView alloc] initWithFrame:frame];
        helpView.alpha = 0.9;
        helpView.backgroundColor = [UIColor blackColor];
        self.helpView = helpView;
        
        // Create the web view for the help view
        UIWebView *webView = [[UIWebView alloc] initWithFrame:helpView.frame];
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        self.helpContents = webView;
        
        [helpView addSubview:webView];
        
        // Create the close button for the help view
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        closeButton.frame = frame;
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [closeButton addTarget:self
                        action:@selector(helpCloseButtonPressed:)
              forControlEvents:UIControlEventTouchUpInside];
        closeButton.hidden = NO;
        self.helpCloseButton = closeButton;
        
        // Add the button to the view
        [helpView addSubview:closeButton];
        
        // Create Auto Layout constraints for the close button:
        // Center it horizontally in its superview, set its width,
        // and place it with the default spacing relative to the bottom of its superview.
        NSDictionary *bindings = NSDictionaryOfVariableBindings(closeButton);
        NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[closeButton(==44)]-|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:bindings];

        NSLayoutConstraint *c1 = [NSLayoutConstraint constraintWithItem:closeButton
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:helpView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0];
        NSLayoutConstraint *c2 = [NSLayoutConstraint constraintWithItem:closeButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1.0
                                                               constant:84];
        
        constraints = [constraints arrayByAddingObjectsFromArray:@[ c1, c2 ]];
        [helpView addConstraints:constraints];
        
        // Set the contents of the web view and style the close button
        [self.helpContents loadHTMLString:kHelpString
                                  baseURL:nil];
        self.helpCloseButton.layer.cornerRadius = 8.0f;
        self.helpCloseButton.layer.masksToBounds = YES;
        self.helpCloseButton.layer.borderWidth = 1.0f;
        self.helpCloseButton.layer.borderColor = [[UIColor whiteColor] CGColor];
    } else {
        // Create the help popover for iPad, a square-ish popover containing a web view.
        CGRect frame = CGRectMake(0, 0, 320, 300);
        
        UIViewController *vc = [[UIViewController alloc] init];
        vc.contentSizeForViewInPopover = frame.size;
        vc.view.frame = frame;
        vc.view.backgroundColor = [UIColor blackColor];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        webView.opaque = NO;
        [webView loadHTMLString:kHelpString baseURL:nil];
        [vc.view addSubview:webView];
        
        UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:vc];
        popoverController.delegate = self;
        self.helpPopoverController = popoverController;
    }
    
    self.shouldShowPopover = YES;
}

- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if (self.task) {
        self.title = @"Edit Task";
		self.textView.text = [self.task inFileFormat];
	} else {
		self.title = @"Add Tasks";
	}
	self.curSelectedRange = self.textView.selectedRange;
	[self.textView becomeFirstResponder];
	
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGRect kbRect = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	kbRect = [self.view convertRect:kbRect toView:nil];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbRect.size.height, 0.0);
    self.textView.contentInset = contentInsets;
    self.textView.scrollIndicatorInsets = contentInsets;
	
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbRect.size.height;
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	self.textView.contentInset = contentInsets;
	self.textView.scrollIndicatorInsets = contentInsets;
}

#pragma mark -
#pragma mark Text view delegate methods

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	self.textView.selectedRange = self.curSelectedRange;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)aTextView {
    
    /*
     You can create the accessory view programmatically (in code), in the same nib file as the view controller's main view, or from a separate nib file. This example illustrates the latter; it means the accessory view is loaded lazily -- only if it is required.
     */
    
    if (self.textView.inputAccessoryView == nil) {
        NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"TaskEditAccessoryView"
                                                       owner:self
                                                     options:nil];
        UIView *accessoryView = views[0];
        
        self.textView.inputAccessoryView = accessoryView;
    }

    self.textView.keyboardType = UIKeyboardTypeDefault;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)aTextView {
	self.curSelectedRange = self.textView.selectedRange;
    [aTextView resignFirstResponder];
    return YES;
}

- (IBAction)cancelButtonPressed:(id)sender {
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)exitController {
	if ([self.delegate respondsToSelector:@selector(taskEditViewController:didUpdateTask:)]) {
        [self.delegate taskEditViewController:self didUpdateTask:self.task];
    }
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addEditTask {
	id<TaskBag> taskBag = self.appDelegate.taskBag;
	
	// FIXME: synchronize?
	if (self.task) {
        self.curInput = [[self.curInput componentsSeparatedByCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                         componentsJoinedByString:@" "];
		[self.task update:self.curInput];
		Task *newTask = [taskBag update:self.task];
		self.task = newTask;
	} else {
        NSArray *tasks = [[[self.curInput componentsSeparatedByString:kTaskDelimiter].rac_sequence
                           filter:^BOOL(NSString *string) {
                               return (string.length > 0) ? YES : NO;
                           }]
                          map:^NSString *(NSString *string) {
                              return [[string componentsSeparatedByCharactersInSet:
                                       [NSCharacterSet whitespaceAndNewlineCharacterSet]]
                                      componentsJoinedByString:@" "];
                          }].array;
        
        if (tasks.count == 0) {
            [self exitController];
            return;
        }
        
		[taskBag addAsTasks:tasks];
	}
	
	[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:YES];
	[self.appDelegate pushToRemote];
}

- (IBAction)doneButtonPressed:(id)sender {
	self.curInput = self.textView.text;
	
	if (self.curInput.length == 0) {
		[self exitController];
		return;
	}
	
	//TODO: progress dialog
	[AsyncTask runTask:@selector(addEditTask) onTarget:self];
    
}

- (IBAction)helpButtonPressed:(id)sender {
	// Close help view if necessary
	[self.helpPopoverController dismissPopoverAnimated:NO];
	
	// Display help text
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Show/hide the help popover on iPad
        if (self.shouldShowPopover) {
            [self.helpPopoverController presentPopoverFromBarButtonItem:self.helpButton
                                               permittedArrowDirections:UIPopoverArrowDirectionDown
                                                               animated:YES];
            
            self.shouldShowPopover = NO;
        } else {
            [self.helpPopoverController dismissPopoverAnimated:YES];
            
            self.shouldShowPopover = YES;
        }
	} else {
		[self.textView resignFirstResponder];
		
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
		self.helpView.frame  = rect;
		self.helpCloseButton.hidden = NO;
        
        // Disable the nav buttons while the help view is visible
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
		[self.view addSubview:self.helpView];
	}
}

- (IBAction)helpCloseButtonPressed:(id)sender {
	CATransition *animation = [CATransition animation];
    [animation setDuration:0.25];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self.view layer] addAnimation:animation forKey:kCATransitionReveal];
	
	[self.helpView removeFromSuperview];
    
    // Re-enable the nav buttons
    self.navigationItem.leftBarButtonItem.enabled = YES;
    self.navigationItem.rightBarButtonItem.enabled = YES;
	[self.textView becomeFirstResponder];
}

- (void) priorityWasSelected:(NSNumber *)selectedIndex element:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		Priority *selectedPriority = [Priority byName:(PriorityName)selectedIndex.intValue];
		NSString *newText = nil;
		if (selectedPriority == [Priority NONE]) {
			newText = [NSString stringWithString:[[PriorityTextSplitter split:self.textView.text] text]];
		} else {
			newText = [NSString stringWithFormat:@"%@ %@",
								 [selectedPriority fileFormat],
								 [[PriorityTextSplitter split:self.textView.text] text]];
		}
		self.curSelectedRange = [Strings calculateSelectedRange:self.curSelectedRange oldText:self.textView.text newText:newText];
		self.textView.text = newText;
		self.textView.selectedRange = self.curSelectedRange;
	}
	[self.textView becomeFirstResponder];
}

- (void) projectWasSelected:(NSNumber *)selectedIndex element:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		id<TaskBag> taskBag = self.appDelegate.taskBag;
		NSString *item = [[taskBag projects] objectAtIndex:selectedIndex.intValue];
		
		if (! [TaskUtil taskHasProject:self.textView.text project:item]) {
			item = [NSString stringWithFormat:@"+%@", item];
			NSString *newText = [Strings insertPaddedString:self.textView.text atRange:self.curSelectedRange withString:item];
			self.curSelectedRange = [Strings calculateSelectedRange:self.curSelectedRange oldText:self.textView.text newText:newText];
			self.textView.text = newText;
			self.textView.selectedRange = self.curSelectedRange;
		}
	}	
	[self.textView becomeFirstResponder];
}

- (void) contextWasSelected:(NSNumber *)selectedIndex element:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		id<TaskBag> taskBag = self.appDelegate.taskBag;
		NSString *item = [[taskBag contexts] objectAtIndex:selectedIndex.intValue];
		
		if (! [TaskUtil taskHasContext:self.textView.text context:item]) {
			item = [NSString stringWithFormat:@"@%@", item];
			NSString *newText = [Strings insertPaddedString:self.textView.text atRange:self.curSelectedRange withString:item];
			self.curSelectedRange = [Strings calculateSelectedRange:self.curSelectedRange oldText:self.textView.text newText:newText];
			self.textView.text = newText;
			self.textView.selectedRange = self.curSelectedRange;
		}
	}	
	[self.textView becomeFirstResponder];
}

- (IBAction) keyboardAccessoryButtonPressed:(id)sender {
	
	id<TaskBag> taskBag = self.appDelegate.taskBag;
    
	[self.actionSheetPicker actionPickerCancel];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //For ipad, we have ample space and it is not necessary to hide the keyboard
        self.appDelegate.lastClickedButton = sender;
		self.curSelectedRange = self.textView.selectedRange;
    } else {
        [self.textView resignFirstResponder];
    }
    
    UIBarButtonItem *button = (UIBarButtonItem*)sender;
 
	if([button.title isEqualToString:@"Context"]) { // Context 
		self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
													  data:[taskBag contexts]
											 selectedIndex:0
													target:self 
													action:@selector(contextWasSelected:element:)
													 title:@"Select Context"
													  rect:CGRectZero
											 barButtonItem:button];			
	} else if([button.title isEqualToString:@"Priority"]) { // Priority 
		NSInteger curPriority = (NSInteger)[[[PriorityTextSplitter split:self.textView.text] priority] name];
		self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
                                                  data:[Priority allCodes]
                                         selectedIndex:curPriority
                                                target:self 
                                                action:@selector(priorityWasSelected:element:)
												 title:@"Select Priority"
												  rect:CGRectZero
										 barButtonItem:button];
        
    } else if([button.title isEqualToString:@"Project"]) { // Priority 
		self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
                                              data:[taskBag projects]
                                     selectedIndex:0
                                            target:self 
                                            action:@selector(projectWasSelected:element:)
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

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.helpPopoverController dismissPopoverAnimated:NO];
	[self.actionSheetPicker actionPickerCancel];
	self.actionSheetPicker = nil;
}

#pragma mark - Popover controller delegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.shouldShowPopover = YES;
}

@end
