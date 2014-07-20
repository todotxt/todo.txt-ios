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

#import "DropboxRemoteClient.h"
#import "Network.h"
#import "TaskIo.h"
#import "DropboxApiKey.h"
#import "Util.h"
#import "DropboxFile.h"

#define TODO_TXT @"todo.txt"
#define DONE_TXT @"done.txt"

@interface DropboxRemoteClient () <DBSessionDelegate>

@property (nonatomic, strong) DropboxFileDownloader *downloader;
@property (nonatomic, strong) DropboxFileUploader *uploader;

@end

@implementation DropboxRemoteClient

+ (NSString*) todoTxtTmpFile {
	return 	[NSString pathWithComponents:
			   [NSArray arrayWithObjects:NSTemporaryDirectory(), 
						TODO_TXT, nil]];
}

+ (NSString*) todoTxtRemoteFile {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [defaults stringForKey:@"file_location_preference"];

	return 	[NSString pathWithComponents:
			 [NSArray arrayWithObjects:remotePath, 
			  TODO_TXT, nil]];
}

+ (NSString*) doneTxtTmpFile {
	return 	[NSString pathWithComponents:
			 [NSArray arrayWithObjects:NSTemporaryDirectory(), 
			  DONE_TXT, nil]];
}

+ (NSString*) doneTxtRemoteFile {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *remotePath = [defaults stringForKey:@"file_location_preference"];
	
	return 	[NSString pathWithComponents:
			 [NSArray arrayWithObjects:remotePath, 
			  DONE_TXT, nil]];
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
	[[DBSession sharedSession] linkFromController:(UIViewController*)parentViewController];
}

- (void)pullTodoWithCompletion:(RemoteClientCompletionBlock)completion {
    // Always run on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Quit without taking any action if the network is not available
        if (![self isNetworkAvailable]) {
            completion(nil, nil, nil);
            return;
        }
        
        DropboxFileDownloader* todoDownloader = [[DropboxFileDownloader alloc] init];
        
        [todoDownloader pullFiles:@[
                                    [[DropboxFile alloc] initWithRemoteFile:[DropboxRemoteClient todoTxtRemoteFile]
                                                                  localFile:[DropboxRemoteClient todoTxtTmpFile]
                                                                originalRev:[[NSUserDefaults standardUserDefaults] stringForKey:@"dropbox_last_rev"]],
                                    [[DropboxFile alloc] initWithRemoteFile:[DropboxRemoteClient doneTxtRemoteFile]
                                                                  localFile:[DropboxRemoteClient doneTxtTmpFile]
                                                                originalRev:[[NSUserDefaults standardUserDefaults] stringForKey:@"dropbox_last_rev_done"]],
                                    ]
                       completion:^(NSArray *files, NSError *error) {
                           if (error) {
                               completion(nil, nil, error);
                               return;
                           }
                           
                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                           
                           DropboxFile *todoFile = files.firstObject;
                           DropboxFile *doneFile = files.count > 1 ? files[1] : nil;
                           
                           // save revs
                           if (todoFile.status == dbSuccess) {
                               [defaults setValue:todoFile.loadedMetadata.rev forKey:@"dropbox_last_rev"];
                           }
                           if (doneFile.status == dbSuccess) {
                               [defaults setValue:doneFile.loadedMetadata.rev forKey:@"dropbox_last_rev_done"];
                           }
                           
                           NSString *loadedTodoFile = nil;
                           if (todoFile.status == dbSuccess) {
                               loadedTodoFile = todoFile.localFile;
                           }
                           NSString *loadedDoneFile = nil;
                           if (doneFile.status == dbSuccess) {
                               loadedDoneFile = doneFile.localFile;
                           }
                           
                           // report status upstream
                           completion(loadedTodoFile, loadedDoneFile, nil);
                       }];
        
        // hang onto todoDownloader so it doesn't get dealloc'ed
        self.downloader = todoDownloader;
    }];
}

- (void)pushTodoOverwrite:(BOOL)doOverwrite withTodo:(NSString *)todoPath withDone:(NSString *)donePath completion:(RemoteClientCompletionBlock)completion {
    // Always run on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        // Quit without taking any action if the network is not available
        if (![self isNetworkAvailable]) {
            completion(nil, nil, nil);
            return;
        }
        
        NSMutableArray *files = [NSMutableArray arrayWithCapacity:2];
        if (todoPath) {
            [files addObject:[[DropboxFile alloc] initWithRemoteFile:[DropboxRemoteClient todoTxtRemoteFile]
                                                           localFile:todoPath
                                                         originalRev:[[NSUserDefaults standardUserDefaults] stringForKey:@"dropbox_last_rev"]]];
        }
        
        if (donePath) {
            [files addObject:[[DropboxFile alloc] initWithRemoteFile:[DropboxRemoteClient doneTxtRemoteFile]
                                                           localFile:donePath
                                                         originalRev:[[NSUserDefaults standardUserDefaults] stringForKey:@"dropbox_last_rev_done"]]];
        }
        
        DropboxFileUploader* todoUploader = [[DropboxFileUploader alloc] init];
        
        [todoUploader pushFiles:files
                      overwrite:doOverwrite
                     completion:^(NSArray *files, NSError *error) {
                         if (error != nil) {
                             NSError *err = nil;
                             
                             // Create our own error to pass along, but include the error passed to us
                             // as the underlying error.
                             NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
                             if (error) {
                                 userInfo[NSUnderlyingErrorKey] = error;
                             }
                             
                             if (error.code == kUploadConflictErrorCode) {
                                 DropboxFile *conflictFile = error.userInfo[kUploadConflictFile];
                                 userInfo[kRCUploadConflictFileKey] = conflictFile.remoteFile;
                                 
                                 err = [NSError errorWithDomain:kRCErrorDomain
                                                           code:kRCErrorUploadConflict
                                                       userInfo:userInfo];
                             } else {
                                 // call remote client delegate function
                                 err = [NSError errorWithDomain:kRCErrorDomain
                                                           code:kRCErrorUploadFailed
                                                       userInfo:userInfo];
                             }
                             
                             completion(nil, nil, err);
                             return;
                         }
                         
                         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                         
                         DropboxFile *todoFile = files.firstObject;
                         DropboxFile *doneFile = files.count > 1 ? files[1] : nil;
                         
                         // save revs
                         [defaults setValue:todoFile.loadedMetadata.rev forKey:@"dropbox_last_rev"];
                         if (doneFile) {
                             [defaults setValue:doneFile.loadedMetadata.rev forKey:@"dropbox_last_rev_done"];
                         }
                         
                         completion(todoFile.remoteFile, doneFile.remoteFile, nil);
                     }];
        
        // hang onto todoUploader so it doesn't get dealloc'ed
        self.uploader = todoUploader;
    }];
}

- (BOOL) isNetworkAvailable {
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


@end
