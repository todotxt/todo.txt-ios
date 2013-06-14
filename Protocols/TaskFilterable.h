//
//  TaskFilterable.h
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/14/13.
//
//

#import <Foundation/Foundation.h>

/*!
 @protocol TaskFilterable
 @abstract A go-between for an object with tasks and a filter.
 @discussion A protocol to go between an object with tasks and an object
 which can filter tasks.
 */
@protocol TaskFilterable <NSObject>

/*!
 @method filterForContexts
 @abstract Filter tasks on contexts and projects.
 @discussion Filter tasks on contexts and projects.
 @param contexts An array of contexts on which to filter.
 @param projects An array of projects on which to filter.
 */
- (void)filterForContexts:(NSArray *)contexts projects:(NSArray *)projects;

@end
