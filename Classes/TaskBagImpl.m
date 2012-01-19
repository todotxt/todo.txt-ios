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
#import "TaskBagImpl.h"
#import "todo_txt_touch_iosAppDelegate.h"
#import "RemoteClientManager.h"
#import "RemoteClient.h"
#import "LocalFileTaskRepository.h"
#import "TaskIo.h"
#import "Filter.h"
#import "TaskUtil.h"

Task* find(NSArray *tasks, Task *task) {
	for(int i = 0; i < [tasks count]; i++) {
		Task *taski = [tasks objectAtIndex:i];
		if([taski.text isEqualToString:task.originalText] &&
		   [taski.priority isEqual:task.originalPriority]) {
			return taski;
		}
	}
    return nil;
}

@implementation TaskBagImpl

- (id) initWithRepository:(id <LocalTaskRepository>)repo {
    self = [super init];
    
	if (self) {
        localTaskRepository = [repo retain];
        tasks = nil;
	}
	
	return self;
   
}

- (void) updateBadge {
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *showWhich = [defaults stringForKey:@"badgeCount_preference"];

	NSInteger count = [TaskUtil badgeCount:tasks which:showWhich];

	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:count];
}

- (void) reload {
    [localTaskRepository create];
    [tasks release];
    tasks = [[localTaskRepository load] retain];
	
	[self updateBadge];
}

- (void) reloadWithFile:(NSString*)file {
	if (file) {
		NSMutableArray *remoteTasks = [TaskIo loadTasksFromFile:file];
		[localTaskRepository store:remoteTasks];
		[self reload];
	}
}

- (void) addAsTask:(NSString*)input {
    [self reload];
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSDate *date = nil;
	if ([defaults boolForKey:@"date_new_tasks_preference"]) {
		date = [NSDate date];
	}
	
    Task *task = [[Task alloc] initWithId:[tasks count] 
							  withRawText:input 
				 withDefaultPrependedDate:date];
    [tasks addObject:task];
	[task release];
    [localTaskRepository store:tasks];
	
	[self updateBadge];
}


- (Task*) update:(Task*)task {
    [self reload];
    Task *found = find(tasks, task);
    if (found) {
        [task copyInto:found];
        [localTaskRepository store:tasks];
		
		[self updateBadge];
		
		return found;
    }
	return nil;
}


- (void) remove:(Task*)task {
    [self reload];
    Task *found = find(tasks, task);
    if (found) {
        [tasks removeObject:found];
        [localTaskRepository store:tasks];
		
		[self updateBadge];
    }    
}

- (Task*) taskAtIndex:(NSUInteger)index {
	if (index >= [tasks count]) {
		return nil;
	}
	return [tasks objectAtIndex:index];
}

- (NSUInteger) indexOfTask:(Task*)task {
	for (int i = 0; i < [tasks count]; i++) {
		if ([tasks objectAtIndex:i] == task) {
			return i;
		}
	}
	return 0;
}

- (NSArray*) tasks {
    return [self tasksWithFilter:nil withSortOrder:nil];
}

- (NSArray*) tasksWithFilter:(id<Filter>)filter withSortOrder:(Sort*)sortOrder {
	NSMutableArray *localTasks = [NSMutableArray arrayWithCapacity:[tasks count]];
	if (filter != nil) {
		for (Task* task in tasks) {
			if ([filter apply:task]) {
				[localTasks addObject:task];
			}
		}
	} else {	
		[localTasks setArray:tasks];
	}
		
	if (!sortOrder) {
		sortOrder = [Sort byName:SortPriority];
	}
	
	[localTasks sortUsingSelector:[sortOrder comparator]];
	
	return localTasks;
}

- (int) size {
    return [tasks count];
}


- (NSArray*) projects {
	NSMutableSet *set = [NSMutableSet setWithCapacity:32];
	for (Task* task in tasks) {
		[set addObjectsFromArray:[task projects]];
	}
    return [[set allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (NSArray*) contexts {
	NSMutableSet *set = [NSMutableSet setWithCapacity:32];
	for (Task* task in tasks) {
		[set addObjectsFromArray:[task contexts]];
	}
    return [[set allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


- (NSArray*) priorities {
    return [Priority all];
}

- (void) dealloc {
    [localTaskRepository release];
    [tasks release];
    [super dealloc];
}

@end

