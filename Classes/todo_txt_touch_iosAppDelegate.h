//
//  todo_txt_touch_iosAppDelegate.h
//  todo.txt-touch-ios
//
//  Created by Shawn McGuire on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class todo_txt_touch_iosViewController;

@interface todo_txt_touch_iosAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    todo_txt_touch_iosViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet todo_txt_touch_iosViewController *viewController;

@end

