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

#import <UIKit/UIKit.h>
#import "TaskBag.h"
#import "RemoteClientManager.h"

#define kTodoChangedNotification @"kTodoChangedNotification"

@class todo_txt_touch_iosViewController;

@interface todo_txt_touch_iosAppDelegate : NSObject <UIApplicationDelegate, RemoteClientDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    UIWindow *window;
    todo_txt_touch_iosViewController *viewController;
	UINavigationController *navigationController;
    id <TaskBag> taskBag;
	RemoteClientManager *remoteClientManager;
    id lastClickedButton; //Anchor holder for the Popover in iPad
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet todo_txt_touch_iosViewController *viewController;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, readonly) id <TaskBag> taskBag;
@property (nonatomic, readonly) RemoteClientManager *remoteClientManager;
@property (nonatomic, retain) id lastClickedButton; 

- (void) syncClient;
- (void) syncClientWithPrompt;
- (void) syncClientForceChoice:(BOOL)forceChoice;
- (void) pushToRemote;
- (void) pushToRemoteOverwrite:(BOOL)overwrite force:(BOOL)force;
- (void) pullFromRemoteForce:(BOOL)force;
- (void) pullFromRemote;
- (BOOL) isOfflineMode;
- (BOOL) setOfflineMode:(BOOL)goOffline;
- (void) logout;

+ (todo_txt_touch_iosAppDelegate*) sharedDelegate;
+ (id<TaskBag>) sharedTaskBag;
+ (RemoteClientManager*) sharedRemoteClientManager;
+ (void) syncClient;
+ (void) syncClientWithPrompt;
+ (void) pushToRemote;
+ (void) pullFromRemote;
+ (BOOL) isOfflineMode;
+ (BOOL) setOfflineMode:(BOOL)goOffline;
+ (void) logout;

@end

