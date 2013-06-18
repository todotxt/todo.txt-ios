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
@property (nonatomic, weak) IBOutlet UITextView *taskTextView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTopSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelBottomSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelLeadingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *taskLabelTrailingSpace;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *ageLabelHeight;
@property (nonatomic) CGFloat ageLabelInitialHeight;
@property (nonatomic, readonly) NSAttributedString *attributedTaskText;

@end

@implementation TaskCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.shouldShowDate = YES;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.taskTextView.font = [[self class] taskFont];
    self.taskTextView.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
    self.ageLabelInitialHeight = self.ageLabelHeight.constant;
    
    // Stop if staticSizingCell is nil, i.e. this is awakeFromNib
    // for the staticSizingCell.
    if (!staticSizingCell) {
        return;
    }
    
    // Move all constraints from the cell's view to the cell's contentView.
    // See http://stackoverflow.com/a/13893146/1610271
    for (NSLayoutConstraint *cellConstraint in self.constraints) {
        [self removeConstraint:cellConstraint];
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        NSLayoutConstraint* contentViewConstraint =
        [NSLayoutConstraint constraintWithItem:firstItem
                                     attribute:cellConstraint.firstAttribute
                                     relatedBy:cellConstraint.relation
                                        toItem:seccondItem
                                     attribute:cellConstraint.secondAttribute
                                    multiplier:cellConstraint.multiplier
                                      constant:cellConstraint.constant];
        [self.contentView addConstraint:contentViewConstraint];
    }
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
    
    self.taskTextView.attributedText = self.attributedTaskText;
    
    CGFloat newAgeLabelHeight = 0;
    // Show the age of the task, if appropriate. If not, hide the age label.
	if (self.shouldShowDate && ![self.task completed] && task.relativeAge) {
		self.ageLabel.text = self.task.relativeAge;
		self.ageLabel.hidden = NO;
        
        newAgeLabelHeight = self.ageLabelInitialHeight;
	} else {
		self.ageLabel.text = @"";
		self.ageLabel.hidden = YES;
        
        newAgeLabelHeight = 0;
	}
    
    // Find the age label's height constraint and set its constant.
    // We can't just use the IBOutlet because the constraint it connects to
    // is removed in -awakeFromNib:
    for (NSLayoutConstraint *constraint in self.ageLabel.constraints) {
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant = newAgeLabelHeight;
        }
    }
}

- (NSAttributedString *)attributedTaskText
{
    return [[self class] attributedTextForTask:self.task];
}

#pragma mark - Public class methods

+ (CGFloat)heightForTask:(Task *)task givenWidth:(CGFloat)width
{
    const CGFloat bottomSpaceReclaimed = task.relativeAge ? 0 : staticSizingCell.ageLabelHeight.constant;
    
    const CGFloat baseHeight = [self sizingCell].taskLabelTopSpace.constant + [self sizingCell].taskLabelBottomSpace.constant - bottomSpaceReclaimed;
    const CGFloat takenWidth = [self sizingCell].taskLabelLeadingSpace.constant + [self sizingCell].taskLabelTrailingSpace.constant;
    
    CGSize taskLabelSize = CGSizeMake(width - takenWidth, CGFLOAT_MAX);
    
    staticSizingCell.taskTextView.attributedText = [self attributedTextForTask:task];
    CGRect rect = CGRectZero;
    rect.size = [staticSizingCell.taskTextView sizeThatFits:taskLabelSize];
    
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
