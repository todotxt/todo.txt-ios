//
//  TaskEditViewController.h
//  todo.txt-touch-ios
//
//  Created by Charles Jones on 8/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TaskEditViewController : UIViewController {
	UITextView *text; 

}

@property (nonatomic, retain) IBOutlet UITextView *text;

- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)doneButtonPressed:(id)sender;

@end
