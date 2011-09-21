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

#import "DropboxRemoteClient.h"
#import "Network.h"
#import "TaskIo.h"

@interface DropboxRemoteClient () <DBSessionDelegate, DBRestClientDelegate, DBLoginControllerDelegate>
@end

@implementation DropboxRemoteClient

@synthesize delegate;

- (NSString*) todoTxtTmpFile {
	return 	[NSString pathWithComponents:
			   [NSArray arrayWithObjects:NSTemporaryDirectory(), 
						@"todo.txt", nil]];
}

- (NSDictionary*) getApiKey {
	NSBundle* bundle = [NSBundle mainBundle];
	NSString* plistPath = [bundle pathForResource:@"dropbox" ofType:@"plist"];
	return [[[NSDictionary alloc] initWithContentsOfFile:plistPath] autorelease];
}

- (id) init {
	self = [super init];
	if (self) {
		NSDictionary *apiKey = [self getApiKey];
		NSString* consumerKey = [apiKey objectForKey:@"dropbox_consumer_key"];
		NSString* consumerSecret = [apiKey objectForKey:@"dropbox_consumer_secret"];
		
		DBSession* session = 
        [[DBSession alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret];
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
	[[DBSession sharedSession] unlink];
	[[NSFileManager defaultManager] 
		removeItemAtPath:[self todoTxtTmpFile] 
					error:nil];
}

- (BOOL) isAuthenticated {
	return [[DBSession sharedSession] isLinked];
}

- (void) presentLoginControllerFromController:(UIViewController*)parentViewController {
	DBLoginController* controller = [[DBLoginController new] autorelease];
	controller.delegate = self;
	[controller presentFromController:parentViewController];
}

- (DBRestClient*)restClient {
    if (restClient == nil) {
    	restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	restClient.delegate = self;
    }
    return restClient;
}

- (void) pullTodo {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(pullTodo) withObject:nil waitUntilDone:NO];
		return;
	}

	if (![self isAvailable]) {
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [[defaults stringForKey:@"file_location_preference"] stringByAppendingString:@"/todo.txt"];
	NSString *localPath = [self todoTxtTmpFile];
	
	[self.restClient loadFile:remotePath intoPath:localPath];
}

- (void) pushTodo:(NSString*)path {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(pushTodo) withObject:path waitUntilDone:NO];
		return;
	}
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [defaults stringForKey:@"file_location_preference"];
	[self.restClient uploadFile:@"todo.txt" toPath:remotePath fromPath:path];
}

- (BOOL) isAvailable {
	return [Network isAvailable];
}

#pragma mark -
#pragma mark DBRestClientDelegate methods
- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)destPath {
	// call RemoteClientDelegate method
	if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:loadedFile:)]) {
		[self.delegate remoteClient:self loadedFile:destPath];
	}
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
	// TODO: implement loadFileFailedWithError
	// For now, lets call loadedFile and pass it nil
	// call RemoteClientDelegate method
	if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:loadedFile:)]) {
		[self.delegate remoteClient:self loadedFile:nil];
	}
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath {
	// call RemoteClientDelegate method
	if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:uploadedFile:)]) {
		[self.delegate remoteClient:self uploadedFile:destPath];
	}
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
	// TODO: implement uploadFileFailedWithError
	// For now, lets call uploadedFile and pass it nil
	// call RemoteClientDelegate method
	if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:uploadedFile:)]) {
		[self.delegate remoteClient:self uploadedFile:nil];
	}
}



#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session {
	//TODO: signal login failure
}


#pragma mark -
#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
	// call RemoteClientDelegate method
	if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:loginControllerDidLogin:)]) {
		[self.delegate remoteClient:self loginControllerDidLogin:YES];
	}	
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
	if (self.delegate && [self.delegate respondsToSelector:@selector(remoteClient:loginControllerDidLogin:)]) {
		[self.delegate remoteClient:self loginControllerDidLogin:NO];
	}	
}

@end
