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

#import "TaskViewController.h"
#import "todo_txt_touch_iosAppDelegate.h"
#import "TaskEditViewController.h"
#import "TaskBag.h"
#import "AsyncTask.h"
#import "Color.h"
#import "ActionSheetPicker.h"
#import "TaskViewCell.h"
#import "FlexiTaskCell.h"
#import "AttributedLabel.h"
#import <CoreText/CoreText.h>

#import "NSMutableAttributedString+TodoTxt.h"

#define TEXT_LABEL_WIDTH_IPHONE_PORTRAIT  255
#define TEXT_LABEL_WIDTH_IPHONE_LANDSCAPE 420
#define TEXT_LABEL_WIDTH_IPAD_PORTRAIT    635
#define TEXT_LABEL_WIDTH_IPAD_LANDSCAPE   895
#define VERTICAL_PADDING        5

#define DATE_LABEL_HEIGHT 16 // 13 + 3 for padding
#define MIN_ROW_HEIGHT 50
#define ACTION_ROW_HEIGHT 50
#define DETAIL_CELL_PADDING 10

char *buttons[] = { "Complete", "Prioritize", "Update", "Delete" };
char *completed_buttons[] = { "Undo Complete", "Delete" }; 

@implementation TaskViewController

@synthesize taskIndex, tableCell, actionSheetPicker;

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

- (CGFloat)textLabelWidth {
	BOOL isiPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	BOOL isPortrait = (UIDeviceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation));
	
	CGFloat offset = 0;

	if (isiPad)
	{
		if (isPortrait)
			return TEXT_LABEL_WIDTH_IPAD_PORTRAIT - offset;
		else
			return TEXT_LABEL_WIDTH_IPAD_LANDSCAPE - offset;
	}
	else
	{
		if (isPortrait)
			return TEXT_LABEL_WIDTH_IPHONE_PORTRAIT - offset;
		else
			return TEXT_LABEL_WIDTH_IPHONE_LANDSCAPE - offset;
	}
		
}

- (CGFloat)calcTextHeightWithTask:(Task*)task {
	CGFloat maxWidth = [self textLabelWidth];
    CGFloat maxHeight = CGFLOAT_MAX;
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

- (NSAttributedString*)attributedTaskText:(Task *)task {
    NSDictionary *taskAttributes = (task.completed) ?
	[FlexiTaskCell completedTaskAttributes] : [FlexiTaskCell taskStringAttributes];
	
    NSString* taskText = [self.task inScreenFormat];
    NSMutableAttributedString *taskString;
    taskString = [[[NSMutableAttributedString alloc] initWithString:taskText
                                                         attributes:taskAttributes] autorelease];
	
    NSDictionary* grayAttriubte = [NSDictionary dictionaryWithObject:(id)[UIColor grayColor].CGColor
                                                              forKey:(id)kCTForegroundColorAttributeName];
    [taskString addAttributesToProjectText:grayAttriubte];
    [taskString addAttributesToContextText:grayAttriubte];
	
    return [[[NSAttributedString alloc] initWithAttributedString:taskString] autorelease];
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
	
	label = (UILabel *)[cell viewWithTag:1];
	[label setHidden:true];
	
	AttributedLabel *al = (AttributedLabel *)[cell viewWithTag:3];
	al.text = [self attributedTaskText:task];
	
	CGRect labelFrame = CGRectMake(46, VERTICAL_PADDING,
								   [self textLabelWidth], [self calcTextHeightWithTask:task]);

	al.frame = labelFrame;
	
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
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	[taskBag remove:task];
	[task release];
	 
	[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:YES];
	[todo_txt_touch_iosAppDelegate displayNotification:@"Deleted task"];
	[todo_txt_touch_iosAppDelegate pushToRemote];
}

- (void) undoCompleteTask {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	[task markIncomplete];
	[taskBag update:task];
	[task release];
	
	[todo_txt_touch_iosAppDelegate pushToRemote];
	[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
}

- (void) completeTask {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	[task markComplete:[NSDate date]];
	[taskBag update:task];
	[task release];
		
	BOOL auto_archive = [[NSUserDefaults standardUserDefaults] boolForKey:@"auto_archive_preference"];
	if (auto_archive) {
		[taskBag archive];
	}
	
	
	if (auto_archive) {
		[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:YES];
		[todo_txt_touch_iosAppDelegate displayNotification:@"Task completed and archived"];
	} else {
		[self performSelectorOnMainThread:@selector(reloadViewData) withObject:nil waitUntilDone:NO];
	}
	[todo_txt_touch_iosAppDelegate pushToRemote];
}

- (void) prioritizeTask:(Priority*)selectedPriority {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[self task] retain];
	task.priority = selectedPriority;
	[taskBag update:task];
	[task release];
	
	[todo_txt_touch_iosAppDelegate pushToRemote];
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
	[actionSheetPicker actionPickerCancel];
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
	[actionSheetPicker release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[actionSheetPicker actionPickerCancel];
	self.actionSheetPicker = nil;
}


@end
