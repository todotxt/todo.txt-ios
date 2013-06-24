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

#import "iPadLoginScreenViewController.h"
#import "TodoTxtAppDelegate.h"
#import "RemoteClientManager.h"


@implementation iPadLoginScreenViewController
@synthesize todoTxtLabel, touchLabel, loginButton, imageView;

- (void) layoutSubviews:(UIInterfaceOrientation)interfaceOrientation {
	// Rearrange the widgets on the screen based on orientation.
	
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		self.todoTxtLabel.frame = CGRectMake(374, 177, self.todoTxtLabel.frame.size.width, self.todoTxtLabel.frame.size.height);
		self.touchLabel.frame = CGRectMake(551, 173, self.touchLabel.frame.size.width, self.touchLabel.frame.size.height);
		self.imageView.frame = CGRectMake(384, 314, self.imageView.frame.size.width, self.imageView.frame.size.height);		
		self.loginButton.frame = CGRectMake(430, 250, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
	} else {
		self.todoTxtLabel.frame = CGRectMake(246, 296, self.todoTxtLabel.frame.size.width, self.todoTxtLabel.frame.size.height);
		self.touchLabel.frame = CGRectMake(423, 292, self.touchLabel.frame.size.width, self.touchLabel.frame.size.height);
		self.imageView.frame = CGRectMake(256, 432, self.imageView.frame.size.width, self.imageView.frame.size.height);		
		self.loginButton.frame = CGRectMake(307, 365, self.loginButton.frame.size.width, self.loginButton.frame.size.height);
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated {
	[self layoutSubviews:[[UIApplication sharedApplication] statusBarOrientation]];	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
	[self layoutSubviews:interfaceOrientation];
}


- (IBAction)loginButtonPressed:(id)sender {
	RemoteClientManager *remoteClientManager = [TodoTxtAppDelegate sharedRemoteClientManager];
	[remoteClientManager.currentClient presentLoginControllerFromController:self];
}


@end
