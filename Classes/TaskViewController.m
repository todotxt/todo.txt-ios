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

#import "TaskViewController.h"
#import "todo_txt_touch_iosAppDelegate.h"
#import "TaskEditViewController.h"
#import "TaskBag.h"
#import "AsyncTask.h"
#import "Color.h"
#import "ActionSheetPicker.h"
#import "TestFlight.h"

#define TEXT_LABEL_WIDTH 227
#define DATE_LABEL_HEIGHT 16 // 13 + 3 for padding
#define MIN_ROW_HEIGHT 50
#define ACTION_ROW_HEIGHT 50
#define DETAIL_CELL_PADDING 10

char *buttons[] = { "Complete", "Prioritize", "Update", "Delete" };
char *completed_buttons[] = { "Undo Complete", "Delete" }; 

@implementation TaskViewController

@synthesize taskIndex, tableCell;

- (Task*) task {
	return [[todo_txt_touch_iosAppDelegate sharedTaskBag] taskAtIndex:taskIndex];
}

- (void) reloadViewData {
	// Scroll the table view to the top before it appears
	[[todo_txt_touch_iosAppDelegate sharedTaskBag] reload];
	
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];

}

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
	[self reloadViewData];
	
    self.title = @"Task Details";
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
            if([task completed]) {
				// For completed tasks there are 2 buttons: Undo Complete and Delete. 
				rows = sizeof(completed_buttons) / sizeof(char*);
			} else {
				// Otherwise, there are 5 buttons: Update, Prioritize, Complete, Delete, and Share. 
				rows = sizeof(buttons) / sizeof(char*);
			}
            break;
        default:
            break;
    }
    return rows;
}

- (CGFloat)calcTextHeightWithTask:(Task*)task {
	CGFloat maxWidth = TEXT_LABEL_WIDTH;
    CGFloat maxHeight = 9999;
    CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
	
    CGSize expectedLabelSize = [[task inScreenFormat] 
			sizeWithFont:[UIFont fontWithName:@"Helvetica" size:14.0f]
			constrainedToSize:maximumLabelSize 
		    lineBreakMode:UILineBreakModeWordWrap]; 
	
	return expectedLabelSize.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		Task* task = [self task];
		CGFloat ret = [self calcTextHeightWithTask:task];
		
		if (![task completed]) {
			ret += DATE_LABEL_HEIGHT; // height of the date line
		}
		
		// padding
		ret += DETAIL_CELL_PADDING;
		
		return MAX(ret, MIN_ROW_HEIGHT);
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

// Return cell for the rows in table view
-(UITableViewCell *) renderTaskCell:(UITableView *)tableView
{
	// Create the cell identifier
	static NSString *CellIdentifier = @"TaskDetailCell";
	
	// Create the cell if cells are available with same cell identifier
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	// If there are no cells available, allocate a new one with our nib
	if (cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
		cell = tableCell;
		self.tableCell = nil;
	}
	
	// Populate the cell data and format
	Task *task = [self task];	
	UILabel *label;
	
    label = (UILabel *)[cell viewWithTag:2];
    label.text = [[task priority] listFormat];
    label.font = [UIFont boldSystemFontOfSize:14.0];
	// Set the priority color
	PriorityName n = [[task priority] name];
	switch (n) {
		case PriorityA:
			//Set color to green #587058
			label.textColor = [Color green];
			break;
		case PriorityB:
			//Set color to blue #587498
			label.textColor = [Color blue];
			break;
		case PriorityC:
			//Set color to orange #E86850
			label.textColor = [Color orange];
			break;
		case PriorityD:
			//Set color to gold #587058
			label.textColor = [Color gold];
			break;			
		default:
			//Set color to black #000000
			label.textColor = [Color black];
			break;
	}
	
    label = (UILabel *)[cell viewWithTag:3];
    label.text = [task inScreenFormat];
    label.font = [UIFont systemFontOfSize:14.0];
	if ([task completed]) {
		// TODO: There doesn't seem to be a strikethrough option for UILabel.
		// For now, let's just disable the label.
		label.enabled = NO;
	} else {
		label.enabled = YES;
	}

	CGRect labelFrame = label.frame;
	labelFrame.size.height = [self calcTextHeightWithTask:task];
	label.frame = labelFrame;
	UILabel *dateLabel = (UILabel *)[cell viewWithTag:4];
    if (![task completed]) {
		dateLabel.text = [task relativeAge];
		dateLabel.hidden = NO;
	} else {
		dateLabel.text = @"";
		dateLabel.hidden = YES;
	}
	
	if ([task completed]) {
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	
	return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = nil;
	
    // Set the text in the cell for the section/row.
	if (indexPath.section == 0) {
		cell = [self renderTaskCell:tableView];
	} else {
		static NSString *CellIdentifier = @"CellIdentifier";
		
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		}
		
		cell.textLabel.textAlignment = UITextAlignmentCenter;

		if([[self task] completed]) {
			cell.textLabel.text = [NSString stringWithUTF8String:completed_buttons[indexPath.row]];
		} else {
			cell.textLabel.text = [NSString stringWithUTF8String:buttons[indexPath.row]];			
		}
    }

    return cell;
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
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	[taskBag remove:task];
	[task release];
	 
	//TODO: toast?
	[todo_txt_touch_iosAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:NO];
}

- (void) undoCompleteTask {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	[task markIncomplete];
	[taskBag update:task];
	[task release];
	
	//TODO: toast?
	[todo_txt_touch_iosAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) completeTask {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	[task markComplete:[NSDate date]];
	[taskBag update:task];
	[task release];
	
	//TODO: toast?
	[todo_txt_touch_iosAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) prioritizeTask:(Priority*)selectedPriority {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	task.priority = selectedPriority;
	[taskBag update:task];
	[task release];
	
	//TODO: toast?
	[todo_txt_touch_iosAppDelegate pushToRemote];
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
	NSInteger curPriority = (NSInteger)[[[self task] priority] name];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]]; //FIXME: don't hardcode this
	[ActionSheetPicker displayActionPickerWithView:self.view 
						data:[Priority allCodes]
						selectedIndex:curPriority 
						target:self 
						action:@selector(priorityWasSelected::) 
						title:@"Select Priority"
						 rect:cell.frame
				barButtonItem:nil];
}

- (void) didTapUpdateButton {
	NSLog(@"didTapUpdateButton called");
    TaskEditViewController *taskEditView = [[[TaskEditViewController alloc] init] autorelease];
	taskEditView.task = [self task];
	[taskEditView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:taskEditView animated:YES];	
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
	[dlg release];		
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
	[dlg release];		
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

- (void) dealloc {;
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

@end
