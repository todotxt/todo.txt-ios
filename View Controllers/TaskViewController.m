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

#import "TaskViewController.h"
#import "TodoTxtAppDelegate.h"
#import "Task.h"
#import "TaskBag.h"
#import "AsyncTask.h"
#import "UIColor+CustomColors.h"
#import "ActionSheetPicker.h"
#import <CoreText/CoreText.h>

#import "NSMutableAttributedString+TodoTxt.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

char *buttons[] = { "Complete", "Prioritize", "Update", "Delete" };
char *completed_buttons[] = { "Undo Complete", "Delete" }; 

static NSString * const kTaskCellReuseIdentifier = @"kTaskCellReuseIdentifier";

@interface TaskViewController ()

@property (nonatomic, weak) IBOutlet UITextView *textView;

- (void)undo;
- (void)chooseContexts;
- (void)chooseProjects;
- (void)deleteTask;
- (void)didTapCompleteButton;
- (void)didTapPrioritizeButton;
- (void)didTapUndoCompleteButton;
- (void)didTapUpdateButton;
- (void)didTapDeleteButton;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;

@end

@implementation TaskViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIBarButtonItem *contextsButton = [[UIBarButtonItem alloc] initWithTitle:@"Ctx" style:UIBarButtonItemStylePlain target:self action:@selector(chooseContexts)];
    UIBarButtonItem *projectsButton = [[UIBarButtonItem alloc] initWithTitle:@"Pjcts" style:UIBarButtonItemStylePlain target:self action:@selector(chooseProjects)];
    UIBarButtonItem *deleteButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteTask)];
    
    self.navigationItem.rightBarButtonItems = @[ contextsButton, projectsButton, deleteButton ];
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
	
    [[NSNotificationCenter defaultCenter] addObserverForName:kTodoChangedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        // TODO
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark - Private methods

- (void)chooseContexts
{
    
}

- (void)chooseProjects
{
    
}

- (void) deleteTask {
    if (self.task) {
        id<TaskBag> taskBag = [TodoTxtAppDelegate sharedTaskBag];
        Task* task = self.task;
        [taskBag remove:task];
        [TodoTxtAppDelegate displayNotification:@"Deleted task"];
        [TodoTxtAppDelegate pushToRemote];
    }
	 
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) undoCompleteTask {
	id<TaskBag> taskBag = [TodoTxtAppDelegate sharedTaskBag];
	Task* task = self.task;
	[task markIncomplete];
	[taskBag update:task];
	
	[TodoTxtAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) completeTask {
	id<TaskBag> taskBag = [TodoTxtAppDelegate sharedTaskBag];
	Task* task = self.task;
	[task markComplete:[NSDate date]];
	[taskBag update:task];
		
	BOOL auto_archive = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_archive_preference"];
	if (auto_archive) {
		[taskBag archive];
	}
	
	
	if (auto_archive) {
		[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:YES];
		[TodoTxtAppDelegate displayNotification:@"Task completed and archived"];
	} else {
		[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
	}
	[TodoTxtAppDelegate pushToRemote];
}

- (void) prioritizeTask:(Priority*)selectedPriority {
	id<TaskBag> taskBag = [TodoTxtAppDelegate sharedTaskBag];
	Task* task = self.task;
	task.priority = selectedPriority;
	[taskBag update:task];
	
	[TodoTxtAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) priorityWasSelected:(NSNumber *)selectedIndex:(id)element {
	//TODO: progress dialog
	if (selectedIndex.intValue >= 0) {
		Priority *selectedPriority = [Priority byName:(PriorityName)selectedIndex.intValue];
		[AsyncTask runTask:@selector(prioritizeTask:) onTarget:self withArgument:selectedPriority];		
	}
}

- (void) didTapCompleteButton {
	NSLog(@"didTapCompleteButton called");
	if (self.task.completed) {
		//TODO: make toast "Task already complete"
		// Really, this should never happen since
		// the complete option is not available for completed tasks.
		return;
	}
    //TODO: progress dialog
	[AsyncTask runTask:@selector(completeTask) onTarget:self];	
}

- (void) didTapPrioritizeButton {
}

- (void) didTapUpdateButton {	
}

- (void) didTapDeleteButton {
	NSLog(@"didTapDeleteButton called");
	// confirmation pane
	UIActionSheet* dlg = [[UIActionSheet alloc] 
					  initWithTitle:@"This cannot be undone. Are you sure?"
					  delegate:self 
					  cancelButtonTitle:@"Cancel" 
					  destructiveButtonTitle:@"Delete Task" 
					  otherButtonTitles:nil];
	dlg.tag = 10;
	[dlg showInView:self.view];
}

- (void) didTapUndoCompleteButton {
	NSLog(@"didTapUndoCompleteButton called");
	// confirmation pane
	UIActionSheet* dlg = [[UIActionSheet alloc] 
						  initWithTitle:@"Are you sure?"
						  delegate:self 
						  cancelButtonTitle:@"Cancel" 
						  destructiveButtonTitle:nil 
						  otherButtonTitles:@"Mark Incomplete", nil ];
	dlg.tag = 20;
	[dlg showInView:self.view];
}

#pragma mark - Notification handlers

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrameEnd = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, CGRectGetHeight(keyboardFrameEnd), 0);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

#pragma mark - Action sheet delegate methods

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 10 && buttonIndex == [actionSheet destructiveButtonIndex]) {
		//TODO: progress dialog
		[AsyncTask runTask:@selector(deleteTask) onTarget:self];
	} else if (actionSheet.tag == 20 && buttonIndex == [actionSheet firstOtherButtonIndex]) {
		//TODO: progress dialog
		[AsyncTask runTask:@selector(undoCompleteTask) onTarget:self];		
	}
}

@end
