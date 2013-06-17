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

static TaskCell *staticSizingCell;
static const CGFloat kMinHeight = 44;

@interface TaskCell ()

+ (TaskCell *)sizingCell;
+ (UIFont *)taskFont;
+ (NSDictionary *)taskStringAttributesForCompleted:(BOOL)isComplete;

@property (nonatomic, weak) IBOutlet UILabel *priorityLabel;
@property (nonatomic, weak) IBOutlet UILabel *ageLabel;
@property (nonatomic, weak) IBOutlet UILabel *taskLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTopSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelLeadingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTrailingSpace;
@property (nonatomic, readonly) NSAttributedString *attributedTaskText;

@end

@implementation TaskCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.taskLabel.font = [[self class] taskFont];
    }
    
    return self;
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
    return [[self class] attributedTextForTask:self.task];
}

#pragma mark - Public class methods

+ (CGFloat)heightForTask:(Task *)task givenWidth:(CGFloat)width
{
    const CGFloat baseHeight = [self sizingCell].taskLabelTopSpace.constant + [self sizingCell].taskLabelBottomSpace.constant;
    const CGFloat takenWidth = [self sizingCell].taskLabelLeadingSpace.constant + [self sizingCell].taskLabelTrailingSpace.constant;
    
    CGSize taskLabelSize = CGSizeMake(width - takenWidth, CGFLOAT_MAX);
    
    CGRect rect = [[self attributedTextForTask:task] boundingRectWithSize:taskLabelSize
                                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                                                  context:nil];
    const CGFloat calculatedHeight = baseHeight + CGRectGetHeight(rect);
    
    return calculatedHeight > kMinHeight ? calculatedHeight : kMinHeight;
}

+ (NSAttributedString *)attributedTextForTask:(Task *)task
{
    NSAssert(task, @"Task cannot be nil");
    
    NSDictionary *taskAttributes = [[self class] taskStringAttributesForCompleted:task.completed];
    
    NSString *taskText = [task inScreenFormat];
    NSMutableAttributedString *taskString;
    taskString = [[NSMutableAttributedString alloc] initWithString:taskText
                                                        attributes:taskAttributes];
    
    NSDictionary *grayAttribute = @{ NSForegroundColorAttributeName : [UIColor grayColor] };
    
    NSArray *contextsRanges = [task rangesOfContexts];
    NSArray *projectsRanges = [task rangesOfProjects];
    for (NSValue *rangeValue in [contextsRanges arrayByAddingObjectsFromArray:projectsRanges]) {
        NSRange range = rangeValue.rangeValue;
        [taskString addAttributes:grayAttribute range:range];
    }
    
    return taskString;
}

#pragma mark - Private class methods

+ (TaskCell *)sizingCell
{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        staticSizingCell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TaskCell class])
                                                         owner:nil
                                                       options:nil][0];
    });
    
    return staticSizingCell;
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
                                     NSFontAttributeName : taskFont,
                                     NSForegroundColorAttributeName : black
                                     };
    [attributes addEntriesFromDictionary:baseAttributes];
    
    if (isComplete) {
        NSDictionary *completedAttributes = @{ NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle) };
        [attributes addEntriesFromDictionary:completedAttributes];
    }
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
