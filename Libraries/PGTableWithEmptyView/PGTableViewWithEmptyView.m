//
//  PGTableViewWithEmptyView.m
//  iDJ-Remix
//
//  Created by Pete Goodliffe on 8/31/10.
//  Copyright 2010 Pete Goodliffe. All rights reserved.
//

#import "PGTableViewWithEmptyView.h"

#import <QuartzCore/QuartzCore.h>

@implementation PGTableViewWithEmptyView

@synthesize emptyView;

- (bool) tableViewHasRows
{
    // TODO: This only supports the first section so far
    return [self numberOfRowsInSection:0] == 0;
}

- (void) updateEmptyPage
{
    const CGRect rect = (CGRect){self.contentOffset,self.frame.size};
    emptyView.frame  = rect;

    const bool shouldShowEmptyView = self.tableViewHasRows;
    const bool emptyViewShown      = emptyView.superview != nil;

	if (emptyViewShown) {
		[self bringSubviewToFront:emptyView];
	}
	
    if (shouldShowEmptyView == emptyViewShown) return;

    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionFade];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[self layer] addAnimation:animation forKey:kCATransitionReveal];

    if (shouldShowEmptyView)
        [self addSubview:emptyView];
    else
        [emptyView removeFromSuperview];
}

- (void) setEmptyView:(UIView *)newView
{
    if (newView == emptyView) return;

    UIView *oldView = emptyView;
    emptyView = [newView retain];

    [oldView removeFromSuperview];
    [oldView release];

    [self updateEmptyPage];
}

#pragma mark UIView

- (void) layoutSubviews
{
    [super layoutSubviews];
    [self updateEmptyPage];
}

- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // Prevent any interaction when the empty view is shown
    const bool emptyViewShown = emptyView.superview != nil;
    return emptyViewShown ? nil : [super hitTest:point withEvent:event];
}

#pragma mark UITableView

- (void) reloadData
{
    [super reloadData];
    [self updateEmptyPage];
}

@end
