//
//  TaskCellViewModel.m
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/21/13.
//  Copyright (c) 2013, Sierra Bravo Corp., dba The Nerdery
//

#import "TaskCellViewModel.h"

#import "Color.h"
#import "Task.h"

@interface TaskCellViewModel ()

@property (nonatomic, readonly) NSDictionary *attributesForTask;
@property (nonatomic, readonly) NSDictionary *attributesForCompletedTask;
@property (nonatomic, readonly) UIFont *taskFont;
@property (nonatomic, readonly) UIColor *taskColor;

@end

@implementation TaskCellViewModel

#pragma mark - Custom getters/setters

- (NSAttributedString *)attributedText
{
    NSDictionary *taskAttributes = self.attributesForTask;
    
    if (self.task.completed) {
        taskAttributes = self.attributesForCompletedTask;
    }
    
    NSString *taskText = [self.task inScreenFormat];
    NSMutableAttributedString *taskString;
    taskString = [[NSMutableAttributedString alloc] initWithString:taskText
                                                        attributes:taskAttributes];
    
    NSDictionary *grayAttribute = @{ NSForegroundColorAttributeName : [UIColor grayColor] };
    
    NSArray *contextsRanges = [self.task rangesOfContexts];
    NSArray *projectsRanges = [self.task rangesOfProjects];
    for (NSValue *rangeValue in [contextsRanges arrayByAddingObjectsFromArray:projectsRanges]) {
        NSRange range = rangeValue.rangeValue;
        [taskString addAttributes:grayAttribute range:range];
    }
    
    return taskString;
}

- (NSString *)ageText
{
    return self.task.relativeAge;
}

- (NSString *)priorityText
{
    return [[self.task priority] listFormat];
}

- (UIColor *)priorityColor
{
    UIColor *color = nil;
    
    // Set the priority label's color
	PriorityName name = [[self.task priority] name];
	switch (name) {
		case PriorityA:
			//Set color to green #587058
			color = [Color green];
			break;
		case PriorityB:
			//Set color to blue #587498
			color = [Color blue];
			break;
		case PriorityC:
			//Set color to orange #E86850
			color = [Color orange];
			break;
		case PriorityD:
			//Set color to gold #587058
			color = [Color gold];
			break;
		default:
			//Set color to black #000000
			color = [Color black];
			break;
	}

	return color;
}

- (BOOL)shouldShowDate
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL isAllowed = [defaults boolForKey:@"date_new_tasks_preference"];
    
    return isAllowed && !self.task.completed && self.task.relativeAge;
}

#pragma mark - Private getters/setters

- (NSDictionary *)attributesForTask
{
    NSDictionary *attributes = @{
                                 NSFontAttributeName : self.taskFont,
                                 NSForegroundColorAttributeName : self.taskColor
                                 };
    
    return attributes;
}

- (NSDictionary *)attributesForCompletedTask
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:self.attributesForTask];
    
    NSDictionary * const completedAttributes = @{ NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle) };
    [attributes addEntriesFromDictionary:completedAttributes];
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

- (UIFont *)taskFont
{
    return [UIFont systemFontOfSize:14.0];
}

- (UIColor *)taskColor
{
    return [UIColor blackColor];
}

@end
