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

#import "DropboxRemoteClient.h"
#import "Network.h"
#import "TaskIo.h"
#import "DropboxApiKey.h"
#import "Util.h"

@interface DropboxRemoteClient () <DBSessionDelegate>
@end

@implementation DropboxRemoteClient

@synthesize delegate;

+ (NSString*) todoTxtTmpFile {
	return 	[NSString pathWithComponents:
			   [NSArray arrayWithObjects:NSTemporaryDirectory(), 
						@"todo.txt", nil]];
}

+ (NSString*) todoTxtRemoteFile {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [defaults stringForKey:@"file_location_preference"];

	return 	[NSString pathWithComponents:
			 [NSArray arrayWithObjects:remotePath, 
			  @"todo.txt", nil]];
}

- (id) init {
	self = [super init];
	if (self) {
		DBSession* session = 
        [[DBSession alloc] initWithAppKey:str(DROPBOX_APP_KEY) 
								appSecret:str(DROPBOX_APP_SECRET) 
									 root:kDBRootDropbox];
		session.delegate = self; 
		[DBSession setSharedSession:session];
		[session release];
	}
	return self;
}

- (Client) client {
	return ClientDropBox;
}

- (BOOL) authenticate {
	// Not sure if we need to do anything here
	return [self isAuthenticated];
}

- (void) deauthenticate {
	[[DBSession sharedSession] unlinkAll];
	[[NSFileManager defaultManager] 
		removeItemAtPath:[DropboxRemoteClient todoTxtTmpFile] 
					error:nil];
}

- (BOOL) isAuthenticated {
	return [[DBSession sharedSession] isLinked];
}

- (void) presentLoginControllerFromController:(UIViewController*)parentViewController {
	[[DBSession sharedSession] link];
}

- (void) pullTodo {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(pullTodo) withObject:nil waitUntilDone:NO];
		return;
	}

	if (![self isAvailable]) {
		return;
	}
	
	[downloader release];
	downloader = [[DropboxTodoDownloader alloc] init];
	downloader.remoteClient = self;
	[downloader pullTodo];
}

- (void) pushTodo:(NSString*)path {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(pushTodo:) withObject:path waitUntilDone:NO];
		return;
	}

	[uploader release];
	uploader = [[DropboxTodoUploader alloc] init];
	uploader.remoteClient = self;
	uploader.localFile = path;
	[uploader pushTodo];	
}

- (void) pushTodoOverwrite:(NSString*)path {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(pushTodoOverwrite:) withObject:path waitUntilDone:NO];
		return;
	}
	
	uploader = [[DropboxTodoUploader alloc] init];
	uploader.remoteClient = self;
	uploader.localFile = path;
	uploader.overwrite = YES;
	[uploader pushTodo];	
}

- (BOOL) isAvailable {
	return [Network isAvailable];
}


#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
	//TODO: signal login failure
}


#pragma mark -
#pragma mark DBLoginControllerDelegate methods
- (BOOL) handleOpenURL:(NSURL *)url {
	if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
			// call RemoteClientDelegate method
			if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:loginControllerDidLogin:)]) {
				[self.delegate remoteClient:self loginControllerDidLogin:YES];
			}	
        } else {
			if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:loginControllerDidLogin:)]) {
				[self.delegate remoteClient:self loginControllerDidLogin:NO];
			}				
		}
        return YES;
    }
    return NO;
}

- (void) dealloc {
	[downloader release];
	[uploader release];
	[super dealloc];
}

@end
