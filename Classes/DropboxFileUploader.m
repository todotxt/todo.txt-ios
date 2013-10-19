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
 * a copy of this software and associated documentation self.files (the
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

#import "DropboxFileUploader.h"
#import "DropboxRemoteClient.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface DropboxFileUploader () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic) BOOL overwrite;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, strong) NSArray *files;
@property (nonatomic) NSInteger curFile;
@property (nonatomic, strong) RACSubject *subject;

@end

@implementation DropboxFileUploader

- (id)init
{
	self = [super init];
	if (self) {
		self.overwrite = NO;
		self.curFile = -1;
	}

	return self;
}

- (DBRestClient *)restClient {
	if (_restClient == nil) {
		_restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		_restClient.delegate = self;
	}
	return _restClient;
}

- (void) uploadNextFile {
	if (++self.curFile < self.files.count) {
		DropboxFile *file = [self.files objectAtIndex:self.curFile];
		if (file.status == dbFound || file.status == dbNotFound) {
			[self.restClient uploadFile:[file.remoteFile lastPathComponent] 
								 toPath:[file.remoteFile stringByDeletingLastPathComponent] 
						  withParentRev:file.loadedMetadata.rev 
							   fromPath:file.localFile];
		} else {
			[self uploadNextFile];
		}
	} else {
		// we're done!
        [self.subject sendNext:self.files];
        [self.subject sendCompleted];
	}
}

- (void) loadNextMetadata {
	if (++self.curFile < self.files.count) {
		DropboxFile *file = [self.files objectAtIndex:self.curFile];
		file.status = dbStarted;
		[self.restClient loadMetadata:file.remoteFile];
	} else {
		// we got all of the metadata, now get the files
		self.curFile = -1;
		[self uploadNextFile];
	}
}

- (RACSignal *)pushFiles:(NSArray*)dropboxFiles overwrite:(BOOL)doOverwrite {
    self.files = dropboxFiles;
    self.curFile = -1;
    self.overwrite = doOverwrite;
    
    self.subject = [RACSubject subject];
    
    // first check metadata of each file, starting with the first
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self loadNextMetadata];
    }];
    
    return self.subject;
}

#pragma mark -
#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	DropboxFile *file = [self.files objectAtIndex:self.curFile];
	
	if (metadata.isDeleted) {
		// if the file does not exist, we can upload it with a nil parentrev
		file.loadedMetadata = nil;
		file.status = dbNotFound;
	} else {
		// save off the returned metadata
		file.loadedMetadata = metadata;	
		
		if (!self.overwrite && ![metadata.rev isEqualToString:file.originalRev]) {
			// Conflict! Stop everything and return to caller
			file.status = dbConflict;
            NSError *err = [NSError errorWithDomain:kRCErrorDomain
                                               code:kUploadConflictErrorCode
                                           userInfo:@{ kUploadConflictFile : file }];
            [self.subject sendError:err];
			return;
		}
		
		file.status = dbFound;
	}
	
	// get the next metadata
	[self loadNextMetadata];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	DropboxFile *file = [self.files objectAtIndex:self.curFile];

	// there was no metadata for the todo file, meaning it does not exist
	// so we can upload with a nil rev
	file.loadedMetadata = nil;
	file.status = dbNotFound;
	
	// get the next metadata
	[self loadNextMetadata];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath 
		  metadata:(DBMetadata *)metadata {	
	DropboxFile *file = [self.files objectAtIndex:self.curFile];
	
	file.loadedMetadata = metadata;	

	if ([metadata.path caseInsensitiveCompare:destPath] != NSOrderedSame) {
		// If the uploaded remote path does not match our expected remotePath, 
		// then a conflict occurred and we should announce the conflict to the user.
		file.status = dbConflict;
        NSError *err = [NSError errorWithDomain:kRCErrorDomain
                                           code:kUploadConflictErrorCode
                                       userInfo:@{ kUploadConflictFile : file }];
        [self.subject sendError:err];
		return;
	}
	
	file.status = dbSuccess;
	
	[self uploadNextFile];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)theError {
	DropboxFile *file = [self.files objectAtIndex:self.curFile];
	
	file.status = dbError;
	file.error = theError;
	
	// don't bother uploading any more self.files after the first error
    [self.subject sendError:theError];
}


@end
