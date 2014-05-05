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

#import "ActionSheetPicker.h"
#import "AsyncTask.h"
#import "FilterFactory.h"
#import "FilterViewController.h"
#import "Task.h"
#import "TaskCell.h"
#import "TaskCellViewModel.h"
#import "TaskEditViewController.h"
#import "TaskViewController.h"
#import "TasksViewController.h"
#import "TodoTxtAppDelegate.h"
#import "UIColor+CustomColors.h"

#import "IASKAppSettingsViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#define LOGOUT_TAG 10
#define ARCHIVE_TAG 11

static NSString *const kEmptyFileMessage = @"Your todo.txt file is empty. \
\n\n\
Tap the + button to add a todo.";

static NSString *const kNoFilterResultsMessage = @"No results for chosen \
contexts and projects.";

static NSString *const kCellIdentifier = @"FlexiTaskCell";
static NSString *const kViewTaskSegueIdentifier = @"TaskViewSegue";
static NSString *const kAddTaskSegueIdentifier = @"TaskAddSegue";
static NSString *const kFilterSegueIdentifier = @"FilterSegue";

static CGFloat const kMinCellHeight = 44;

@interface TasksViewController () <IASKSettingsDelegate>

@property (strong, nonatomic) IBOutlet UILabel *emptyLabel;
@property (nonatomic, strong) NSArray *tasks;
@property (nonatomic, strong) Sort *sort;
@property (nonatomic, copy) NSString *savedSearchTerm;
@property (nonatomic, strong) NSArray *searchResults;
@property (weak, nonatomic, readonly) NSArray *filteredTasks;
@property (nonatomic, strong) id<Filter> filter;
@property (nonatomic, strong) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, strong) ActionSheetPicker *actionSheetPicker;
@property (nonatomic, strong) UIPopoverController *masterPopoverController;
@property (nonatomic, readonly) UIFont *mainTextFont;

// Store the last contexts and projects that were filtered on when on iPhone,
// so they can be shown as selected in the filter view if it is shown again.
@property (nonatomic, strong) NSArray *lastFilteredContexts;
@property (nonatomic, strong) NSArray *lastFilteredProjects;

@property (nonatomic) BOOL needSync;

// TODO: refactor app delegate and remove me
@property (nonatomic, weak) TodoTxtAppDelegate *appDelegate;

- (void)sync:(id)sender;

@end

@implementation TasksViewController

static NSString * const kTODOTasksRefreshText = @"Pull down to sync with Dropbox";
static NSString * const kTODOTasksSyncingRefreshText = @"Syncing with Dropbox now...";

#pragma mark -
#pragma mark Private methods

- (void)sync:(id)sender {
	NSLog(@"sync: called");
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTODOTasksSyncingRefreshText];
    [[[self.appDelegate syncClient] finally:^{
        [self.refreshControl endRefreshing];
        self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTODOTasksRefreshText];
    }] subscribeCompleted:^{
        //nothing, but required for the finally: block
    }];
}

- (void) reloadData:(NSNotification *) notification {
	// reload global tasklist from disk
	[self.appDelegate.taskBag reload];	

	// reload main tableview data
	self.tasks = [self.appDelegate.taskBag tasksWithFilter:nil withSortOrder:self.sort];
	[self.tableView reloadData];
	
	// reload searchbar tableview data if necessary
	if (self.savedSearchTerm)
	{	
		id<Filter> filter = [FilterFactory getAndFilterWithPriorities:nil contexts:nil projects:nil text:self.savedSearchTerm caseSensitive:NO];
		self.searchResults = [self.appDelegate.taskBag tasksWithFilter:filter withSortOrder:self.sort];
		[self.searchDisplayController.searchResultsTableView reloadData];
	}
}

- (NSArray*) taskListForTable:(UITableView*)tableView {
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return self.searchResults;
	} else {
		return self.filteredTasks;
	}
}

- (Task*) taskForTable:(UITableView*)tableView atIndex:(NSUInteger)index {
	if(tableView == self.searchDisplayController.searchResultsTableView) {
		return [self.searchResults objectAtIndex:index];
	} else {
		return [self.filteredTasks objectAtIndex:index];
	}
}


- (void)hideSearchBar:(BOOL)animated {
	if (animated) {
		[UIView beginAnimations:@"hidesearchbar" context:nil];
		[UIView setAnimationDuration:0.4];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	self.tableView.contentOffset = CGPointMake(0, self.searchDisplayController.searchBar.frame.size.height);
	
	if (animated) {
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark Synthesizers

- (Sort*) sortOrderPref {
	SortName name = SortPriority;
	NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
	if (def) name = [def integerForKey:@"sortOrder"];
	return [Sort byName:name];
}

- (void) setSortOrderPref {
	NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
	if (def) {
		[def setInteger:[self.sort name] forKey:@"sortOrder"];
		[AsyncTask runTask:@selector(synchronize) onTarget:def];
	}
}

#pragma mark -
#pragma mark Lifecycle methods

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        self.appDelegate = (TodoTxtAppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Todo.txt";
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:kTODOTasksRefreshText];
    [refreshControl addTarget:self action:@selector(sync:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
	
    self.sort = [self sortOrderPref];
	self.tasks = nil;
	
	// Restore search term
	if (self.savedSearchTerm)
	{
		self.searchDisplayController.searchBar.text = self.savedSearchTerm;
	}

    self.emptyLabel.text = kEmptyFileMessage;
    
    [self.tableView registerClass:[TaskCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	NSLog(@"viewWillAppear - tableview");
	[self hideSearchBar:NO];
	[self reloadData:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reloadData:) 
												 name:kTodoChangedNotification 
											   object:nil];
}

- (void) viewDidAppear:(BOOL)animated {	
	if (self.needSync) {
		self.needSync = NO;
        if (![self.appDelegate isManualMode]) {
			[self.appDelegate syncClient];
        }
	}	
}

- (void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	// Save the state of the search UI so that it can be restored if the view is re-created.
	self.savedSearchTerm = self.searchDisplayController.searchBar.text;
	self.searchResults = nil;
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.actionSheetPicker = nil;
}

- (void)didReceiveMemoryWarning {
	NSLog(@"Memory warning!");
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Overridden getters/setters

- (NSArray *)filteredTasks
{
    return [self.appDelegate.taskBag tasksWithFilter:self.filter withSortOrder:self.sort];
}

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!_appSettingsViewController) {
		_appSettingsViewController = [[IASKAppSettingsViewController alloc] initWithNibName:@"IASKAppSettingsView" bundle:nil];
		_appSettingsViewController.delegate = self;
	}
	return _appSettingsViewController;
}

- (UIFont *)mainTextFont
{
    return [UIFont systemFontOfSize:14];
}

#pragma mark -
#pragma mark Table view datasource methods

// Return the number of sections in table view
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// Return the number of rows in the section of table view
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self taskListForTable:tableView] count];
}

// Return cell for the rows in table view
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [self taskForTable:tableView atIndex:indexPath.row];
    TaskCellViewModel *viewModel = [[TaskCellViewModel alloc] init];
    viewModel.task = task;
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    cell.viewModel = viewModel;
    
    RAC(cell.taskTextView, attributedText) = [RACObserve(viewModel, attributedText) distinctUntilChanged];
    RAC(cell.taskTextView, accessibilityLabel) = [RACObserve(viewModel, accessibleText) distinctUntilChanged];
    RAC(cell.ageLabel, text) = [RACObserve(viewModel, ageText) distinctUntilChanged];
    RAC(cell.priorityLabel, text) = [RACObserve(viewModel, priorityText) distinctUntilChanged];
    RAC(cell.priorityLabel, textColor) = [RACObserve(viewModel, priorityColor) distinctUntilChanged];
    RAC(cell, shouldShowDate) = [RACObserve(viewModel, shouldShowDate) distinctUntilChanged];
    
	return cell;
}


#pragma mark -
#pragma mark Table view delegate methods

// Return the height for tableview cells
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Task* task = [self taskForTable:tableView atIndex:indexPath.row];
    CGFloat height = [TaskCell heightForText:task.text
                                    withFont:self.mainTextFont
                                       width:CGRectGetWidth(tableView.frame)];
    return MAX(height, kMinCellHeight);
}

// Load the detail view controller when user taps the row
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Segue to the detail view for a task
    [self performSegueWithIdentifier:kViewTaskSegueIdentifier sender:tableView];
}

#pragma mark -
#pragma mark Search bar delegate methods

- (void)handleSearchForTerm:(NSString *)searchTerm {
	self.savedSearchTerm = searchTerm;
	id<Filter> filter = [FilterFactory getAndFilterWithPriorities:nil contexts:nil projects:nil text:self.savedSearchTerm caseSensitive:NO];
	self.searchResults = [self.appDelegate.taskBag tasksWithFilter:filter withSortOrder:self.sort];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
	[self handleSearchForTerm:searchString];
    
	return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
	self.savedSearchTerm = nil;
	[self reloadData:nil];
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;    
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<TaskBag> taskBag = self.appDelegate.taskBag;
    Task *task = [self taskForTable:tableView atIndex:indexPath.row];
    
    if (task.completed) {
        [task markIncomplete];
    } else {
        [task markComplete:[NSDate date]];
    }
    
    [taskBag update:task];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"auto_archive_preference"]) {
		[taskBag archive];
	}
	
    [self reloadData:nil];
    [self.appDelegate pushToRemote];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Task *task = [self taskForTable:tableView atIndex:indexPath.row];
    
    if (task.completed) {
        return @"Undo Complete";
    } else {
        return @"Complete";
    }
}


- (IBAction)addButtonPressed:(id)sender {
	NSLog(@"addButtonPressed called");
    [self performSegueWithIdentifier:kAddTaskSegueIdentifier sender:self];
}

- (IBAction)settingsButtonPressed:(id)sender {
    UINavigationController *aNavController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
    //[viewController setShowCreditsFooter:NO];   // Uncomment to not display InAppSettingsKit credits for creators.
    // But we encourage you not to uncomment. Thank you!
    self.appSettingsViewController.showDoneButton = YES;
    [self presentViewController:aNavController animated:YES completion:nil];
}

#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.appDelegate.taskBag updateBadge];
	self.needSync = YES;
}

#pragma mark -
#pragma mark Search display results controller delegate methods

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    // Register the desired cell type for a search display controller's table view
    [controller.searchResultsTableView registerClass:[TaskCell class]
                              forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark -
#pragma mark Split view controller delegate methods

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    barButtonItem.title = @"Filter";
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = pc;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForKey:(NSString*)key {
	if ([key isEqualToString:@"logout_button"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" 
														 message:@"Are you sure you wish to log out of Dropbox?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel"
											   otherButtonTitles:nil];
		alert.tag = LOGOUT_TAG;
		[alert addButtonWithTitle:@"Log out"];
		[alert show];
	}
	if ([key isEqualToString:@"archive_button"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" 
														 message:@"Are you sure you wish to archive your completed tasks?" 
														delegate:self 
											   cancelButtonTitle:@"Cancel"
											   otherButtonTitles:nil];
		alert.tag = ARCHIVE_TAG;
		[alert addButtonWithTitle:@"Archive"];
		[alert show];
	}
    else if([key isEqualToString:@"about_todo"]) {
        NSURL *url = [NSURL URLWithString:@"http://todotxt.com"];
        [[UIApplication sharedApplication] openURL:url];
    }
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {

        switch (alertView.tag) {
			case LOGOUT_TAG:
                [self dismissViewControllerAnimated:NO completion:nil];
				[self.appDelegate logout];
				break;
			case ARCHIVE_TAG:
                [self dismissViewControllerAnimated:YES completion:nil];
                NSLog(@"Archiving...");
				[self.appDelegate displayNotification:@"Archiving completed tasks..."];
				[self.appDelegate.taskBag archive];
				[self reloadData:nil];
				[self.appDelegate pushToRemote];
				break;
			default:
				break;
		}		
    }
}

- (void) sortOrderWasSelected:(NSNumber *)selectedIndex element:(id)element {
	self.actionSheetPicker = nil;
	if (selectedIndex.intValue >= 0) {
		self.sort = [Sort byName:selectedIndex.intValue];
		[self setSortOrderPref];
		[self reloadData:nil];
		[self hideSearchBar:NO];
	}
}

//- (IBAction)segmentControlPressed:(id)sender {
//	[actionSheetPicker actionPickerCancel];
//	self.actionSheetPicker = nil;
//	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
//	CGRect rect = [self.view convertRect:segmentedControl.frame fromView:segmentedControl];
//	rect = CGRectMake(segmentedControl.frame.origin.x + segmentedControl.frame.size.width / 4, rect.origin.y, 
//					  rect.size.width, rect.size.height);
//	switch (segmentedControl.selectedSegmentIndex) {
//		case 0: // Filter
//			break;
//		case 1: // Sort
//			self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
//																			   data:[Sort descriptions]
//																	  selectedIndex:[sort name]
//																			 target:self 
//																			 action:@selector(sortOrderWasSelected:element:)
//																			  title:@"Select Sort Order"
//																			   rect:rect
//																	  barButtonItem:nil];			
//			break;
//	}
//}

- (IBAction)sortButtonPressed:(id)sender {
	[self.actionSheetPicker actionPickerCancel];
	self.actionSheetPicker = nil;
	self.actionSheetPicker = [ActionSheetPicker displayActionPickerWithView:self.view 
																	   data:[Sort descriptions]
															  selectedIndex:[self.sort name]
																	 target:self 
																	 action:@selector(sortOrderWasSelected:element:)
																	  title:@"Select Sort Order"
																	   rect:CGRectZero
															  barButtonItem:sender];			
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self reloadData:nil];
    [self hideSearchBar:YES];   
	[self.actionSheetPicker actionPickerCancel];
	self.actionSheetPicker = nil;
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kViewTaskSegueIdentifier]) {
		UITableView *tableView = (UITableView*)sender;
        Task *task = [self taskForTable:tableView atIndex:tableView.indexPathForSelectedRow.row];
        
        TaskViewController *detailViewController = (TaskViewController *)segue.destinationViewController;
        detailViewController.taskIndex = [self.appDelegate.taskBag indexOfTask:task];
    } else if ([segue.identifier isEqualToString:kFilterSegueIdentifier]) {
        FilterViewController *vc = (FilterViewController *)[(UINavigationController *)segue.destinationViewController topViewController];
        vc.filterTarget = self;
        vc.initialSelectedContexts = self.lastFilteredContexts;
        vc.initialSelectedProjects = self.lastFilteredProjects;
        vc.shouldWaitForDone = YES;
    }
    // nothing to be done for kAddTaskSegueIdentifier
}

#pragma mark - TaskFilterable methods

- (void)filterForContexts:(NSArray *)contexts projects:(NSArray *)projects
{
    self.lastFilteredContexts = [NSArray arrayWithArray:contexts];
    self.lastFilteredProjects = [NSArray arrayWithArray:projects];
    
    self.filter = [FilterFactory getAndFilterWithPriorities:nil contexts:contexts projects:projects text:nil caseSensitive:NO];
    
    if (contexts.count || projects.count) {
        self.emptyLabel.text = kNoFilterResultsMessage;
    } else {
        self.emptyLabel.text = kEmptyFileMessage;
    }
    
	// reload main tableview data to use the filter
    [self.tableView reloadData];
}

@end
