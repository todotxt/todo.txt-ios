/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Brendon Justin <bjustin@nerdery.com>
 * @copyright 2013 Sierra Bravo Corp., dba The Nerdery (http://nerdery.com)
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

#import "FilterViewController.h"

#import "Task.h"
#import "TaskBag.h"
#import "TodoTxtAppDelegate.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

typedef NS_ENUM(NSInteger, FilterViewFilterTypes) {
    FilterViewFilterTypesContexts = 0,
    FilterViewFilterTypesProjects,
    FilterViewFilterTypesFirst = FilterViewFilterTypesContexts,
    FilterViewFilterTypesLast = FilterViewFilterTypesProjects
};

typedef NS_OPTIONS(NSInteger, FilterViewActiveTypes) {
    FilterViewActiveTypesContexts = 1 << 0,
    FilterViewActiveTypesProjects = 1 << 1,
    FilterViewActiveTypesAll = FilterViewActiveTypesContexts | FilterViewActiveTypesProjects
};

@interface FilterViewController ()

- (FilterViewFilterTypes)typeOfFilterForSection:(NSInteger)section;
- (void)filterOnContextsAndProjects;
- (IBAction)selectedSegment:(UISegmentedControl *)sender;
- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@property (strong, nonatomic) NSArray *contexts;
@property (strong, nonatomic) NSArray *projects;
@property (strong, nonatomic) NSMutableArray *selectedContexts;
@property (strong, nonatomic) NSMutableArray *selectedProjects;
@property (readonly, nonatomic) BOOL haveContexts;
@property (readonly, nonatomic) BOOL haveProjects;
@property (nonatomic) FilterViewActiveTypes activeTypes;

@end

@implementation FilterViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.title = @"Filter";
        
        self.selectedContexts = [NSMutableArray array];
        self.selectedProjects = [NSMutableArray array];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.activeTypes = FilterViewActiveTypesAll;
    
    // Listen for updates to tasks in the TaskBag, to keep our context and project
    // lists current.
    NSObject<TaskBag> *taskBag = ((TodoTxtAppDelegate *)[[UIApplication sharedApplication] delegate]).taskBag;
    
    RACSignal *tasksSignal = RACObserve(taskBag, tasks);
    
    RAC(self, contexts) = [tasksSignal map:^NSArray *(NSArray *tasks) {
        return [[tasks valueForKeyPath:@"@distinctUnionOfArrays.contexts"]
                sortedArrayUsingSelector:@selector(compare:)];
    }];
    
    RAC(self, projects) = [tasksSignal map:^NSArray *(NSArray *tasks) {
        return [[tasks valueForKeyPath:@"@distinctUnionOfArrays.projects"]
                sortedArrayUsingSelector:@selector(compare:)];
    }];
    
    // Whenever our contexts or projects update, tell the table view to reloadData
    [[RACSignal combineLatest:@[ RACObserve(self, contexts), RACObserve(self, projects) ]]
     subscribeNext:^(id _) {
         [self.tableView reloadData];
    }];
    
    // Use ordinary UITableViewCells
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FilterCell"];
}

#pragma mark - Custom getters/setters

- (void)setInitialSelectedContexts:(NSArray *)initialSelectedContexts
{
    self.selectedContexts = [NSMutableArray arrayWithArray:initialSelectedContexts];
}

- (void)setInitialSelectedProjects:(NSArray *)initialSelectedProjects
{
    self.selectedProjects = [NSMutableArray arrayWithArray:initialSelectedProjects];
}

- (BOOL)haveContexts
{
    return (self.contexts.count > 0 && (self.activeTypes & FilterViewActiveTypesContexts));
}

- (BOOL)haveProjects
{
    return (self.projects.count > 0 && (self. activeTypes & FilterViewActiveTypesProjects));
}

#pragma mark - Private methods

- (FilterViewFilterTypes)typeOfFilterForSection:(NSInteger)section
{
    if (self.haveContexts && section == 0) {
        return FilterViewFilterTypesContexts;
    } else {
        return FilterViewFilterTypesProjects;
    }
}

- (void)filterOnContextsAndProjects
{
    NSArray *filterContexts = nil;
    NSArray *filterProjects = nil;
    
    if (self.haveContexts) {
        filterContexts = self.selectedContexts;
    }
    
    if (self.haveProjects) {
        filterProjects = self.selectedProjects;
    }
    
    if (!self.shouldWaitForDone) {
        [self.filterTarget filterForContexts:filterContexts projects:filterProjects];
    }
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *const contextsTitle = @"Contexts";
    NSString *const projectsTitle = @"Projects";
    
    switch ([self typeOfFilterForSection:section]) {
        case FilterViewFilterTypesContexts:
            return contextsTitle;
            break;
            
        case FilterViewFilterTypesProjects:
            return projectsTitle;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    NSInteger numSections = 0;
    
    if (self.haveContexts) {
        numSections++;
    }
    
    if (self.haveProjects) {
        numSections++;
    }
    
    return numSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch ([self typeOfFilterForSection:section]) {
        case FilterViewFilterTypesContexts:
            return self.contexts.count;
            break;
            
        case FilterViewFilterTypesProjects:
            return self.projects.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    // Reset the accessory type in case we got a recycled cell that
    // had a type set.
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    NSString *text = nil;
    switch ([self typeOfFilterForSection:indexPath.section]) {
        case FilterViewFilterTypesContexts:
            text = [NSString stringWithFormat:@"@%@", self.contexts[indexPath.row]];
            if ([self.selectedContexts containsObject:self.contexts[indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
            
        case FilterViewFilterTypesProjects:
            text = [NSString stringWithFormat:@"+%@", self.projects[indexPath.row]];
            if ([self.selectedProjects containsObject:self.projects[indexPath.row]]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            break;
    }
    cell.textLabel.text = text;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect the cell to remove the selection highlight
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // Update contexts and projects to filter on
    switch ([self typeOfFilterForSection:indexPath.section]) {
        case FilterViewFilterTypesContexts:
            if ([self.selectedContexts containsObject:self.contexts[indexPath.row]]) {
                [self.selectedContexts removeObject:self.contexts[indexPath.row]];
            } else {
                [self.selectedContexts addObject:self.contexts[indexPath.row]];
            }
            break;
            
        case FilterViewFilterTypesProjects:
            if ([self.selectedProjects containsObject:self.projects[indexPath.row]]) {
                [self.selectedProjects removeObject:self.projects[indexPath.row]];
            } else {
                [self.selectedProjects addObject:self.projects[indexPath.row]];
            }
            break;
    }
    
    // Reload the row to reflect the updated selection status.
    [self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self filterOnContextsAndProjects];
}

#pragma mark - IBActions

- (void)selectedSegment:(UISegmentedControl *)sender
{
    // Set the filter types to show based on the selected segment.
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.activeTypes = FilterViewActiveTypesAll;
            [self.tableView reloadData];
            break;
            
        case 1:
            self.activeTypes = FilterViewActiveTypesContexts;
            [self.tableView reloadData];
            break;
            
        case 2:
            self.activeTypes = FilterViewActiveTypesProjects;
            [self.tableView reloadData];
            break;
            
        default:
            break;
    }
}

- (void)done:(id)sender
{
    NSArray *filterContexts = nil;
    NSArray *filterProjects = nil;
    
    if (self.haveContexts) {
        filterContexts = self.selectedContexts;
    }
    
    if (self.haveProjects) {
        filterProjects = self.selectedProjects;
    }
    
    if (self.shouldWaitForDone) {
        [self.filterTarget filterForContexts:filterContexts projects:filterProjects];
    }

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
