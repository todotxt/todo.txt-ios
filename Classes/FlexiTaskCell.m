//
//  FlexiTaskCell.m
//  todo.txt-touch-ios
//
//  Created by Ricky Hussmann on 10/13/11.
//  Copyright (c) 2011 LovelyRide. All rights reserved.
//

#import "Color.h"
#import "FlexiTaskCell.h"

#define VERTICAL_PADDING    5
#define PRI_XPOS_SHORT      28
#define PRI_XPOS_LONG       10
#define TEXT_XPOS_SHORT     46
#define TEXT_WIDTH_SHORT    235
#define TEXT_XPOS_LONG      PRI_XPOS_SHORT
#define TEXT_WIDTH_LONG     253
#define TEXT_HEIGHT_SHORT   19
#define TEXT_HEIGHT_LONG    35
#define AGE_HEIGHT          13

@interface FlexiTaskCell ()

+ (CGFloat)taskTextWidth;

@property (retain, readwrite) UILabel *priorityLabel;
@property (retain, readwrite) UILabel *todoIdLabel;
@property (retain, readwrite) UILabel *ageLabel;
@end

@implementation FlexiTaskCell

@synthesize priorityLabel, todoIdLabel, ageLabel, task;

+ (NSString*)cellId { return NSStringFromClass(self); }
+ (UIFont*)taskFont { return [UIFont systemFontOfSize:14.0]; }

+ (BOOL)shouldShowTaskId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return[defaults boolForKey:@"show_line_numbers_preference"];
}

+ (BOOL)shouldShowTaskAge {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"show_task_age_preference"];
}

+ (CGFloat)taskTextWidth {
    return [self shouldShowTaskId] ? TEXT_WIDTH_SHORT : TEXT_WIDTH_LONG;
}

+ (CGFloat)taskTextOriginX {
    return [self shouldShowTaskId] ? TEXT_XPOS_SHORT : TEXT_XPOS_LONG;
}

+ (CGFloat)heightForCellWithTask:(Task*)aTask {
    CGSize maxSize = CGSizeMake(self.taskTextWidth, CGFLOAT_MAX);
    CGSize labelSize = [[aTask inScreenFormat] sizeWithFont:[self taskFont]
                                          constrainedToSize:maxSize
                                              lineBreakMode:UILineBreakModeWordWrap];

    CGFloat ageLabelHeight = [self shouldShowTaskAge] ? AGE_HEIGHT : 0;
    return fmax(2*VERTICAL_PADDING+labelSize.height+ageLabelHeight, 50);
}
- (id)init {
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:[[self class] cellId]];

    if (self) {
        self.priorityLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.priorityLabel.font = [UIFont systemFontOfSize:17.0];

        self.ageLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.ageLabel.font = [UIFont systemFontOfSize:10.0];
        self.ageLabel.textColor = [UIColor lightGrayColor];

        self.todoIdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.todoIdLabel.font = [UIFont systemFontOfSize:10.0];
        self.todoIdLabel.textColor = [UIColor lightGrayColor];
        self.todoIdLabel.textAlignment = UITextAlignmentRight;

        self.textLabel.font = [[self class] taskFont];

        [self addSubview:priorityLabel];
        [self addSubview:todoIdLabel];
        [self addSubview:ageLabel];
    }
    return self;
}

- (void)dealloc {
    self.priorityLabel = nil;
    self.ageLabel = nil;
    self.todoIdLabel = nil;
    [super dealloc];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect todoIdFrame = CGRectMake(0, 16, 23, 13);
    CGRect priorityFrame = CGRectMake(28, VERTICAL_PADDING, 12, 21);
    CGRect ageFrame = CGRectMake(46, 27, 235, AGE_HEIGHT);
    CGRect todoFrame = CGRectMake(46, VERTICAL_PADDING,
                                  [[self class] taskTextWidth], 19);

    self.todoIdLabel.frame = todoIdFrame;
    self.priorityLabel.frame = priorityFrame;
    self.ageLabel.frame = ageFrame;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
// TODO ID label setup
	if ([defaults boolForKey:@"show_line_numbers_preference"]) {
		self.todoIdLabel.text = [NSString stringWithFormat:@"%02d", [self.task taskId] + 1];
		self.todoIdLabel.hidden = NO;
	} else {
		self.todoIdLabel.hidden = YES;
	}

// Priority label setup
    if ([defaults boolForKey:@"show_line_numbers_preference"]) {
        priorityFrame.origin.x = PRI_XPOS_SHORT;//28
    } else {
        priorityFrame.origin.x = PRI_XPOS_LONG;//10
    }
    priorityLabel.frame = priorityFrame;
    priorityLabel.text = [[self.task priority] listFormat];
	// Set the priority color
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
	
    self.textLabel.text = [self.task inScreenFormat];
    CGSize maxSize = CGSizeMake(CGRectGetWidth(todoFrame), CGFLOAT_MAX);
    CGSize labelSize = [self.textLabel.text sizeWithFont:[[self class] taskFont]
                                       constrainedToSize:maxSize
                                           lineBreakMode:UILineBreakModeWordWrap];
    todoFrame.origin.x = [[self class] taskTextOriginX];
    todoFrame.size = labelSize;
    self.textLabel.frame = todoFrame;
    self.textLabel.numberOfLines = 0;
    self.textLabel.backgroundColor = [UIColor redColor];

    todoIdFrame.origin.y = [[self class] heightForCellWithTask:self.task]/2.0 -
        CGRectGetHeight(todoIdFrame)/2.0;
    self.todoIdLabel.frame = todoIdFrame;

	if ([self.task completed]) {
		// TODO: There doesn't seem to be a strikethrough option for UILabel.
		// For now, let's just disable the label.
		self.textLabel.enabled = NO;
	} else {
		self.textLabel.enabled = YES;
	}

	if ([defaults boolForKey:@"show_task_age_preference"] && ![self.task completed]) {
        ageFrame.origin.x = [[self class] taskTextOriginX];
        ageFrame.origin.y = self.textLabel.frame.origin.y + self.textLabel.frame.size.height;
        ageFrame.size.width = [[self class] taskTextWidth];
        self.ageLabel.frame = ageFrame;
		self.ageLabel.text = [self.task relativeAge];
		self.ageLabel.hidden = NO;
	} else {
		self.ageLabel.text = @"";
		self.ageLabel.hidden = YES;
	}
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
