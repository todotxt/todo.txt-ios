//
//  Strings.m
//  todo.txt-touch-ios
//
//  Created by Charles Jones on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Strings.h"

#define SINGLE_SPACE ' '

@implementation Strings

+ (NSString*) insertPaddedString:(NSString *)s atRange:(NSRange)insertAt withString:(NSString *)stringToInsert {
	if (stringToInsert.length == 0) {
		return s;
	}	
	
	NSMutableString *newText = [NSMutableString stringWithCapacity:(s.length + stringToInsert.length + 2)];
	
	if (insertAt.location > 0) {
		[newText appendString:[s substringToIndex:(insertAt.location)]];
		if (newText.length > 0 && [newText characterAtIndex:(newText.length - 1)] != SINGLE_SPACE) {
			[newText appendFormat:@"%c", SINGLE_SPACE];
		}
		[newText appendString:stringToInsert];
		NSUInteger pos = NSMaxRange(insertAt);
		NSString *postItem = [s substringFromIndex:pos];
		if (postItem.length == 0 || [postItem characterAtIndex:0] != SINGLE_SPACE) {
			[newText appendFormat:@"%c", SINGLE_SPACE];
		}
		[newText appendString:postItem];
	} else {
		[newText appendString:stringToInsert];
		if (s.length > 0 && [s characterAtIndex:0] != SINGLE_SPACE) {
			[newText appendFormat:@"%c", SINGLE_SPACE];
		}	
		[newText appendString:s];
	}
	
	return newText;
}

+ (NSRange) calculateSelectedRange:(NSRange)oldRange oldText:(NSString*)oldText newText:(NSString*)newText {
	NSUInteger length = oldRange.length;
	
	if (newText == nil) {
		return NSMakeRange(0, length);
	}
	
	if (oldText == nil) {
		return NSMakeRange(newText.length, 0);
	}
	
	NSInteger pos = oldRange.location + (newText.length - oldText.length);
	pos = pos < 0 ? 0 : pos;
	pos = pos > newText.length ? newText.length : pos;
	
	return NSMakeRange(pos, length);
}


@end
