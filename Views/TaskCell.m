//
//  TaskCell.m
//  todo.txt-touch-ios
//
//  Created by Brendon Justin on 6/16/13.
//
//

#import "TaskCell.h"

#import "Color.h"
#import "Priority.h"
#import "Task.h"

#import <CoreText/CoreText.h>

@interface TaskCell ()

+ (UIFont *)taskFont;
+ (NSDictionary *)taskStringAttributesForCompleted:(BOOL)isComplete;

@property (nonatomic, assign) IBOutlet UILabel *priorityLabel;
@property (nonatomic, assign) IBOutlet UILabel *todoIdLabel;
@property (nonatomic, assign) IBOutlet UILabel *ageLabel;
@property (nonatomic, assign) IBOutlet UILabel *taskLabel;
@property (nonatomic, readonly) NSAttributedString *attributedTaskText;

@end

@implementation TaskCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Overridden getters/setters

- (void)setTask:(Task *)task
{
    _task = task;
    
    // Setup the priority label
    self.priorityLabel.text = [[self.task priority] listFormat];
	
    // Set the priority label's color
	PriorityName n = [[self.task priority] name];
	switch (n) {
		case PriorityA:
			//Set color to green #587058
			self.priorityLabel.textColor = [Color green];
			break;
		case PriorityB:
			//Set color to blue #587498
			self.priorityLabel.textColor = [Color blue];
			break;
		case PriorityC:
			//Set color to orange #E86850
			self.priorityLabel.textColor = [Color orange];
			break;
		case PriorityD:
			//Set color to gold #587058
			self.priorityLabel.textColor = [Color gold];
			break;
		default:
			//Set color to black #000000
			self.priorityLabel.textColor = [Color black];
			break;
	}
    
    self.taskLabel.attributedText = self.attributedTaskText;
    
    // Show the age of the task, if appropriate
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"date_new_tasks_preference"] && ![self.task completed]) {
		self.ageLabel.text = self.task.relativeAge;
		self.ageLabel.hidden = NO;
	} else {
		self.ageLabel.text = @"";
		self.ageLabel.hidden = YES;
	}
}

- (NSAttributedString *)attributedTaskText
{
    NSAssert(self.taskLabel, @"Task cannot be nil");
    
    NSDictionary *taskAttributes = [[self class] taskStringAttributesForCompleted:self.task.completed];
    
    NSString *taskText = [self.task inScreenFormat];
    NSMutableAttributedString *taskString;
    taskString = [[[NSMutableAttributedString alloc] initWithString:taskText
                                                         attributes:taskAttributes] autorelease];
    
    NSDictionary *grayAttribute = [NSDictionary dictionaryWithObject:[UIColor grayColor]
                                                              forKey:NSForegroundColorAttributeName];
    
    NSArray *contextsRanges = [self.task rangesOfContexts];
    NSArray *projectsRanges = [self.task rangesOfProjects];
    for (NSValue *rangeValue in [contextsRanges arrayByAddingObjectsFromArray:projectsRanges]) {
        NSRange range = rangeValue.rangeValue;
        [taskString setAttributes:grayAttribute range:range];
    }
    
    return taskString;
}

+ (UIFont *)taskFont
{
    return [UIFont systemFontOfSize:14.0];
}

+ (NSDictionary *)taskStringAttributesForCompleted:(BOOL)isComplete
{
    UIFont *taskFont = [[self class] taskFont];
    UIColor *black = [UIColor blackColor];
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    NSDictionary *baseAttributes = @{
                                     taskFont : NSFontAttributeName,
                                     black : NSForegroundColorAttributeName
                                     };
    [attributes addEntriesFromDictionary:baseAttributes];
    
    if (isComplete) {
        NSDictionary *completedAttributes = @{ @(NSUnderlineStyleSingle) : NSStrikethroughStyleAttributeName };
        [attributes addEntriesFromDictionary:completedAttributes];
    }
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
