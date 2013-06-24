//
//  ActionSheetPicker.h
//  Spent
//
//  Created by Tim Cinel on 3/01/11.
//  Copyright 2011 Thunderous Playground. All rights reserved.
//
//
//	Easily present an ActionSheet with a PickerView to select from a number of immutible options,
//	based on the drop-down replacement in mobilesafari.
//
//	Some code derived from marcio's post on Stack Overflow [ http://stackoverflow.com/questions/1262574/add-uipickerview-a-button-in-action-sheet-how ]  

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "TodoTxtAppDelegate.h"


@interface ActionSheetPicker : NSObject <UIPickerViewDelegate, UIPickerViewDataSource, MBProgressHUDDelegate> {
	UIView *_view;
	
	NSArray *_data;
	NSInteger _selectedIndex;
	NSString *_title;
	
	UIDatePickerMode _datePickerMode;
	NSDate *_selectedDate;
	
	id _target;
	SEL _action;
	
	UIActionSheet *_actionSheet;
	UIPopoverController *_popOverController;
	UIPickerView *_pickerView;
	UIDatePicker *_datePickerView;
	NSInteger _pickerPosition;
    
    MBProgressHUD *HUD;
	
	CGRect _rect;
	UIBarButtonItem *_barButtonItem;
}

@property (nonatomic, strong) UIView *view;

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSString *title;

@property (nonatomic, assign) UIDatePickerMode datePickerMode;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) id target;
@property (nonatomic, assign) SEL action;

@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIPopoverController *popOverController;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIDatePicker *datePickerView;
@property (nonatomic, assign) NSInteger pickerPosition;

@property (nonatomic, readonly) CGSize viewSize;

@property (nonatomic, assign) CGRect rect;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;

//no memory management required for convenience methods

//display actionsheet picker inside View, loaded with strings from data, with item selectedIndex selected. On dismissal, [target action:(NSNumber *)selectedIndex:(id)view] is called
+ (ActionSheetPicker*)displayActionPickerWithView:(UIView *)aView data:(NSArray *)data selectedIndex:(NSInteger)selectedIndex target:(id)target action:(SEL)action title:(NSString *)title rect:(CGRect)rect barButtonItem:(UIBarButtonItem*)barButtonItem;

//display actionsheet datepicker in datePickerMode inside View with selectedDate selected. On dismissal, [target action:(NSDate *)selectedDate:(id)view] is called
+ (ActionSheetPicker*)displayActionPickerWithView:(UIView *)aView datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate target:(id)target action:(SEL)action title:(NSString *)title rect:(CGRect)rect barButtonItem:(UIBarButtonItem*)barButtonItem;

- (id)initWithContainingView:(UIView *)aView target:(id)target action:(SEL)action rect:(CGRect)rect barButtonItem:(UIBarButtonItem*)barButtonItem;

- (id)initForDataWithContainingView:(UIView *)aView data:(NSArray *)data selectedIndex:(NSInteger)selectedIndex target:(id)target action:(SEL)action title:(NSString *)title rect:(CGRect)rect barButtonItem:(UIBarButtonItem*)barButtonItem;

- (id)initForDateWithContainingView:(UIView *)aView datePickerMode:(UIDatePickerMode)datePickerMode selectedDate:(NSDate *)selectedDate target:(id)target action:(SEL)action title:(NSString *)title rect:(CGRect)rect barButtonItem:(UIBarButtonItem*)barButtonItem;

//implementation
- (void)showActionPicker;
- (void)showDataPicker;
- (void)showDatePicker;

- (void)actionPickerDone;
- (void)actionPickerCancel;

- (void)eventForDatePicker:(id)sender;

- (BOOL)isViewPortrait;

+ (void)showHUDWithCustomView:(UIView *)view withMessage:(NSString *)message;

@end
