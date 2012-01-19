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

#import <UIKit/UIKit.h>
#import "Task.h"
#import "ActionSheetPicker.h"
#import "SSTextView.h"

@class TaskEditViewController;

@protocol TaskEditViewControllerDelegate <NSObject>

@optional

- (void)taskEditViewController:(TaskEditViewController *)controller didUpdateTask:(Task *)task;

@end

@interface TaskEditViewController : UIViewController <UITextViewDelegate>{
	 id <TaskEditViewControllerDelegate> delegate;
	UINavigationItem *navItem;
	SSTextView *textView; 
	UIView *accessoryView;
	NSString *curInput;
	Task *task;
	NSRange curSelectedRange;
	UIView *helpView;
	UIButton *helpCloseButton;
	UIPopoverController *popOverController;
	ActionSheetPicker *actionSheetPicker;
	UIWebView* helpContents;
}

@property (nonatomic, assign) id <TaskEditViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UINavigationItem *navItem;
@property (nonatomic, retain) IBOutlet SSTextView *textView;
@property (nonatomic, assign) IBOutlet UIView *accessoryView;
@property (nonatomic, retain) Task *task;
@property (nonatomic, retain) IBOutlet UIView *helpView;
@property (nonatomic, retain) IBOutlet UIView *helpContents;
@property (nonatomic, retain) IBOutlet UIButton *helpCloseButton;
@property (nonatomic, retain) UIPopoverController *popOverController;
@property (nonatomic, retain) ActionSheetPicker *actionSheetPicker;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;
- (IBAction)helpButtonPressed:(id)sender;
- (IBAction)helpCloseButtonPressed:(id)sender;
- (IBAction) keyboardAccessoryButtonPressed:(id)sender; 
- (void) addEditTask;

@end
