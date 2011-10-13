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

@interface FlexiTaskCell ()
@property (retain, readwrite) UILabel *priorityLabel;
@property (retain, readwrite) UILabel *todoIdLabel;
@property (retain, readwrite) UILabel *ageLabel;
@end

@implementation FlexiTaskCell

@synthesize priorityLabel, todoIdLabel, ageLabel, task;

+ (NSString*)cellId { return NSStringFromClass(self); }

+ (UIFont*)todoFont {
    return [UIFont systemFontOfSize:14.0];
}

+ (CGFloat)heightForCellWithTask:(Task*)aTask {
    // Need desired width here...
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    CGFloat labelWidth = [defaults boolForKey:@"show_line_numbers_preference"] ?
    TEXT_WIDTH_SHORT : TEXT_WIDTH_LONG;
    CGSize maxSize = CGSizeMake(labelWidth, CGFLOAT_MAX);
    CGSize labelSize = [[aTask inScreenFormat] sizeWithFont:[UIFont systemFontOfSize:14.0]
                                          constrainedToSize:maxSize
                                              lineBreakMode:UILineBreakModeWordWrap];
    
	return fmax(2*VERTICAL_PADDING+labelSize.height, 50);
}
- (id)init {
    self = [super initWithStyle:UITableViewCellStyleDefault
                reuseIdentifier:[FlexiTaskCell cellId]];

    if (self) {
        self.priorityLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.priorityLabel.font = [UIFont systemFontOfSize:17.0];

        self.ageLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.ageLabel.font = [UIFont systemFontOfSize:10.0];
        self.ageLabel.textColor = [UIColor lightGrayColor];

        self.todoIdLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        self.todoIdLabel.font = [UIFont systemFontOfSize:10.0];
        self.todoIdLabel.textColor = [UIColor lightGrayColor];

        self.textLabel.font = [FlexiTaskCell todoFont];

        [self addSubview:priorityLabel];
        [self addSubview:todoIdLabel];
        [self addSubview:ageLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect todoIdFrame = CGRectMake(0, 16, 23, 13);
    CGRect priorityFrame = CGRectMake(28, 5, 12, 21);
    CGRect ageFrame = CGRectMake(46, 27, 235, 13);
    CGRect todoFrame = CGRectMake(46, 5, 235, 19);

    self.todoIdLabel.frame = todoIdFrame;
    self.priorityLabel.frame = priorityFrame;
    self.ageLabel.frame = ageFrame;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
// Here
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
	
    if ([defaults boolForKey:@"show_line_numbers_preference"]) {
        todoFrame.origin.x = TEXT_XPOS_SHORT;//46;
        todoFrame.size.width = TEXT_WIDTH_SHORT;//235;
    } else {
        todoFrame.origin.x = TEXT_XPOS_LONG;//28;
        todoFrame.size.width = TEXT_WIDTH_LONG;//253;
    }
    if ([defaults boolForKey:@"show_task_age_preference"] && ![self.task completed]) {
        todoFrame.size.height = TEXT_HEIGHT_SHORT;//19;
    } else {
        todoFrame.size.height = TEXT_HEIGHT_LONG;//35;
    }
    self.textLabel.text = [self.task inScreenFormat];
    CGSize maxSize = CGSizeMake(CGRectGetWidth(todoFrame), CGFLOAT_MAX);
    CGSize labelSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0]
                                       constrainedToSize:maxSize
                                           lineBreakMode:UILineBreakModeWordWrap];
    todoFrame.size = labelSize;
    self.textLabel.frame = todoFrame;
    self.textLabel.numberOfLines = 0;
    
	if ([self.task completed]) {
		// TODO: There doesn't seem to be a strikethrough option for UILabel.
		// For now, let's just disable the label.
		self.textLabel.enabled = NO;
	} else {
		self.textLabel.enabled = YES;
	}
	
	if ([defaults boolForKey:@"show_task_age_preference"] && ![self.task completed]) {
        if ([defaults boolForKey:@"show_line_numbers_preference"]) {
            ageFrame.origin.x = TEXT_XPOS_SHORT;
            ageFrame.size.width = TEXT_WIDTH_SHORT;
        } else {
            ageFrame.origin.x = TEXT_XPOS_LONG;
            ageFrame.size.width = TEXT_WIDTH_LONG;
        }
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
