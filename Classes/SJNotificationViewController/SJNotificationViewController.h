/*
Copyright (c) <YEAR>, <OWNER>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#import <UIKit/UIKit.h>

typedef enum {
	SJNotificationLevelError = 0,
	SJNotificationLevelMessage = 1,
	SJNotificationLevelSuccess = 2
} SJNotificationLevel;

typedef enum {
    SJNotificationPositionBottom = 0,
    SJNotificationPositionTop = 1
} SJNotificationPosition;

typedef enum {
    SJNotificationDurationStay = 0,
    SJNotificationDurationShort = 1500,
    SJNotificationDurationMedium = 3000,
    SJNotificationDurationLong = 5000,
    SJNotificationDurationAlmostForever = 10000
} SJNotificationDuration;

@interface SJNotificationViewController : UIViewController {
	SJNotificationLevel notificationLevel;
    SJNotificationPosition notificationPosition;
    SJNotificationDuration notificationDuration;
	UIView *parentView;
	IBOutlet UILabel *label;
	IBOutlet UIActivityIndicatorView *spinner;
	BOOL showSpinner;
	NSString *notificationTitle;
    UIColor *backgroundColor;
    UIColor *textColor;
}

@property (nonatomic, retain) UIView *parentView;
@property (nonatomic) SJNotificationPosition notificationPosition;
@property (nonatomic) SJNotificationDuration notificationDuration;
@property (nonatomic, retain) UIColor *backgroundColor;
@property (nonatomic, retain) UIColor *textColor;

- (void)setShowSpinner:(BOOL)b;
- (void)setNotificationLevel:(SJNotificationLevel)level;

- (void)show;
- (void)hide;

- (void)setNotificationTitle:(NSString *)t;
- (void)setTapTarget:(id)target selector:(SEL)selector;

- (CGFloat)yPositionWhenHidden:(BOOL)hidden;

@end
