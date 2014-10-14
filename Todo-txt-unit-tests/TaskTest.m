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

#import "TaskTest.h"
#import "Task.h"
#import "Util.h"

@implementation TaskTest

- (void)testConstructor_simple
{
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_simple_prependDate
{
	NSString *input = @"A Simple test with no curve balls";
	NSDate *date = [Util dateFromString:@"20110228" withFormat:@"yyyyMMdd"];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input withDefaultPrependedDate:date] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"2011-02-28", task.prependedDate, @"prependedDate should be 2011-11-28");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(@"2011-02-28 A Simple test with no curve balls", task.inFileFormat, @"inFileFormat should be \"2011-02-28 A Simple test with no curve balls\"");
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withPriority
{
	NSString *input = @"(A) A priority test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.originalText, @"originalText should be \"A priority test with no curve balls\"");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.text, @"text should be \"A priority test with no curve balls\"");
	XCTAssertEqual([Priority byName:PriorityA], task.originalPriority, @"originalPriority should be A");
	XCTAssertEqual([Priority byName:PriorityA], task.priority, @"priority should be A");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.inScreenFormat, @"inScreenFormat should be \"A priority test with no curve balls\"");
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withPrependedDate
{
	NSString *input = @"2011-11-28 A priority test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.originalText, @"originalText should be \"A priority test with no curve balls\"");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.text, @"text should be \"A priority test with no curve balls\"");
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"2011-11-28", task.prependedDate, @"prependedDate should be 2011-11-28");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.inScreenFormat, @"inScreenFormat should be \"A priority test with no curve balls\"");
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withPrependedDate_prependDate
{
	NSString *input = @"2011-11-28 A priority test with no curve balls";
	NSDate *date = [Util dateFromString:@"20110228" withFormat:@"yyyyMMdd"];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input withDefaultPrependedDate:date] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.originalText, @"originalText should be \"A priority test with no curve balls\"");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.text, @"text should be \"A priority test with no curve balls\"");
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"2011-11-28", task.prependedDate, @"prependedDate should be 2011-11-28");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(@"A priority test with no curve balls", task.inScreenFormat, @"inScreenFormat should be \"A priority test with no curve balls\"");
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withContext
{
	NSString *input = @"A simple test @phone";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(1U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"phone"], @"Task should contain context \"phone\"");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withMultipleContexts
{
	NSString *input = @"A simple test with @multiple @contexts @phone";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertTrue([task.contexts containsObject:@"phone"], @"Task should contain context \"phone\"");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withInterspersedContexts
{
	NSString *input = @"@simple test @with multiple contexts @phone";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"simple"], @"Task should contain context \"simple\"");
	XCTAssertTrue([task.contexts containsObject:@"with"], @"Task should contain context \"with\"");
	XCTAssertTrue([task.contexts containsObject:@"phone"], @"Task should contain context \"phone\"");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withProject
{
	NSString *input = @"A simple test +myproject";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqual(1U, task.projects.count, @"should be 1 project");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withMultipleProjects
{
	NSString *input = @"A simple test with +multiple +projects +associated";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqual(3U, task.projects.count, @"should be 3 projects");
	XCTAssertTrue([task.projects containsObject:@"multiple"], @"Task should contain project \"multiple\"");
	XCTAssertTrue([task.projects containsObject:@"projects"], @"Task should contain project \"projects\"");
	XCTAssertTrue([task.projects containsObject:@"associated"], @"Task should contain project \"associated\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withInterspersedProjects
{
	NSString *input = @"A +simple test +with +multiple projects +myproject";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqual(4U, task.projects.count, @"should be 4 projects");
	XCTAssertTrue([task.projects containsObject:@"simple"], @"Task should contain project \"simple\"");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"multiple"], @"Task should contain project \"multiple\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withLink
{
	NSString *input = @"A simple test with an http://www.url.com";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	//FIXME: No support for links yet
	//STAssertEquals(1U, task.links.count, @"should be 1 link");
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.url.com"]], @"Task should contain link \"http://www.url.com\"");	
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withMultipleLinks
{
	NSString *input = @"A simple test with two http://www.urls.com http://www.another.one";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	//FIXME: No support for links yet
	//STAssertEquals(2U, task.links.count, @"should be 2 links");
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.url.com"]], @"Task should contain link \"http://www.url.com\"");	
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.another.one"]], @"Task should contain link \"http://www.another.one\"");	
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_withInterspersedLinks
{
	NSString *input = @"A simple https://ww.url.com test with two http://www.urls.com http://www.another.one";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	//FIXME: No support for links yet
	//STAssertEquals(3U, task.links.count, @"should be 3 links");
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.url.com"]], @"Task should contain link \"http://www.url.com\"");	
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.urls.com"]], @"Task should contain link \"http://www.urls.com\"");	
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.another.one"]], @"Task should contain link \"http://www.another.one\"");	
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_complex
{
	
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject and links http://www.link.com";
	NSString *priority = @"D";
	NSString *date = @"2011-12-01";
	NSString *input = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority byCode:priority], task.originalPriority, @"originalPriority should be %@", priority);
	XCTAssertEqual([Priority byCode:priority], task.priority, @"priority should be %@", priority);
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	//FIXME: No support for links yet
	//STAssertEquals(1U, task.links.count, @"should be 1 link");
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.link.com"]], @"Task should contain link \"http://www.link.com\"");	
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_email
{
	NSString *input = @"Email me@steveh.ca about unit testing";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	//FIXME: No support for links yet
	//STAssertEqualObjects([NSArray array], task.links, @"links should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_empty
{
	NSString *input = @"";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	//FIXME: No support for links yet
	//STAssertEqualObjects([NSArray array], task.links, @"links should be empty");
	XCTAssertTrue(task.deleted, @"Task should be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_nil
{
	Task *task = [[[Task alloc] initWithId:1 withRawText:nil] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(@"", task.originalText, @"originalText should be empty");
	XCTAssertEqualObjects(@"", task.text, @"text should be empty");
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	//FIXME: No support for links yet
	//STAssertEqualObjects([NSArray array], task.links, @"links should be empty");
	XCTAssertTrue(task.deleted, @"Task should be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(@"", task.inScreenFormat, @"inScreenFormat should be empty");
	XCTAssertEqualObjects(@"", task.inFileFormat, @"inFileFormat should be empty");
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testConstructor_completedTask
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject with http://www.link.com";
	NSString *date = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"x %@ %@", date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	//FIXME: No support for links yet
	//STAssertEquals(1U, task.links.count, @"should be 1 link");
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.link.com"]], @"Task should contain link \"http://www.link.com\"");	
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertTrue(task.completed, @"Task should be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(date, task.completionDate, @"completionDate should be %@", date);
}

- (void)testConstructor_completedTask_upperCase
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject with http://www.link.com";
	NSString *date = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"X %@ %@", date, text];
	NSString *expected = [NSString stringWithFormat:@"x %@ %@", date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	//FIXME: No support for links yet
	//STAssertEquals(1U, task.links.count, @"should be 1 link");
	//STAssertTrue([task.links containsObject:[NSURL URLWithString:@"http://www.link.com"]], @"Task should contain link \"http://www.link.com\"");	
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertTrue(task.completed, @"Task should be completed");
	XCTAssertEqualObjects(expected, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(expected, task.inFileFormat, @"inFileFormat should be %@", input);
	XCTAssertEqualObjects(date, task.completionDate, @"completionDate should be %@", date);
}

- (void)testEqualsAndHashCode_simple {
	NSString *input = @"(D) 2011-12-01 A @complex test with @multiple projects and @contexts myproject";
	Task *task1 = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	Task *task2 = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertTrue([task1 isEqual:task1], @"task1 should equal itself");
	XCTAssertTrue([task2 isEqual:task2], @"task2 should equal itself");
	XCTAssertTrue([task1 isEqual:task2], @"task1 should equal task2");
	XCTAssertTrue([task2 isEqual:task1], @"task2 should equal task1");
	XCTAssertEqual(task1.hash, task2.hash, @"task1 should equal itself");
}

- (void)testCopyInto {
	NSString *input1 = @"(D) 2011-12-01 A @complex test with @multiple projects and @contexts myproject";
	NSString *input2 = @"A simple text input";
	Task *task1 = [[[Task alloc] initWithId:1 withRawText:input1] autorelease];
	Task *task2 = [[[Task alloc] initWithId:2 withRawText:input2] autorelease];
	[task1 copyInto:task2];
	
	XCTAssertEqual(task1.taskId, task2.taskId, @"Should have same taskID");
	XCTAssertFalse([task1.originalText isEqualToString:task2.originalText], @"Should have same originalText");
	XCTAssertEqualObjects(@"A @complex test with @multiple projects and @contexts myproject", task1.originalText, @"task1 originalText should be \"A @complex test with @multiple projects and @contexts myproject\"");
	XCTAssertEqualObjects(@"A simple text input", task2.originalText, @"task2 originalText should be \"A simple text input\"");
	XCTAssertEqualObjects(task1.text, task2.text, @"Texts should be equal");
	XCTAssertFalse(task1.originalPriority == task2.originalPriority, @"Should have same originalPriority");
	XCTAssertEqual([Priority byName:PriorityD], task1.originalPriority, @"task1 originalPriority should be D");
	XCTAssertEqual([Priority NONE], task2.originalPriority, @"task2 originalPriority should be NONE");
	XCTAssertEqual(task1.priority, task2.priority, @"Should have same priority");
	XCTAssertEqualObjects(task1.prependedDate, task2.prependedDate, @"Should have same prependedDate");
	XCTAssertEqualObjects(task1.contexts, task2.contexts, @"Should have same contexts");
	XCTAssertEqualObjects(task1.projects, task2.projects, @"Should have same projects");
	XCTAssertEqual(task1.deleted, task2.deleted, @"Should have same deleted");
	XCTAssertEqual(task1.completed, task2.completed, @"Should have same completed");
	XCTAssertEqualObjects(task1, task2, @"Tasks should be equal");
	XCTAssertEqualObjects(@"A @complex test with @multiple projects and @contexts myproject", task1.inScreenFormat, @"task1 inScreenFormat should be \"A @complex test with @multiple projects and @contexts myproject\"");
	XCTAssertEqualObjects(@"A @complex test with @multiple projects and @contexts myproject", task2.inScreenFormat, @"task2 inScreenFormat should be \"A @complex test with @multiple projects and @contexts myproject\"");
	XCTAssertEqualObjects(input1, task1.inFileFormat, @"task1 inFileFormat should be \"%@\"", input1);
	XCTAssertEqualObjects(input1, task2.inFileFormat, @"task2 inFileFormat should be \"%@\"", input1);
	XCTAssertEqualObjects(@"", task1.completionDate, @"task1 completionDate should be blank");
	XCTAssertEqualObjects(task1.completionDate, task2.completionDate, @"Should have same completionDate");
}

- (void)testMarkComplete
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *priority = @"D";
	NSString *date = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	NSString *completedDate = @"2011-02-28"; 
	
	NSString *completedText = [NSString stringWithFormat:@"x %@ %@ %@", completedDate, date, text];
	
	[task markComplete:[Util dateFromString:completedDate withFormat:@"yyyy-MM-dd"]];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority byCode:priority], task.originalPriority, @"originalPriority should be %@", priority);
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertTrue(task.completed, @"Task should be completed");
	XCTAssertEqualObjects(completedText, task.inScreenFormat, @"inScreenFormat should be %@", completedText);
	XCTAssertEqualObjects(completedText, task.inFileFormat, @"inFileFormat should be %@", completedText);
	XCTAssertEqualObjects(completedDate, task.completionDate, @"completionDate should be %@", completedDate);
}

- (void)testMarkComplete_twice
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *priority = @"D";
	NSString *date = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	NSString *completedDate = @"2011-02-28"; 
	
	NSString *completedText = [NSString stringWithFormat:@"x %@ %@ %@", completedDate, date, text];
	
	[task markComplete:[Util dateFromString:completedDate withFormat:@"yyyy-MM-dd"]];
	[task markComplete:[Util dateFromString:completedDate withFormat:@"yyyy-MM-dd"]];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority byCode:priority], task.originalPriority, @"originalPriority should be %@", priority);
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertTrue(task.completed, @"Task should be completed");
	XCTAssertEqualObjects(completedText, task.inScreenFormat, @"inScreenFormat should be %@", completedText);
	XCTAssertEqualObjects(completedText, task.inFileFormat, @"inFileFormat should be %@", completedText);
	XCTAssertEqualObjects(completedDate, task.completionDate, @"completionDate should be %@", completedDate);
}

- (void)testMarkIncomplete
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *date = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"x %@ %@", date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
		
	[task markIncomplete];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(text, task.inFileFormat, @"inFileFormat should be %@", text);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testMarkIncomplete_twice
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *date = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"x %@ %@", date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task markIncomplete];
	[task markIncomplete];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(text, task.inFileFormat, @"inFileFormat should be %@", text);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testMarkIncomplete_withPrependedDate
{
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *date = @"2011-02-17";
	NSString *completedDate = @"2011-02-28";
	NSString *input = [NSString stringWithFormat:@"x %@ %@ %@", completedDate, date, text];
	NSString *incompleteText = [NSString stringWithFormat:@"%@ %@", date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task markIncomplete];
	[task markIncomplete];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqual(3U, task.contexts.count, @"should be 3 contexts");
	XCTAssertTrue([task.contexts containsObject:@"complex"], @"Task should contain context \"complex\"");
	XCTAssertTrue([task.contexts containsObject:@"multiple"], @"Task should contain context \"multiple\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"with"], @"Task should contain project \"with\"");
	XCTAssertTrue([task.projects containsObject:@"myproject"], @"Task should contain project \"myproject\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(incompleteText, task.inFileFormat, @"inFileFormat should be %@", text);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testDelete_simple {
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *priority = @"D";
	NSString *date = @"2011-12-01";
	NSString *input = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task deleteTask];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(@"", task.text, @"text should be blank");
	XCTAssertEqual([Priority byCode:priority], task.originalPriority, @"originalPriority should be %@", priority);
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertTrue(task.deleted, @"Task should be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(@"", task.inScreenFormat, @"inScreenFormat should be blank");
	XCTAssertEqualObjects(@"", task.inFileFormat, @"inFileFormat should be blank");
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testDelete_twice {
	NSString *text = @"A @complex test +with @multiple projects and @contexts +myproject";
	NSString *priority = @"D";
	NSString *date = @"2011-12-01";
	NSString *input = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task deleteTask];
	[task deleteTask];
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(@"", task.text, @"text should be blank");
	XCTAssertEqual([Priority byCode:priority], task.originalPriority, @"originalPriority should be %@", priority);
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertTrue(task.deleted, @"Task should be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(@"", task.inScreenFormat, @"inScreenFormat should be blank");
	XCTAssertEqualObjects(@"", task.inFileFormat, @"inFileFormat should be blank");
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testInFileFormat_simple {
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withPriority {
	NSString *input = @"(A) Simple test with a priority";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withPrependedDate {
	NSString *input = @"2011-01-29 Simple test with a prepended date";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withPriorityAndPrependedDate {
	NSString *input = @"(B) 2011-01-29 Simple test with a priority and a prepended date";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withContext {
	NSString *input = @"Simple test with a context @home";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withMultipleContexts {
	NSString *input = @"Simple test @phone @home";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withInterspersedContexts {
	NSString *input = @"Simple @phone test @home";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withProject {
	NSString *input = @"Simple test with a +project";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withMultipleProjects {
	NSString *input = @"Simple test +phone +home";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_withInterspersedProjects {
	NSString *input = @"+Simple phone +test home";
	Task *task = [[[Task alloc] initWithId:0 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_complex {
	NSString *input = @"(D) 2011-12-01 A @complex test +with @multiple +projects and @contexts +myproject";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_empty {
	NSString *input = @"";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(input, task.inFileFormat, @"inFileFormat shoud be \"%@\"", input);
}

- (void)testInFileFormat_nil {
	NSString *input = nil;
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	XCTAssertEqualObjects(@"", task.inFileFormat, @"inFileFormat shoud be nil");
}

- (void)testSetPriority_noExisting {
	NSString *input = @"A Simple test with no curve balls";
	NSString *priority = @"C";
	NSString *expected = [NSString stringWithFormat:@"(%@) %@", priority, input];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	task.priority = [Priority byCode:priority];					 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(input, task.text, @"text should be %@", input);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority byCode:priority], task.priority, @"priority should be C");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(input, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(expected, task.inFileFormat, @"inFileFormat should be %@", expected);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testSetPriority_noExistingWithPrependedDate {
	NSString *text = @"A Simple test with no curve balls";
	NSString *priority = @"B";
	NSString *date = @"2011-11-01";
	NSString *expected = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	NSString *input = [NSString stringWithFormat:@"%@ %@", date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	task.priority = [Priority byCode:priority];					 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority byCode:priority], task.priority, @"priority should be C");
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", input);
	XCTAssertEqualObjects(expected, task.inFileFormat, @"inFileFormat should be %@", expected);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testSetPriority_existing {
	NSString *text = @"A Simple test with no curve balls";
	NSString *originalPriority = @"A";
	NSString *priority = @"C";
	NSString *expected = [NSString stringWithFormat:@"(%@) %@", priority, text];
	NSString *input = [NSString stringWithFormat:@"(%@) %@", originalPriority, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	task.priority = [Priority byCode:priority];					 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority byCode:originalPriority], task.originalPriority, @"originalPriority should be A");
	XCTAssertEqual([Priority byCode:priority], task.priority, @"priority should be C");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(expected, task.inFileFormat, @"inFileFormat should be %@", expected);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testSetPriority_existingWithPrependedDate {
	NSString *text = @"A Simple test with no curve balls";
	NSString *originalPriority = @"A";
	NSString *priority = @"C";
	NSString *date = @"2011-11-01";
	NSString *expected = [NSString stringWithFormat:@"(%@) %@ %@", priority, date, text];
	NSString *input = [NSString stringWithFormat:@"(%@) %@ %@", originalPriority, date, text];
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	task.priority = [Priority byCode:priority];					 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(text, task.originalText, @"originalText should be %@", text);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority byCode:originalPriority], task.originalPriority, @"originalPriority should be A");
	XCTAssertEqual([Priority byCode:priority], task.priority, @"priority should be C");
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(expected, task.inFileFormat, @"inFileFormat should be %@", expected);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testUpdate_simpleToSimple {
	NSString *expectedResult = @"Another simple test with no curve balls";
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task update:expectedResult];				 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(expectedResult, task.text, @"text should be %@", expectedResult);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(expectedResult, task.inScreenFormat, @"inScreenFormat should be %@", expectedResult);
	XCTAssertEqualObjects(expectedResult, task.inFileFormat, @"inFileFormat should be %@", expectedResult);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testUpdate_simpleToWithContexts {
	NSString *expectedResult = @"Another simple @test with @contexts";
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task update:expectedResult];				 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(expectedResult, task.text, @"text should be %@", expectedResult);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqual(2U, task.contexts.count, @"should be 2 contexts");
	XCTAssertTrue([task.contexts containsObject:@"test"], @"Task should contain context \"test\"");
	XCTAssertTrue([task.contexts containsObject:@"contexts"], @"Task should contain context \"contexts\"");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(expectedResult, task.inScreenFormat, @"inScreenFormat should be %@", expectedResult);
	XCTAssertEqualObjects(expectedResult, task.inFileFormat, @"inFileFormat should be %@", expectedResult);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testUpdate_simpleToWithProjects {
	NSString *expectedResult = @"Another simple +test with +projects";
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task update:expectedResult];				 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(expectedResult, task.text, @"text should be %@", expectedResult);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqual(2U, task.projects.count, @"should be 2 projects");
	XCTAssertTrue([task.projects containsObject:@"test"], @"Task should contain projects \"test\"");
	XCTAssertTrue([task.projects containsObject:@"projects"], @"Task should contain projects \"projects\"");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(expectedResult, task.inScreenFormat, @"inScreenFormat should be %@", expectedResult);
	XCTAssertEqualObjects(expectedResult, task.inFileFormat, @"inFileFormat should be %@", expectedResult);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testUpdate_simpleToPriority {
	NSString *text = @"Another simple test with no curve balls";
	NSString *priority = @"A";
	NSString *expectedResult = [NSString stringWithFormat:@"(%@) %@", priority, text];
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task update:expectedResult];				 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority byCode:priority], task.priority, @"priority should be A");
	XCTAssertEqualObjects(@"", task.prependedDate, @"prependedDate should be blank");
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(expectedResult, task.inFileFormat, @"inFileFormat should be %@", expectedResult);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

- (void)testSetText_simpleToPrependedDate {
	NSString *text = @"Another simple test with no curve balls";
	NSString *date = @"2011-10-01";
	NSString *expectedResult = [NSString stringWithFormat:@"%@ %@", date, text];
	NSString *input = @"A Simple test with no curve balls";
	Task *task = [[[Task alloc] initWithId:1 withRawText:input] autorelease];
	
	[task update:expectedResult];				 
	
	XCTAssertEqual(1U, task.taskId, @"Task ID should be 1");
	XCTAssertEqualObjects(input, task.originalText, @"originalText should be %@", input);
	XCTAssertEqualObjects(text, task.text, @"text should be %@", text);
	XCTAssertEqual([Priority NONE], task.originalPriority, @"originalPriority should be NONE");
	XCTAssertEqual([Priority NONE], task.priority, @"priority should be NONE");
	XCTAssertEqualObjects(date, task.prependedDate, @"prependedDate should be %@", date);
	XCTAssertEqualObjects([NSArray array], task.contexts, @"contexts should be empty");
	XCTAssertEqualObjects([NSArray array], task.projects, @"projects should be empty");
	XCTAssertFalse(task.deleted, @"Task should not be deleted");
	XCTAssertFalse(task.completed, @"Task should not be completed");
	XCTAssertEqualObjects(text, task.inScreenFormat, @"inScreenFormat should be %@", text);
	XCTAssertEqualObjects(expectedResult, task.inFileFormat, @"inFileFormat should be %@", expectedResult);
	XCTAssertEqualObjects(@"", task.completionDate, @"completionDate should be blank");
}

@end
