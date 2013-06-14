//
//  FilterViewController.h
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/14/13.
//
//

#import <UIKit/UIKit.h>

#import "TaskFilterable.h"

@interface FilterViewController : UITableViewController

@property (assign, nonatomic) IBOutlet id<TaskFilterable> filterTarget;

@end
