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

#import "DropboxFileUploaderTest.h"
#import "AsyncWaiter.h"
#import "DropboxFileUploader.h"
#import <objc/runtime.h>
#import <OCMock/OCMock.h>

@interface DropboxFileUploaderTest ()

@property (nonatomic, strong) AsyncWaiter *waiter;

@end

@implementation DropboxFileUploaderTest

- (void)completed {
	self.waiter.complete = YES;
}

- (void) setUp {
	self.waiter = [[AsyncWaiter alloc] init];
}

- (void) tearDown {
	[self.waiter release];
}

- (void)testRemoteFileMissing
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"origrev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileUploader *uploader = [[DropboxFileUploader alloc]
									 initWithTarget:self
									 onComplete:@selector(completed)];
    [uploader performSelector:@selector(setRestClient:) withObject:mock];
    
	STAssertNotNil(uploader, @"uploader should not be nil");
	
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:remoteFile];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:uploadedFile:from:metadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock
											  uploadedFile:remoteFile
													  from:localFile
												  metadata:[[[DBMetadata alloc]
                                                             initWithDictionary:[NSDictionary
                                                                                 dictionaryWithObjectsAndKeys:@"newrev", @"rev", remoteFile, @"path", nil]] autorelease]];
		}
	} ] uploadFile:[remoteFile lastPathComponent]
     toPath:[remoteFile stringByDeletingLastPathComponent]
     withParentRev:nil
     fromPath:localFile];
	
	[uploader pushFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
                                                                               localFile:localFile
																			 originalRev:rev]] overwrite:NO];
    
	//STAssertEquals(uploader.status, ulStarted, @"Status should be STARTED");
	
	STAssertTrue([self.waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(uploader.status, dbSuccess, @"Status should be SUCCESS");
	[uploader release];
}

- (void)testRemoteFileExists
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"origrev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileUploader *uploader = [[DropboxFileUploader alloc]
									 initWithTarget:self
									 onComplete:@selector(completed)];
    [uploader performSelector:@selector(setRestClient:) withObject:mock];
	
	STAssertNotNil(uploader, @"uploader should not be nil");
	
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock loadedMetadata:[[[DBMetadata alloc]
                                                                                 initWithDictionary:[NSDictionary
                                                                                                     dictionaryWithObjectsAndKeys:rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:uploadedFile:from:metadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock
											  uploadedFile:remoteFile
													  from:localFile
												  metadata:[[[DBMetadata alloc]
                                                             initWithDictionary:[NSDictionary
                                                                                 dictionaryWithObjectsAndKeys:@"newrev", @"rev", remoteFile, @"path", nil]] autorelease]];
		}
	} ] uploadFile:[remoteFile lastPathComponent]
	 toPath:[remoteFile stringByDeletingLastPathComponent]
	 withParentRev:rev
	 fromPath:localFile];
	
	[uploader pushFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																			   localFile:localFile
																			 originalRev:rev]] overwrite:NO];
	
	//STAssertEquals(uploader.status, ulStarted, @"Status should be STARTED");
	
	STAssertTrue([self.waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(uploader.status, dbSuccess, @"Status should be SUCCESS");
	[uploader release];
}

- (void)testRemoteFileConflict
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *our_rev = @"our_rev";
	NSString *their_rev = @"their_rev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileUploader *uploader = [[DropboxFileUploader alloc]
									 initWithTarget:self
									 onComplete:@selector(completed)];
    [uploader performSelector:@selector(setRestClient:) withObject:mock];
	
	STAssertNotNil(uploader, @"uploader should not be nil");
	
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock loadedMetadata:[[[DBMetadata alloc]
                                                                                 initWithDictionary:[NSDictionary
                                                                                                     dictionaryWithObjectsAndKeys:their_rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
	
	[uploader pushFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																			   localFile:localFile
																			 originalRev:our_rev]] overwrite:NO];
	
	//STAssertEquals(uploader.status, ulStarted, @"Status should be STARTED");
	
	STAssertTrue([self.waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(uploader.status, dbConflict, @"Status should be CONFLICT");
	[uploader release];
}

- (void)testRemoteFileOverwrite
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *our_rev = @"our_rev";
	NSString *their_rev = @"their_rev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileUploader *uploader = [[DropboxFileUploader alloc]
									 initWithTarget:self
									 onComplete:@selector(completed)];
    [uploader performSelector:@selector(setRestClient:) withObject:mock];
	
	STAssertNotNil(uploader, @"uploader should not be nil");
	
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock loadedMetadata:[[[DBMetadata alloc]
																				 initWithDictionary:[NSDictionary
																									 dictionaryWithObjectsAndKeys:their_rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:uploadedFile:from:metadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock
											  uploadedFile:remoteFile
													  from:localFile
												  metadata:[[[DBMetadata alloc]
															 initWithDictionary:[NSDictionary
																				 dictionaryWithObjectsAndKeys:@"newrev", @"rev", remoteFile, @"path", nil]] autorelease]];
		}
	} ] uploadFile:[remoteFile lastPathComponent]
	 toPath:[remoteFile stringByDeletingLastPathComponent]
	 withParentRev:their_rev
	 fromPath:localFile];
	
	[uploader pushFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																			   localFile:localFile
																			 originalRev:our_rev]] overwrite:YES];
	
	//STAssertEquals(uploader.status, ulStarted, @"Status should be STARTED");
	
	STAssertTrue([self.waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(uploader.status, dbSuccess, @"Status should be SUCCESS");
	[uploader release];
}

- (void)testRemoteFileUploadError
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"origrev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileUploader *uploader = [[DropboxFileUploader alloc]
									 initWithTarget:self
									 onComplete:@selector(completed)];
    [uploader performSelector:@selector(setRestClient:) withObject:mock];
	
	STAssertNotNil(uploader, @"uploader should not be nil");
	
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock loadedMetadata:[[[DBMetadata alloc]
																				 initWithDictionary:[NSDictionary
																									 dictionaryWithObjectsAndKeys:rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([uploader respondsToSelector:@selector(restClient:uploadFileFailedWithError:)]) {
			[(id<DBRestClientDelegate>)uploader restClient:mock
								 uploadFileFailedWithError:[NSError errorWithDomain:@"errorDomain" code:99 userInfo:nil]];
		}
	} ] uploadFile:[remoteFile lastPathComponent]
	 toPath:[remoteFile stringByDeletingLastPathComponent]
	 withParentRev:rev 
	 fromPath:localFile];
	
	[uploader pushFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																			   localFile:localFile
																			 originalRev:rev]] overwrite:NO];
	
	//STAssertEquals(uploader.status, ulStarted, @"Status should be STARTED");
	
	STAssertTrue([self.waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(uploader.status, dbError, @"Status should be ERROR");
	STAssertEqualObjects(uploader.error.domain, @"errorDomain", @"NSError not set correctly");
	[uploader release];
}

@end
