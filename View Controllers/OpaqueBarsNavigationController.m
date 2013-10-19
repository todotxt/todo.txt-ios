//
//  OpaqueBarsNavigationController.m
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 10/5/13.
//
//

#import "OpaqueBarsNavigationController.h"

@implementation OpaqueBarsNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationBar.translucent = NO;
    self.toolbar.translucent = NO;
}

@end
