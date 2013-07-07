/**
 * This file is part of Todo.txt, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011 Todo.txt contributors (http://todotxt.com)
 *  
 *Dual-licensed under the GNU General Public License and the MIT License
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

#import "DropboxFileDownloaderTest.h"
#import "DropboxFileDownloader.h"
#import "DropboxFile.h"
#import <objc/runtime.h>
#import <OCMock/OCMock.h>

@implementation DropboxFileDownloaderTest

- (void)completed {
	waiter.complete = YES;
}

- (void) setUp {
	waiter = [[AsyncWaiter alloc] init];
}

- (void) tearDown {
	[waiter release];
}

- (void)testRemoteFileMissing
{
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
					initWithTarget:self		
						onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:[OCMArg any]];
	
	STAssertNotNil(downloader, @"downloader should not be nil");

	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:@"/somepath/somefile.txt"
																				 localFile:@"thelocalfile.txt"
																			   originalRev:@"origrev"]]];

	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");

	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 1U, @"Should have 1 file");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbNotFound, @"Status should be NOT_FOUND");
	[downloader release];
}

- (void)testRemoteFileExists
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"remoterev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
										initWithDictionary:[NSDictionary 
										dictionaryWithObjectsAndKeys:rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile];
		}
	} ] loadFile:remoteFile atRev:rev intoPath:localFile];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																				 localFile:localFile
																			   originalRev:@"origrev"]]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	[downloader release];
}

- (void)testRemoteFileUpToDate
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"remoterev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
    object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															initWithDictionary:[NSDictionary 
															dictionaryWithObjectsAndKeys:rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
		
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																				 localFile:localFile
																			   originalRev:rev]]];

	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 1U, @"Should have 1 file");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbNotChanged, @"Status should be NOT_CHANGED");
	[downloader release];
}

- (void)testRemoteFileDownloadError
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"remoterev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															  initWithDictionary:[NSDictionary 
															  dictionaryWithObjectsAndKeys:rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadFileFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadFileFailedWithError:[NSError errorWithDomain:@"errorDomain" code:99 userInfo:nil]];
		}
	} ] loadFile:remoteFile atRev:rev intoPath:localFile];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
																				 localFile:localFile
																			   originalRev:@"origrev"]]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbError, @"Status should be ERROR");
	STAssertEqualObjects(downloader.error.domain, @"errorDomain", @"NSError not set correctly");
	[downloader release];
}

#pragma mark -
#pragma mark Test two files

- (void)testBothRemoteFilesMissing
{
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:[OCMArg any]];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:@"/somepath/somefile.txt"
																				 localFile:@"thelocalfile.txt"
																			   originalRev:@"origrev"],
						   [[DropboxFile alloc] initWithRemoteFile:@"/somepath/anotherfile.txt"
														 localFile:@"anotherlocalfile.txt"
													   originalRev:@"anotherrev"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbNotFound, @"Status should be NOT_FOUND");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbNotFound, @"Status should be NOT_FOUND");
	
	[downloader release];
}

- (void)testFirstRemoteFileExists
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev1 = @"remoterev1";
	NSString *localFile2 = @"thelocalfile2.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile1];
		}
	} ] loadFile:remoteFile1 atRev:rev1 intoPath:localFile1];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:@"origrev1"],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:@"origrev2"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbNotFound, @"Status should be NOT_FOUND");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	
	[downloader release];
}

- (void)testSecondRemoteFileExists
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile2];
		}
	} ] loadFile:remoteFile2 atRev:rev2 intoPath:localFile2];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:@"origrev1"],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:@"origrev2"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbNotFound, @"Status should be NOT_FOUND");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	
	[downloader release];
}

- (void)testBothRemoteFilesExist
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *rev1 = @"remoterev1";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile1];
		}
	} ] loadFile:remoteFile1 atRev:rev1 intoPath:localFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile2];
		}
	} ] loadFile:remoteFile2 atRev:rev2 intoPath:localFile2];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:@"origrev1"],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:@"origrev2"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	
	[downloader release];
}

- (void)testFirstRemoteFileUpToDate
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *rev1 = @"remoterev1";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile2];
		}
	} ] loadFile:remoteFile2 atRev:rev2 intoPath:localFile2];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:rev1],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:@"origrev2"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbNotChanged, @"Status should be NOT_CHANGED");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	
	[downloader release];
}

- (void)testSecondRemoteFileUpToDate
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *rev1 = @"remoterev1";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile1];
		}
	} ] loadFile:remoteFile1 atRev:rev1 intoPath:localFile1];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:@"origrev1"],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:rev2],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbNotChanged, @"Status should be NOT_CHANGED");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	
	[downloader release];
}

- (void)testBothRemoteFilesUpToDate
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *rev1 = @"remoterev1";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:rev1],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:rev2],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbSuccess, @"Status should be SUCCESS");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbNotChanged, @"Status should be NOT_CHANGED");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbNotChanged, @"Status should be NOT_CHANGED");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	
	[downloader release];
}

- (void)testFirstRemoteFileError
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *rev1 = @"remoterev1";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	NSString *errordomain = @"the_error_domain";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadFileFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadFileFailedWithError:[NSError errorWithDomain:errordomain code:99 userInfo:nil]];
		}
	} ] loadFile:remoteFile1 atRev:rev1 intoPath:localFile1];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:@"origrev1"],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:@"origrev2"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbError, @"Status should be ERROR");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbError, @"Status should be ERROR");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbFound, @"Status should be FOUND");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] error] domain], errordomain, @"error domain should be \"%@\"", errordomain);
	
	[downloader release];
}

- (void)testSecondRemoteFileError
{
	NSString *remoteFile1 = @"/somepath/somefile1.txt";
	NSString *localFile1 = @"thelocalfile1.txt";
	NSString *rev1 = @"remoterev1";
	NSString *remoteFile2 = @"/somepath/somefile2.txt";
	NSString *rev2 = @"remoterev2";
	NSString *localFile2 = @"thelocalfile2.txt";
	NSString *errordomain = @"the_error_domain";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] 
										 initWithTarget:self		
										 onComplete:@selector(completed)];
	object_setInstanceVariable(downloader, "restClient", mock);
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev1, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															   initWithDictionary:[NSDictionary 
																				   dictionaryWithObjectsAndKeys:rev2, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile2];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedFile:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadedFile:localFile1];
		}
	} ] loadFile:remoteFile1 atRev:rev1 intoPath:localFile1];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadFileFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadFileFailedWithError:[NSError errorWithDomain:errordomain code:99 userInfo:nil]];
		}
	} ] loadFile:remoteFile2 atRev:rev2 intoPath:localFile2];
	
	STAssertNotNil(downloader, @"downloader should not be nil");
	
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
																				  localFile:localFile1
																				originalRev:@"origrev1"],
						   [[DropboxFile alloc] initWithRemoteFile:remoteFile2
														 localFile:localFile2
													   originalRev:@"origrev2"],
						   nil]];
	
	//STAssertEquals(downloader.status, dlStarted, @"Status should be STARTED");
	
	STAssertTrue([waiter waitForCompletion:15.0], @"Failed to complete in time");
	STAssertEquals(downloader.status, dbError, @"Status should be ERROR");
	STAssertEquals(downloader.files.count, 2U, @"Should have 2 files");
	STAssertEquals([[downloader.files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
	STAssertEquals([[downloader.files objectAtIndex:1] status], dbError, @"Status should be ERROR");
	STAssertEqualObjects([[[downloader.files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
	STAssertEqualObjects([[[downloader.files objectAtIndex:1] error] domain], errordomain, @"error domain should be \"%@\"", errordomain);
	
	[downloader release];
}


@end
