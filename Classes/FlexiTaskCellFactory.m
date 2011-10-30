//
//  FlexiTaskCellFactory.m
//  todo.txt-touch-ios
//
//  Created by Ricky Hussmann on 10/30/11.
//  Copyright (c) 2011 LovelyRide. All rights reserved.
//

#import "FlexiTaskCellFactory.h"

@interface FlexiTaskCellFactory ()
+ (BOOL)currentDeviceIsIpad;
+ (BOOL)currentOrientationIsPortrait;
@end

@implementation FlexiTaskCellFactory
+ (FlexiTaskCell*)cellForDeviceOrientation {
    return [[[FlexiTaskCell alloc] init] autorelease];
}

+ (NSString*)cellIDForDeviceOrientation {
    return [[[self cellForDeviceOrientation] class] cellId];
}

+ (BOOL)currentDeviceIsIpad {
    return
    [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+ (BOOL)currentOrientationIsPortrait {
    return UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
}
@end
