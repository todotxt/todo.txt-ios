//
//  PGTableViewWithEmptyView.h
//  iDJ-Remix
//
//  Created by Pete Goodliffe on 8/31/10.
//  Copyright 2010 Pete Goodliffe. All rights reserved.
//

#import <Foundation/Foundation.h>

/// A UITableView that switches to a user-specified view when
/// it is empty.
///
/// This view is not loaded on demand, so should already have
/// been created when you display the table view.
///
/// You can connect this up in Interface Builder if that floats
/// your boat.
///
/// @version 1.0
@interface PGTableViewWithEmptyView : UITableView
{
    UIView *emptyView;
}

/// Assign this the view you want to be displayed when the UITableView
/// is empty.
@property (retain,nonatomic) IBOutlet UIView *emptyView;

/// Property value is true if the UITableView has any rows
@property (nonatomic,readonly) bool tableViewHasRows;

@end
