/**
 * This file is part of Todo.txt Touch, an iOS app for managing your todo.txt file.
 *
 * @author Todo.txt contributors <todotxt@yahoogroups.com>
 * @copyright 2011-2012 Todo.txt contributors (http://todotxt.com)
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

#import "todo_txt_touch_iosAppDelegate.h"
#import "todo_txt_touch_iosViewController.h"
#import "LoginScreenViewController.h"
#import "iPadLoginScreenViewController.h"
#import "TaskBag.h"
#import "TaskBagFactory.h"
#import "AsyncTask.h"
#import "Network.h"
#import "LocalFileTaskRepository.h"
#import "Util.h"
#import "Reachability.h"
#import "SJNotificationViewController.h"

@implementation todo_txt_touch_iosAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize navigationController;
@synthesize taskBag;
@synthesize remoteClientManager;
@synthesize lastClickedButton;


#pragma mark -
#pragma mark Application lifecycle

+ (todo_txt_touch_iosAppDelegate*) sharedDelegate {
	return (todo_txt_touch_iosAppDelegate*)[[UIApplication sharedApplication] delegate];
}

+ (id<TaskBag>) sharedTaskBag {
	return [[todo_txt_touch_iosAppDelegate sharedDelegate] taskBag];
}

+ (RemoteClientManager*) sharedRemoteClientManager {
	return [[todo_txt_touch_iosAppDelegate sharedDelegate] remoteClientManager];
}

+ (void) syncClient {	
	[[todo_txt_touch_iosAppDelegate sharedDelegate] performSelectorOnMainThread:@selector(syncClient) withObject:nil waitUntilDone:NO];
}

+ (void) pushToRemote {	
	[[todo_txt_touch_iosAppDelegate sharedDelegate] performSelectorOnMainThread:@selector(pushToRemote) withObject:nil waitUntilDone:NO];
}

+ (void) pullFromRemote {
	[[todo_txt_touch_iosAppDelegate sharedDelegate] performSelectorOnMainThread:@selector(pullFromRemote) withObject:nil waitUntilDone:NO];
}

+ (BOOL) isManualMode {
	return [[todo_txt_touch_iosAppDelegate sharedDelegate] isManualMode];
}

+ (void) logout {
	return [[todo_txt_touch_iosAppDelegate sharedDelegate] logout];
}

+ (BOOL) needToPush {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"need_to_push"];
}

+ (void) setNeedToPush:(BOOL)needToPush {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:needToPush forKey:@"need_to_push"];
}

+ (void)displayNotification:(NSString *)message {
	[[todo_txt_touch_iosAppDelegate sharedDelegate] performSelectorOnMainThread:@selector(displayNotification:) withObject:message waitUntilDone:NO];
}

- (void) presentLoginController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        loginController = [[iPadLoginScreenViewController alloc] init];
    }
    else
    {
        loginController = [[LoginScreenViewController alloc] init];
    }
    [self.navigationController presentModalViewController:loginController animated:NO];
}

- (void) presentMainViewController {
    [loginController dismissModalViewControllerAnimated:YES];
    [loginController release];
    loginController = nil;
}

- (void) clearUserDefaults {
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}


BOOL wasConnected = YES;
- (void)reachabilityChanged {
	if ([self isManualMode]) return;
	
	if ([[[todo_txt_touch_iosAppDelegate sharedRemoteClientManager] currentClient] isAvailable]) {
		if (!wasConnected) {
			[self displayNotification:@"Connection reestablished: syncing with Dropbox now..."];
		}
		[todo_txt_touch_iosAppDelegate syncClient];
		wasConnected = YES;
	} else {
		wasConnected = NO;
	}
}

- (void)displayNotification:(NSString *)message {
	SJNotificationViewController *notificationController = [[SJNotificationViewController alloc] initWithNibName:@"SJNotificationViewController" bundle:nil];
	[notificationController setParentView:self.navigationController.topViewController.view];
	[notificationController setNotificationTitle:message];
	
	[notificationController setNotificationDuration:2000];
	[notificationController setNotificationPosition:SJNotificationPositionTop];
	[notificationController setBackgroundColor:[UIColor colorWithRed:0
															   green:0
																blue:0 
															   alpha:0.6f]];
	
	[notificationController show];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
   
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjectsAndKeys:
								 @"NO", @"date_new_tasks_preference", 
								 @"NO", @"windows_line_breaks_preference", 
								 @"NO", @"manual_sync_preference", 
								 @"NO", @"need_to_push",
								 @"/todo", @"file_location_preference", nil];	
    [defaults registerDefaults:appDefaults];
	
    remoteClientManager = [[RemoteClientManager alloc] initWithDelegate:self];
    taskBag = [[TaskBagFactory getTaskBag] retain];
		
	// Start listening for network status updates.
	[Network startNotifier];
    
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(reachabilityChanged) 
												 name:kReachabilityChangedNotification object:nil];

    // Add the view controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    
	if (![remoteClientManager.currentClient isAuthenticated]) {
		[self presentLoginController];
	}
	
	[self.window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName: kTodoChangedNotification object: nil];
	
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
	if (![self isManualMode] && [remoteClientManager.currentClient isAuthenticated]) {
		[todo_txt_touch_iosAppDelegate syncClient];
	}
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Remote functions

- (void) syncClient {
	[self syncClientForce:NO];
}

- (void) syncClientForce:(BOOL)force {
	
	if ([self isManualMode]) {
		UIActionSheet* dlg = [[UIActionSheet alloc] 
							  initWithTitle:@"Manual Sync: Do you want to upload or download your todo.txt file?"
							  delegate:self 
							  cancelButtonTitle:@"Cancel" 
							  destructiveButtonTitle:nil 
							  otherButtonTitles:@"Upload changes", @"Download to device", nil ];
		dlg.tag = 10;
		[dlg showInView:self.navigationController.visibleViewController.view];
		[dlg release];
	} else if ([todo_txt_touch_iosAppDelegate needToPush]) {
		[self pushToRemoteOverwrite:NO force:force];
	} else {
		[self pullFromRemoteForce:force];
	}
}

-(void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 10) {
        if (buttonIndex == [actionSheet firstOtherButtonIndex]) {
            [self pushToRemoteOverwrite:NO force:YES];
        } else if (buttonIndex == [actionSheet firstOtherButtonIndex] + 1){
            [self pullFromRemoteForce:YES];
        }
	} 
}

- (void) pushToRemoteOverwrite:(BOOL)overwrite force:(BOOL)force {
	[todo_txt_touch_iosAppDelegate setNeedToPush:YES];

	if (!force && [self isManualMode]) {
		return;
	}
	
	if (![remoteClientManager.currentClient isAvailable]) {
		[todo_txt_touch_iosAppDelegate displayNotification:@"No internet connection: Cannot sync with Dropbox right now."];
		return;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	// We probably shouldn't be assuming LocalFileTaskRepository here, 
	// but that is what the Android app does, so why not?
	NSString *todoPath = [LocalFileTaskRepository todoFilename];
	NSString *donePath = nil;
	
	if ([taskBag doneFileModifiedSince:lastSync]) {
		donePath = [LocalFileTaskRepository doneFilename];
	}
	
	[remoteClientManager.currentClient pushTodoOverwrite:overwrite 
												withTodo:todoPath 
												withDone:donePath];
	
	// pushTodo is asynchronous. When it returns, it will call
	// the delegate method 'uploadedFile'
	
}

- (void) pushToRemote {
	[self pushToRemoteOverwrite:NO force:NO];
}

- (void) pullFromRemoteForce:(BOOL)force {
	if (!force && [self isManualMode]) {
		return;
	}
	
	[todo_txt_touch_iosAppDelegate setNeedToPush:NO];

	if (![remoteClientManager.currentClient isAvailable]) {
		[todo_txt_touch_iosAppDelegate displayNotification:@"No internet connection: Cannot sync with Dropbox right now."];
		return;
	}
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	[remoteClientManager.currentClient pullTodo];
	// pullTodo is asynchronous. When it returns, it will call
	// the delegate method 'loadedFile'

}

- (void) pullFromRemote {
	[self pullFromRemoteForce:NO];
}

- (BOOL) isManualMode {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];	
	return [defaults boolForKey:@"manual_sync_preference"];
}

- (void) logout {
	[remoteClientManager.currentClient deauthenticate];
	[self clearUserDefaults];
	[self presentLoginController];
}

- (void) syncComplete:(BOOL)success {
	if (success) {
		[todo_txt_touch_iosAppDelegate setNeedToPush:NO];
		[lastSync release];
		lastSync = [[NSDate date] retain];
	}
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];	
}

#pragma mark -
#pragma mark RemoteClientDelegate methods

- (void)remoteClient:(id<RemoteClient>)client loadedTodoFile:(NSString*)todoPath loadedDoneFile:(NSString*)donePath{
	if (todoPath) {
		[taskBag reloadWithFile:todoPath];
		// Send notification so that whichever screen is active can refresh itself
		[[NSNotificationCenter defaultCenter] postNotificationName: kTodoChangedNotification object: nil];
	}
	
	if (donePath) {
		[taskBag loadDoneTasksWithFile:donePath];
	}

	[self syncComplete:YES];
}

- (void) remoteClient:(id<RemoteClient>)client loadFileFailedWithError:(NSError *)error {
	NSLog(@"Error downloading todo.txt file: %@", error);
	
	if (error.code == 404) {
		// ignore missing file. They may not have created one yet.
		[self syncComplete:YES];
		return;
	}
	
	[self syncComplete:NO];
	UIAlertView *alert =
	[[UIAlertView alloc] initWithTitle: @"Error"
							   message: @"There was an error downloading your todo.txt file."
							  delegate: nil
					 cancelButtonTitle: @"OK"
					 otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)remoteClient:(id<RemoteClient>)client uploadedFile:(NSString*)destPath {
	[todo_txt_touch_iosAppDelegate setNeedToPush:NO];

    // Push is complete. Let's do a pull now in case the remote done.txt changed
	[self pullFromRemoteForce:YES];
}

- (void) remoteClient:(id<RemoteClient>)client uploadFileFailedWithError:(NSError *)error {
	NSLog(@"Error uploading todo file: %@", error);
	
	[self syncComplete:NO];
	
	UIAlertView *alert =
	[[UIAlertView alloc] initWithTitle: @"Error"
							   message: @"There was an error uploading your todo.txt file."
							  delegate: nil
					 cancelButtonTitle: @"OK"
					 otherButtonTitles: nil];
    [alert show];
    [alert release];
}

- (void)remoteClient:(id<RemoteClient>)client uploadFileFailedWithConflict:(NSString*)destPath {
	// alert user to the conflict and ask if he wants to force push or pull
	NSLog(@"Upload conflict");
	[self syncComplete:NO];
	
	NSString *message = [NSString 
		stringWithFormat:@"Oops! There is a newer version of your %@ file in Dropbox. "
						 "Do you want to upload your local changes, or download the Dropbox version?",
						 [destPath lastPathComponent]
						 ];
	
	UIAlertView *alert =
	[[UIAlertView alloc] initWithTitle: @"File Conflict"
							   message: message
							  delegate: self
					 cancelButtonTitle: @"Cancel"
					 otherButtonTitles: @"Upload changes", @"Download to device", nil];
    [alert show];
    [alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == [alertView firstOtherButtonIndex]) {
		[self pushToRemoteOverwrite:YES force:YES];
	} else if (buttonIndex == [alertView firstOtherButtonIndex] + 1){
		[self pullFromRemoteForce:YES];
	}
}

- (void)remoteClient:(id<RemoteClient>)client loginControllerDidLogin:(BOOL)success {
	if (success) {
		// Don't sync because we already did that when the app was reactivated by Dropbox
        // We may need to do something else for other services.
        //[self syncClient];
		[self presentMainViewController];
	}
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([remoteClientManager.currentClient handleOpenURL:url]) {
        if ([remoteClientManager.currentClient isAuthenticated]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
        }
        return YES;
    }
    // Add whatever other url handling code your app requires here
    return NO;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)dealloc {
    [loginController release];
    [viewController release];
	[navigationController release];
    [window release];
    [taskBag release];
	[remoteClientManager release];
	[lastSync release];
    [super dealloc];
}


@end
