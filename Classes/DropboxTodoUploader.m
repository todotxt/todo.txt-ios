/**
 *
 * Todo.txt-Touch-iOS/Classes/todo_txt_touch_iosAppDelegate.h
 *
 * Copyright (c) 2009-2011 Gina Trapani, Shawn McGuire
 *
 * LICENSE:
 *
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file (http://todotxt.com).
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
 * @author Gina Trapani <ginatrapani[at]gmail[dot]com>
 * @author Shawn McGuire <mcguiresm[at]gmail[dot]com> 
 * @license http://www.gnu.org/licenses/gpl.html
 * @copyright 2009-2011 Gina Trapani, Shawn McGuire
 *
 *
 * Copyright (c) 2011 Gina Trapani and contributors, http://todotxt.com
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

#import "DropboxTodoUploader.h"
#import "DropboxRemoteClient.h"

@interface DropboxTodoUploader () <DBRestClientDelegate>
@end

@implementation DropboxTodoUploader 

@synthesize remoteClient, rev, localFile, force;

- (DBRestClient*)restClient {
    if (restClient == nil) {
    	restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	restClient.delegate = self;
    }
    return restClient;
}
 
- (void) pushTodo {
	
	// First call loadMetadata to get the current rev
	// then, call uploadFile with that rev
	[self.restClient loadMetadata:[DropboxRemoteClient todoTxtRemoteFile]];
}

#pragma mark -
#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	// we loaded the latest metadata for the todo file. Now we can push it
	rev = [metadata.rev retain];	

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [defaults stringForKey:@"file_location_preference"];
	NSString *lastRev = [defaults stringForKey:@"dropbox_last_rev"];
	
	if (!force && ![rev isEqualToString:lastRev]) {
		// Conflict! Call RemoteClientDelegate method
		if (self.remoteClient.delegate && [self.remoteClient.delegate respondsToSelector:@selector(remoteClient:uploadFileFailedWithConflict:)]) {
			[self.remoteClient.delegate remoteClient:self.remoteClient uploadFileFailedWithConflict:remotePath];
		}
		return;
	}
	
	[self.restClient uploadFile:@"todo.txt" toPath:remotePath withParentRev:rev fromPath:localFile];
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	// there was no metadata for the todo file, meaning it does not exist
	// so we can upload with a nil rev
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [defaults stringForKey:@"file_location_preference"];
	[self.restClient uploadFile:@"todo.txt" toPath:remotePath withParentRev:nil fromPath:localFile];
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath 
		  metadata:(DBMetadata *)metadata {	
	rev = [metadata.rev retain];	

	if (![metadata.path isEqualToString:destPath]) {
		// If the uploaded remote path does not match our expected remotePath, 
		// then a conflict occurred and we should announce the conflict to the user.
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setValue:rev forKey:@"dropbox_last_rev"];

	// call RemoteClientDelegate method
	if (self.remoteClient.delegate && [self.remoteClient.delegate respondsToSelector:@selector(remoteClient:uploadedFile:)]) {
		[self.remoteClient.delegate remoteClient:self.remoteClient uploadedFile:destPath];
	}
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	// call RemoteClientDelegate method
	if (self.remoteClient.delegate && [self.remoteClient.delegate respondsToSelector:@selector(remoteClient:uploadFileFailedWithError:)]) {
		[self.remoteClient.delegate remoteClient:self.remoteClient uploadFileFailedWithError:error];
	}
}

- (void) dealloc {
	[rev release];
	[restClient release];
	[localFile release];
	[super dealloc];
}

@end
