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
#import <OCMock/OCMock.h>

static CGFloat const kDownloaderTestTimeout = 15;

@interface DropboxFileDownloaderTest ()

@property BOOL finished;

@end

@implementation DropboxFileDownloaderTest

- (void)testRemoteFileMissing
{
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:[OCMArg any]];
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:@"/somepath/somefile.txt"
                                                                                 localFile:@"thelocalfile.txt"
                                                                               originalRev:@"origrev"]]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 1U, @"Should have 1 file");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbNotFound, @"Status should be NOT_FOUND");
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
	[downloader release];
}

- (void)testRemoteFileExists
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"remoterev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
                                                                                 localFile:localFile
                                                                               originalRev:@"origrev"]]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
	[downloader release];
}

- (void)testRemoteFileUpToDate
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"remoterev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
    [downloader performSelector:@selector(setRestClient:) withObject:mock];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadedMetadata:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock 
											  loadedMetadata:[[[DBMetadata alloc] 
															initWithDictionary:[NSDictionary 
															dictionaryWithObjectsAndKeys:rev, @"rev", nil]] autorelease]];
		}
	} ] loadMetadata:remoteFile];
    
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
                                                                                 localFile:localFile
                                                                               originalRev:rev]]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 1U, @"Should have 1 file");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbNotChanged, @"Status should be NOT_CHANGED");
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
	[downloader release];
}

- (void)testRemoteFileDownloadError
{
	NSString *remoteFile = @"/somepath/somefile.txt";
	NSString *rev = @"remoterev";
	NSString *localFile = @"thelocalfile.txt";
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObject:[[DropboxFile alloc] initWithRemoteFile:remoteFile
                                                                                 localFile:localFile
                                                                               originalRev:@"origrev"]]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqualObjects(error.domain, @"errorDomain", @"NSError not set correctly");
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
	[downloader release];
}

#pragma mark -
#pragma mark Test two files

- (void)testBothRemoteFilesMissing
{
	id mock = [OCMockObject mockForClass:DBRestClient.class];
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
	[[[mock stub] andDo:^(NSInvocation *invocation) {
		if ([downloader respondsToSelector:@selector(restClient:loadMetadataFailedWithError:)]) {
			[(id<DBRestClientDelegate>)downloader restClient:mock loadMetadataFailedWithError:nil];
		}
	} ] loadMetadata:[OCMArg any]];
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:@"/somepath/somefile.txt"
                                                                                  localFile:@"thelocalfile.txt"
                                                                                originalRev:@"origrev"],
                           [[DropboxFile alloc] initWithRemoteFile:@"/somepath/anotherfile.txt"
                                                         localFile:@"anotherlocalfile.txt"
                                                       originalRev:@"anotherrev"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbNotFound, @"Status should be NOT_FOUND");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbNotFound, @"Status should be NOT_FOUND");
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:@"origrev1"],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:@"origrev2"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbNotFound, @"Status should be NOT_FOUND");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:@"origrev1"],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:@"origrev2"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbNotFound, @"Status should be NOT_FOUND");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:@"origrev1"],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:@"origrev2"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:rev1],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:@"origrev2"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbNotChanged, @"Status should be NOT_CHANGED");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:@"origrev1"],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:rev2],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbNotChanged, @"Status should be NOT_CHANGED");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:rev1],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:rev2],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbNotChanged, @"Status should be NOT_CHANGED");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbNotChanged, @"Status should be NOT_CHANGED");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   
                   XCTAssertNil(error, @"Failed to complete without error");
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:@"origrev1"],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:@"origrev2"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbError, @"Status should be ERROR");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbFound, @"Status should be FOUND");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   XCTAssertEqualObjects([[[files objectAtIndex:0] error] domain], errordomain, @"error domain should be \"%@\"", errordomain);
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
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
	DropboxFileDownloader *downloader = [[DropboxFileDownloader alloc] init];
	[downloader performSelector:@selector(setRestClient:) withObject:mock];
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
	
	XCTAssertNotNil(downloader, @"downloader should not be nil");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
	[downloader pullFiles:[NSArray arrayWithObjects:[[DropboxFile alloc] initWithRemoteFile:remoteFile1
                                                                                  localFile:localFile1
                                                                                originalRev:@"origrev1"],
                           [[DropboxFile alloc] initWithRemoteFile:remoteFile2
                                                         localFile:localFile2
                                                       originalRev:@"origrev2"],
                           nil]
               completion:^(NSArray *files, NSError *error) {
                   self.finished = YES;
                   
                   XCTAssertEqual(files.count, 2U, @"Should have 2 files");
                   XCTAssertEqual([[files objectAtIndex:0] status], dbSuccess, @"Status should be SUCCESS");
                   XCTAssertEqual([[files objectAtIndex:1] status], dbError, @"Status should be ERROR");
                   XCTAssertEqualObjects([[[files objectAtIndex:0] loadedMetadata] rev], rev1, @"loaded Rev should be \"%@", rev1);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] loadedMetadata] rev], rev2, @"loaded Rev should be \"%@", rev2);
                   XCTAssertEqualObjects([[[files objectAtIndex:1] error] domain], errordomain, @"error domain should be \"%@\"", errordomain);
                   
                   dispatch_semaphore_signal(semaphore);
               }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDownloaderTestTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       if (!self.finished) {
                           XCTFail(@"Failed to complete in time");
                       }
                       dispatch_semaphore_signal(semaphore);
                   });
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    }
    
	[downloader release];
}


@end
