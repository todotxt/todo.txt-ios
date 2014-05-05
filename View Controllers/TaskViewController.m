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

#import "TaskViewController.h"
#import "TodoTxtAppDelegate.h"
#import "Task.h"
#import "TaskEditViewController.h"
#import "TaskBag.h"
#import "AsyncTask.h"
#import "UIColor+CustomColors.h"
#import "ActionSheetPicker.h"
#import "TaskCell.h"
#import "TaskCellViewModel.h"
#import <CoreText/CoreText.h>

#import "NSMutableAttributedString+TodoTxt.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#define MIN_ROW_HEIGHT 50
#define ACTION_ROW_HEIGHT 50
#define DETAIL_CELL_PADDING 10

static NSString * const kTaskCellReuseIdentifier = @"kTaskCellReuseIdentifier";
static NSString * const kTaskEditSegueIdentifier = @"TaskEditSegue";

static CGFloat const kIphoneGroupedTableViewSideInset = 10;
static CGFloat const kIpadGroupedTableViewSideInset = 40;

@interface TaskViewController ()

@property (nonatomic, strong) TaskCell *taskCell;
@property (nonatomic, strong) ActionSheetPicker *actionSheetPicker;
@property (nonatomic, strong) NSArray *buttonNames;
@property (nonatomic, strong) NSArray *completedButtonNames;

// TODO: refactor app delegate and remove me
@property (nonatomic, weak) TodoTxtAppDelegate *appDelegate;

@end

@implementation TaskViewController

- (Task *)task {
	return [self.appDelegate.taskBag taskAtIndex:self.taskIndex];
}

- (void)reloadViewData {
	// Scroll the table view to the top before it appears
	[self.appDelegate.taskBag reload];

	self.taskCell = nil;
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];

}

#pragma mark -
#pragma mark View lifecycle

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.appDelegate = (TodoTxtAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

- (void)viewDidLoad
{
    self.buttonNames = @[ @"Complete", @"Prioritize", @"Update", @"Delete" ];
    self.completedButtonNames = @[ @"Undo Complete", @"Delete" ];
}

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
	
 	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reloadViewData) 
												 name:kTodoChangedNotification 
											   object:nil];
   
	[self reloadViewData];
	
    self.title = @"Task Details";
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];	
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // There are 2 sections, one for the text, the other for the buttons
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	Task* task = [self task];
	
	/*
	 The number of rows varies by section.
	 */
    NSInteger rows = 0;
    switch (section) {
        case 0:        
            // For the text, there is one row.
            rows = 1;
            break;
        case 1:
            if ([task completed]) {
				rows = self.completedButtonNames.count;
			} else { 
				rows = self.buttonNames.count;
			}
            break;
        default:
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		Task* task = [self task];
        
        CGFloat sideInset = kIphoneGroupedTableViewSideInset;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            sideInset = kIpadGroupedTableViewSideInset;
        }
        
        CGFloat height = [TaskCell heightForText:task.text
                                        withFont:[UIFont systemFontOfSize:14]
                                           width:CGRectGetWidth(tableView.frame) - 2 * sideInset];
		
		return MAX(height, MIN_ROW_HEIGHT);
	} else {
		return ACTION_ROW_HEIGHT;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0) {
		return [NSString stringWithFormat:@""];
	} else {
		return @"Actions";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
	
    // Set the text in the cell for the section/row.
	if (indexPath.section == 0) {
        if (!self.taskCell) {
            [tableView registerClass:[TaskCell class]
              forCellReuseIdentifier:kTaskCellReuseIdentifier];
            TaskCell *taskCell = [tableView dequeueReusableCellWithIdentifier:kTaskCellReuseIdentifier];
            Task *task = [self task];
            TaskCellViewModel *viewModel = [[TaskCellViewModel alloc] init];
            viewModel.task = task;
            
            taskCell.viewModel = viewModel;
            
            // Use RAC(...) as usual here, since this cell is created once and never re-used.
            RAC(taskCell.taskTextView, attributedText) = [RACObserve(viewModel, attributedText) distinctUntilChanged];
            RAC(taskCell.taskTextView, accessibilityLabel) = [RACObserve(viewModel, accessibleText) distinctUntilChanged];
            RAC(taskCell.ageLabel, text) = [RACObserve(viewModel, ageText) distinctUntilChanged];
            RAC(taskCell.priorityLabel, text) = [RACObserve(viewModel, priorityText) distinctUntilChanged];
            RAC(taskCell.priorityLabel, textColor) = [RACObserve(viewModel, priorityColor) distinctUntilChanged];
            RAC(taskCell, shouldShowDate) = RACObserve(viewModel, shouldShowDate);
            
            taskCell.viewModel = viewModel;
            
            self.taskCell = taskCell;
        }
        
        cell = self.taskCell;
	} else {
		static NSString *CellIdentifier = @"CellIdentifier";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		cell.textLabel.textAlignment = NSTextAlignmentCenter;

		if([[self task] completed]) {
			cell.textLabel.text = self.completedButtonNames[indexPath.row];
		} else {
			cell.textLabel.text = self.buttonNames[indexPath.row];
		}
    }

    return cell;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.tableView reloadData];
}

// Load the detail view controller when user taps the row
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:NO];
	Task * task = [self task];
	
	// Tapping the detail view triggers the update option
	if (indexPath.section == 0) {
		if (![task completed]) {
			[self didTapUpdateButton];
		}
		return;
	}
	
	// Handle other button taps
	if ([task completed]) {
		switch (indexPath.row) {
			case 0: //Undo Complete
				[self didTapUndoCompleteButton];
				break;
			case 1: //Delete
				[self didTapDeleteButton];
				break;
				
			default:
				break;
		}
	} else {
		switch (indexPath.row) {
			case 0: // Complete
				[self didTapCompleteButton];
				break;
			case 1: // Prioritize
				[self didTapPrioritizeButton];
				break;
			case 2: // Update
				[self didTapUpdateButton];
				break;
			case 3: // Delete
				[self didTapDeleteButton];
				break;
				
			default:
				break;
		}
	}
}

-(void)exitController {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void) deleteTask {
    if (self.task) {
        id<TaskBag> taskBag = self.appDelegate.taskBag;
        Task* task = self.task;
        [taskBag remove:task];
		[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:YES];
        [self.appDelegate displayNotification:@"Deleted task"];
        [self.appDelegate pushToRemote];
    }
}

- (void) undoCompleteTask {
	id<TaskBag> taskBag = self.appDelegate.taskBag;
	Task* task = self.task;
	[task markIncomplete];
	[taskBag update:task];
	
	[self.appDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) completeTask {
	id<TaskBag> taskBag = self.appDelegate.taskBag;
	Task* task = self.task;
	[task markComplete:[NSDate date]];
	[taskBag update:task];
		
	BOOL auto_archive = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_archive_preference"];
	if (auto_archive) {
		[taskBag archive];
	}
	
	
	if (auto_archive) {
		[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:YES];
		[self.appDelegate displayNotification:@"Task completed and archived"];
	} else {
		[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
	}
	[self.appDelegate pushToRemote];
}

- (void) prioritizeTask:(Priority*)selectedPriority {
	id<TaskBag> taskBag = self.appDelegate.taskBag;
	Task* task = self.task;
	task.priority = selectedPriority;
	[taskBag update:task];
	
	[self.appDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) priorityWasSelected:(NSNumber *)selectedIndex element:(id)element {
	//TODO: progress dialog
	if (selectedIndex.intValue >= 0) {
		Priority *selectedPriority = [Priority byName:(PriorityName)selectedIndex.intValue];
		[AsyncTask runTask:@selector(prioritizeTask:) onTarget:self withArgument:selectedPriority];		
	}
}

- (void) didTapCompleteButton {
	NSLog(@"didTapCompleteButton called");
	Task* task = [self task];
	if ([task completed]) {
		//TODO: make toast "Task already complete"
		// Really, this should never happen since
		// the complete option is not available for completed tasks.
		return;
	}
    //TODO: progress dialog
	[AsyncTask runTask:@selector(completeTask) onTarget:self];	
}

- (void) didTapPrioritizeButton {
	NSLog(@"didTapPrioritizeButton called");
	[self.actionSheetPicker actionPickerCancel];
	NSInteger curPriority = (NSInteger)[[[self task] priority] name];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]; //FIXME: don't hardcode this
	self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
						data:[Priority allCodes]
						selectedIndex:curPriority 
						target:self 
						action:@selector(priorityWasSelected:element:)
						title:@"Select Priority"
						 rect:cell.frame
				barButtonItem:nil];
}

- (void) didTapUpdateButton {
	NSLog(@"didTapUpdateButton called");
    [self performSegueWithIdentifier:kTaskEditSegueIdentifier sender:self];
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


-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 10 && buttonIndex == [actionSheet destructiveButtonIndex]) {
		//TODO: progress dialog
		[AsyncTask runTask:@selector(deleteTask) onTarget:self];
	} else if (actionSheet.tag == 20 && buttonIndex == [actionSheet firstOtherButtonIndex]) {
		//TODO: progress dialog
		[AsyncTask runTask:@selector(undoCompleteTask) onTarget:self];		
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[self.actionSheetPicker actionPickerCancel];
	self.actionSheetPicker = nil;
}

#pragma mark - Segue methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kTaskEditSegueIdentifier]) {
        TaskEditViewController *taskEditView = (TaskEditViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        taskEditView.task = self.task;
    }
}


@end
