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
#import "TaskBagImpl.h"
#import "TodoTxtAppDelegate.h"
#import "RemoteClientManager.h"
#import "RemoteClient.h"
#import "LocalFileTaskRepository.h"
#import "TaskIo.h"
#import "Filter.h"
#import "TaskUtil.h"

static Task* find(NSArray *tasks, Task *task) {
	for(int i = 0; i < [tasks count]; i++) {
		Task *taski = [tasks objectAtIndex:i];
		if(task == taski || ([taski.text isEqualToString:task.originalText] &&
		   [taski.priority isEqual:task.originalPriority])) {
			return taski;
		}
	}
    return nil;
}

@interface TaskBagImpl ()

@property (nonatomic, strong) NSMutableArray *tasks;
@property (nonatomic, strong) id <LocalTaskRepository> localTaskRepository;
@property (nonatomic, strong) NSDate *lastReload;

@end

@implementation TaskBagImpl

- (id) initWithRepository:(id <LocalTaskRepository>)repo {
    self = [super init];
    
	if (self) {
        self.localTaskRepository = repo;
	}
	
	return self;
   
}

- (void) updateBadge {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *showWhich = [defaults stringForKey:@"badgeCount_preference"];

	NSInteger count = [TaskUtil badgeCount:self.tasks which:showWhich];

	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (BOOL) todoFileModifiedSince:(NSDate*)date {
	return [self.localTaskRepository todoFileModifiedSince:date];
}

- (BOOL) doneFileModifiedSince:(NSDate*)date {
	return [self.localTaskRepository doneFileModifiedSince:date];
}

- (void) store:(NSArray*)theTasks {
    [self.localTaskRepository store:theTasks];
    self.lastReload = nil;
}

- (void) store {
    [self store:self.tasks];
}

- (void) archive {
	[self reload];
	[self.localTaskRepository archive:self.tasks];
    self.lastReload = nil;
}

- (void) reload {
	if (!self.tasks || [self todoFileModifiedSince:self.lastReload]) {
		[self.localTaskRepository create];
		self.tasks = [self.localTaskRepository load];
		self.lastReload = [NSDate date];
		[self updateBadge];
	}
}

- (void) reloadWithFile:(NSString*)file {
	if (file) {
		NSMutableArray *remoteTasks = [TaskIo loadTasksFromFile:file];
		[self store:remoteTasks];
		[self reload];
	}
}

- (void) loadDoneTasksWithFile:(NSString*)file {
	if (file) {
		[self.localTaskRepository loadDoneTasksWithFile:file];
	}
}

- (void) addAsTask:(NSString*)input {
    [self reload];
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *date = nil;
	if ([defaults boolForKey:@"date_new_tasks_preference"]) {
		date = [NSDate date];
	}
	
    Task *task = [[Task alloc] initWithId:[self.tasks count]
							  withRawText:input 
				 withDefaultPrependedDate:date];
    [self.tasks addObject:task];
	[self updateBadge];
    [self store];

}


- (Task*) update:(Task*)task {
    [self reload];
    Task *found = find(self.tasks, task);
    if (found) {
        if (found != task) [task copyInto:found];

		[self updateBadge];
        [self store];
		
		return found;
    }
	return nil;
}


- (void) remove:(Task*)task {
    [self reload];
    Task *found = find(self.tasks, task);
    if (found) {
        [self.tasks removeObject:found];
		[self updateBadge];
        [self store];
    }    
}

- (Task*) taskAtIndex:(NSUInteger)index {
	if (index >= [self.tasks count]) {
		return nil;
	}
	return [self.tasks objectAtIndex:index];
}

- (NSUInteger) indexOfTask:(Task*)task {
	for (int i = 0; i < [self.tasks count]; i++) {
		if ([self.tasks objectAtIndex:i] == task) {
			return i;
		}
	}
	return 0;
}

- (NSArray*) tasksWithFilter:(id<Filter>)filter withSortOrder:(Sort*)sortOrder {
	NSMutableArray *localTasks = [NSMutableArray arrayWithCapacity:[_tasks count]];
	if (filter != nil) {
		for (Task* task in _tasks) {
			if ([filter apply:task]) {
				[localTasks addObject:task];
			}
		}
	} else {	
		[localTasks setArray:_tasks];
	}
		
	if (!sortOrder) {
		sortOrder = [Sort byName:SortPriority];
	}
	
	[localTasks sortUsingSelector:[sortOrder comparator]];
	
	return localTasks;
}

- (int) size {
    return [self.tasks count];
}

- (NSArray*) projects {
	NSMutableSet *set = [NSMutableSet setWithCapacity:32];
	for (Task* task in self.tasks) {
		[set addObjectsFromArray:[task projects]];
	}
    return [[set allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (NSArray*) contexts {
	NSMutableSet *set = [NSMutableSet setWithCapacity:32];
	for (Task* task in self.tasks) {
		[set addObjectsFromArray:[task contexts]];
	}
    return [[set allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (NSArray*) priorities {
    return [Priority all];
}


@end

