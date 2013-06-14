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
#import "LoginScreenViewController.h"
#import "todo_txt_touch_iosAppDelegate.h"
#import "RemoteClientManager.h"

@implementation LoginScreenViewController
@synthesize todoTxtLabel, touchLabel, loginButton, imageView;

- (void) layoutSubviews:(UIInterfaceOrientation)interfaceOrientation {
	// Even though we only want portrait mode for this screen, it sometimes shows in landscape, and
	// there doesn't seem to be a way to stop it. So, we need to rearrange the widgets on the screen
	// when it happens.
	
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		self.todoTxtLabel.frame = CGRectMake(112, 4, 173, 41);
		self.touchLabel.frame = CGRectMake(283, 0, 99, 42);
		self.imageView.frame = CGRectMake(112, 44, 256, 256);		
		self.loginButton.frame = CGRectMake(163, 108, 155, 35);
	} else {
		self.todoTxtLabel.frame = CGRectMake(22, 24, 173, 41);
		self.touchLabel.frame = CGRectMake(199, 20, 99, 42);
		self.imageView.frame = CGRectMake(32, 160, 256, 256);
		self.loginButton.frame = CGRectMake(82, 73, 155, 35);
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"Todo.txt Touch";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.todoTxtLabel = nil;
	self.touchLabel = nil;
	self.loginButton = nil;
	self.imageView = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self layoutSubviews:[[UIApplication sharedApplication] statusBarOrientation]];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutSubviews:interfaceOrientation];
}

- (IBAction)loginButtonPressed:(id)sender {
	RemoteClientManager *remoteClientManager = [todo_txt_touch_iosAppDelegate sharedRemoteClientManager];
	[remoteClientManager.currentClient presentLoginControllerFromController:self];
}



@end
