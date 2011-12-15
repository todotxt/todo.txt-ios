/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011 Todo.txt contributors (http://todotxt.com)
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

#import "DropboxTodoDownloader.h"
#import "DropboxRemoteClient.h"

@interface DropboxTodoDownloader () <DBRestClientDelegate>
@end

@implementation DropboxTodoDownloader 

@synthesize remoteClient, rev;

- (DBRestClient*)restClient {
    if (restClient == nil) {
    	restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	restClient.delegate = self;
    }
    return restClient;
}
 
- (void) pullTodo {
	
	// First call loadMetadata to get the current rev
	// then, call loadFile with that rev
	// don't save rev until we successfully loaded the file
	[self.restClient loadMetadata:[DropboxRemoteClient todoTxtRemoteFile]];
}

#pragma mark -
#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	// we loaded the latest metadata for the todo file. Now we can pull it
	rev = [metadata.rev retain];	
		
	[self.restClient loadFile:[DropboxRemoteClient todoTxtRemoteFile]
						atRev:rev 
					 intoPath:[DropboxRemoteClient todoTxtTmpFile]];	
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	// there was no metadata for the todo file, meaning it does not exist
	// so there is nothing to load
	// call RemoteClientDelegate method
	if (self.remoteClient.delegate && [self.remoteClient.delegate respondsToSelector:@selector(remoteClient:loadedFile:)]) {
		[self.remoteClient.delegate remoteClient:self.remoteClient loadedFile:nil];
	}
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
	// save off the downloaded file's rev
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:rev forKey:@"dropbox_last_rev"];
	
	// call RemoteClientDelegate method
	if (self.remoteClient.delegate && [self.remoteClient.delegate respondsToSelector:@selector(remoteClient:loadedFile:)]) {
		[self.remoteClient.delegate remoteClient:self.remoteClient loadedFile:destPath];
	}
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	if (self.remoteClient.delegate && [self.remoteClient.delegate respondsToSelector:@selector(remoteClient:loadFileFailedWithError:)]) {
		[self.remoteClient.delegate remoteClient:self.remoteClient loadFileFailedWithError:error];
	}
}

- (void) dealloc {
	[rev release];
	[restClient release];
	[super dealloc];
}

@end
