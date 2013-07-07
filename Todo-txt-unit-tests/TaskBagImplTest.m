/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011 Todo.txt contributors (http://todotxt.com)
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

#import "TaskBagImplTest.h"
#import "LocalTaskRepository.h"
#import "TaskBagImpl.h"
#import <objc/runtime.h>
#import <OCMock/OCMock.h>

@implementation TaskBagImplTest

- (void)testReload {
	NSString *text = @"A Simple test with no curve balls";
	NSString *text2 = @"The second task";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:text] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:text2] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag reload];
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 0U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text, @"Task text should be \"%@\"", text);
	STAssertEquals([[taskBag.tasks objectAtIndex:1] taskId], 99U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:1] text], text2, @"Task text should be \"%@\"", text2);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];
}

- (void)testReloadModified {
	NSString *text = @"A Simple test with no curve balls";
	NSString *text2 = @"The second task";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:text] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:text2] autorelease];
	NSMutableArray *tasks1 = [[NSMutableArray arrayWithObjects:task1, nil] retain];
	NSMutableArray *tasks2 = [[NSMutableArray arrayWithObjects:task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	BOOL modified = YES;
	[ (id <LocalTaskRepository>)[[mock expect] andReturnValue:OCMOCK_VALUE(modified)] todoFileModifiedSince:nil];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks2] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	object_setInstanceVariable(taskBag, "tasks", [tasks1 retain]);
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 0U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text, @"Task text should be \"%@\"", text);
	
	[taskBag reload];
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 99U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text2, @"Task text should be \"%@\"", text2);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks1 release];
	[tasks2 release];
}

- (void)testReloadNotModified {
	NSString *text = @"A Simple test with no curve balls";
	NSString *text2 = @"The second task";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:text] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:text2] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	BOOL notModified = NO;
	[ (id <LocalTaskRepository>)[[mock expect] andReturnValue:OCMOCK_VALUE(notModified)] todoFileModifiedSince:nil];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	object_setInstanceVariable(taskBag, "tasks", [tasks retain]);
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	
	[taskBag reload];
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertEquals([taskBag.tasks objectAtIndex:0], task1, @"Task should be same as object task1");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 0U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text, @"Task text should be \"%@\"", text);
	STAssertEquals([taskBag.tasks objectAtIndex:1], task2, @"Task should be same object as task2");
	STAssertEquals([[taskBag.tasks objectAtIndex:1] taskId], 99U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:1] text], text2, @"Task text should be \"%@\"", text2);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];
}


- (void)testAddAsTaskToNewList
{
	NSString *text = @"A Simple test with no curve balls";
	NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:1];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	[[mock expect] store:[OCMArg isNotNil]];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag addAsTask:text];
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 0U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text, @"Task text should be \"%@\"", text);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
}

- (void)testAddAsTaskToExistingList
{
	NSString *text = @"A Simple test with no curve balls";
	NSMutableArray *tasks = [NSMutableArray arrayWithObject:[[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease]];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	[[mock expect] store:[OCMArg isNotNil]];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag addAsTask:text];
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertEquals([[taskBag.tasks objectAtIndex:1] taskId], 1U, @"Task ID should be 1");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:1] text], text, @"Task text should be \"%@\"", text);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
}

- (void)testUpdate
{
	NSString *text = @"A Simple test with no curve balls";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:@"The second task"] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	[[mock expect] store:[OCMArg isNotNil]];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[task2 update:text];
	Task* updatedTask = [taskBag update:task2];

	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertNotNil(updatedTask, @"Update couldn't find the task");
	STAssertEquals(updatedTask, [taskBag.tasks objectAtIndex:1], @"Update should return a pointer to the updated task");
	STAssertEquals([[taskBag.tasks objectAtIndex:1] taskId], 99U, @"Task ID should be 99");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:1] text], text, @"Task text should be \"%@\"", text);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];
}

- (void)testUpdateFailsOnNonExistentTask
{
	NSString *text = @"A Simple test with no curve balls";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:@"The second task"] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[task2 update:text];
	Task* updatedTask = [taskBag update:task2];
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertNil(updatedTask, @"Update found a non-existent task?!");

	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];
}

- (void)testRemove
{
	NSString *text = @"A Simple test with no curve balls";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:text] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:@"The second task"] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	[[mock expect] store:[OCMArg isNotNil]];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag remove:task2];
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 0U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text, @"Task text should be \"%@\"", text);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];
}

- (void)testRemoveFailsOnNonExistentTask
{
	NSString *text = @"A Simple test with no curve balls";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:text] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:@"The second task"] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag remove:task2];
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertEquals([[taskBag.tasks objectAtIndex:0] taskId], 0U, @"Task ID should be 0");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:0] text], text, @"Task text should be \"%@\"", text);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];
}

- (void)testTaskAtIndex {
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:@"The second task"] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");

	[taskBag reload];
	
	Task* foundTask = [taskBag taskAtIndex:1];
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertNotNil(foundTask, @"Did not find the task");
	STAssertEquals(foundTask, task2, @"Should have found task2");
	STAssertEquals(foundTask.taskId, 99U, @"Task ID should be 99");

	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];	
}

- (void)testTaskAtIndexNotFound {
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:@"The second task"] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag reload];
	
	Task* foundTask = [taskBag taskAtIndex:3];
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertNil(foundTask, @"Should not have found a task");
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];	
}



- (void)testIndexOfTask {
	NSString *text = @"A Simple test with no curve balls";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:text] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, task2, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag reload];
	
	NSUInteger foundTask = [taskBag indexOfTask:task2];
	
	STAssertEquals(taskBag.size, 2, @"Should have two tasks");
	STAssertEquals(foundTask, 1U, @"Should have found task2");
	STAssertEquals([taskBag.tasks objectAtIndex:foundTask], task2, @"Update should return a pointer to the updated task");
	STAssertEquals([[taskBag.tasks objectAtIndex:foundTask] taskId], 99U, @"Task ID should be 99");
	STAssertEqualObjects([[taskBag.tasks objectAtIndex:foundTask] text], text, @"Task text should be \"%@\"", text);
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];	
}

- (void)testIndexOfTaskNotFound {
	NSString *text = @"A Simple test with no curve balls";
	Task* task1 = [[[Task alloc] initWithId:0U withRawText:@"The first task"] autorelease];
	Task* task2 = [[[Task alloc] initWithId:99U withRawText:text] autorelease];
	NSMutableArray *tasks = [[NSMutableArray arrayWithObjects:task1, nil] retain];
	id mock = [OCMockObject mockForProtocol:@protocol(LocalTaskRepository)];
	[[mock expect] create];
	[ (id <LocalTaskRepository>)[[mock expect] andReturn:tasks] load];
	
	TaskBagImpl *taskBag = [[TaskBagImpl alloc] initWithRepository:mock];
	
	STAssertEquals(taskBag.size, 0, @"Should have no tasks");
	
	[taskBag reload];
	
	NSUInteger foundTask = [taskBag indexOfTask:task2];
	
	STAssertEquals(taskBag.size, 1, @"Should have one task");
	STAssertEquals(foundTask, 0U, @"Should NOT have found task2");
	
	STAssertNoThrow([mock verify], @"Mock verify Failed");
	[taskBag release];
	[tasks release];	
}

@end
