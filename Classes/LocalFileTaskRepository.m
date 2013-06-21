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
#import "LocalFileTaskRepository.h"
#import "TaskIo.h"
#import "Task.h"
#import "Util.h"

@implementation LocalFileTaskRepository

+ (NSString*) todoFilename {
    static NSString *TODO_TXT_FILE = nil;
    if(!TODO_TXT_FILE) {
        TODO_TXT_FILE = [[NSSearchPathForDirectoriesInDomains(
                NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] 
                stringByAppendingPathComponent:@"todo.txt"];
    }
    return TODO_TXT_FILE;
}

+ (NSString*) doneFilename {
    static NSString *DONE_TXT_FILE = nil;
    if(!DONE_TXT_FILE) {
        DONE_TXT_FILE = [[NSSearchPathForDirectoriesInDomains(
				NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] 
				stringByAppendingPathComponent:@"done.txt"];
    }
    return DONE_TXT_FILE;
}

- (NSDate*) dateLastModifiedForFile:(NSString*)filename {
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:filename]) {
		NSDictionary *attributes = [fileManager attributesOfItemAtPath:filename error:nil];
		NSLog(@"File \"%@\" last modified %@", filename, [attributes fileModificationDate]);
		return [attributes fileModificationDate];
	} else {
		NSLog(@"File \"%@\" does not exist!", filename);
	}
	return [NSDate distantPast];
}

- (NSDate*) todoFileLastModified {
	return [self dateLastModifiedForFile:[LocalFileTaskRepository todoFilename]];
}

- (NSDate*) doneFileLastModified {
	return [self dateLastModifiedForFile:[LocalFileTaskRepository doneFilename]];
}

- (BOOL) todoFileModifiedSince:(NSDate*)date {
    NSDate *lastModified = [self todoFileLastModified];
	if (!date) {
        date = [NSDate distantPast];
    }
    return [date compare:lastModified] == NSOrderedAscending;
}

- (BOOL) doneFileModifiedSince:(NSDate*)date {
    NSDate *lastModified = [self doneFileLastModified];
	if (!date) {
        date = [NSDate distantPast];
    }
    return [date compare:lastModified] == NSOrderedAscending;
}

- (void) create {
    NSString *filename = [LocalFileTaskRepository todoFilename];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filename]) {
        [fileManager createFileAtPath:filename contents:nil attributes:nil];
    }
}

- (void) purge {
    NSString *filename = [LocalFileTaskRepository todoFilename];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:filename]) {
        [fileManager removeItemAtPath:filename error:nil];
    }
}

- (NSMutableArray*) load {
    [self create];    
    NSMutableArray* tasks = [TaskIo loadTasksFromFile:[LocalFileTaskRepository todoFilename]];
	return tasks;
}

- (void) store:(NSArray*)tasks {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [TaskIo writeTasks:tasks 
				toFile:[LocalFileTaskRepository todoFilename]
			 overwrite:YES
	 withWindowsBreaks:[defaults boolForKey:@"windows_line_breaks_preference"]];
}

- (void) archive:(NSArray*)tasks {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL windowsLineBreaks = [defaults boolForKey:@"windows_line_breaks_preference"];
	
	NSMutableArray *completedTasks = [NSMutableArray arrayWithCapacity:tasks.count];	
	NSMutableArray *incompleteTasks = [NSMutableArray arrayWithCapacity:tasks.count];	

	for (Task *task in tasks) {
		if (task.completed) {
			[completedTasks addObject:task];
		} else {
			[incompleteTasks addObject:task];
		}
	}
	
	// append completed tasks to done.txt
	[TaskIo writeTasks:completedTasks 
				 toFile:[LocalFileTaskRepository doneFilename]
			  overwrite:NO
	  withWindowsBreaks:windowsLineBreaks];
	
	// write incomplete tasks back to todo.txt
	//TODO: remove blank lines (if we ever add support for PRESERVE_BLANK_LINES)
    [TaskIo writeTasks:incompleteTasks 
				toFile:[LocalFileTaskRepository todoFilename]
			 overwrite:YES
	 withWindowsBreaks:windowsLineBreaks];
}

- (void) loadDoneTasksWithFile:(NSString*)file {
	//move from tmp to real location
	[Util renameFile:file newFile:[LocalFileTaskRepository doneFilename] overwrite:YES];
}

@end
