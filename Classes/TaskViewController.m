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

char *buttons[] = { "Update", "Prioritize", "Complete", "Delete", "Share" }; 

@implementation TaskViewController

@synthesize taskIndex;

#pragma mark -
#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated {
    // Update the view with current data before it is displayed.
    [super viewWillAppear:animated];
    
    // Scroll the table view to the top before it appears
	[[todo_txt_touch_iosAppDelegate sharedTaskBag] reload];
	
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    self.title = @"Task Details";
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // There are 2 sections, one for the text, the other for the buttons
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
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
            // There are 5 buttons: Update, Prioritize, Complete, Delete, and Share. 
            rows = 5;
            break;
        default:
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 75;
	} else {
		return 50;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 60;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	if(section == 0) {
		return @"";
	} else {
		return @"Actions";
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set the text in the cell for the section/row.
	if (indexPath.section == 0) {
		id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];	
		Task *task = [[taskBag tasks] objectAtIndex:taskIndex];
		cell.textLabel.text = [task inScreenFormat];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
	} else {
		cell.textLabel.text = [NSString stringWithUTF8String:buttons[indexPath.row]];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
    }

    return cell;
}

// Load the detail view controller when user taps the row
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[tableView cellForRowAtIndexPath:indexPath] setSelected:NO animated:YES];
	
	switch (indexPath.row) {
		case 0: //Update
			[self didTapUpdateButton];
			break;
		case 3: //Delete
			[self didTapDeleteButton];
			break;
			
		default:
			break;
	}
}

- (void) didTapUpdateButton {
	NSLog(@"didTapUpdateButton called");
    TaskEditViewController *taskEditView = [[[TaskEditViewController alloc] init] autorelease];
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];	
	taskEditView.task = [[taskBag tasks] objectAtIndex:taskIndex];
	[taskEditView setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentModalViewController:taskEditView animated:YES];	
}

-(void)exitController {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void) deleteTask {
	id<TaskBag> taskBag = [todo_txt_touch_iosAppDelegate sharedTaskBag];
	Task* task = [[[taskBag tasks] objectAtIndex:taskIndex] retain];
	[taskBag remove:task];
	[task release];
	 
	//TODO: toast?
	//TODO: sync remote
	[self performSelectorOnMainThread:@selector(exitController) withObject:nil waitUntilDone:NO];
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
	
	[dlg showInView:self.view];
	[dlg release];		
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [actionSheet destructiveButtonIndex]) {
		//TODO: progress dialog
		[AsyncTask runTask:@selector(deleteTask) onTarget:self];
	}
}

- (void) dealloc {;
	[super dealloc];
}

@end
