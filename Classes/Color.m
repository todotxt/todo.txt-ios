//
//  Color.m
//  todo.txt-touch-ios
//
//  Created by Charles Jones on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Color.h"

@implementation UIColor(HexValues)

+ (UIColor*) colorWithHex:(NSUInteger)hexValue {
	
	return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
						   green:((float)((hexValue & 0xFF00) >> 8))/255.0 
							blue:((float)(hexValue & 0xFF))/255.0 
						   alpha:1.0];
}

@end

@implementation Color

+ (UIColor*) green {
	static const UIColor *sGreen = nil;
	if(!sGreen) sGreen = [[UIColor colorWithHex:0x587058] retain];
	return (UIColor*)sGreen;
}

+ (UIColor*) blue {
	static UIColor *sBlue = nil;
	if(!sBlue) sBlue = [[UIColor colorWithHex:0x587498] retain];
	return sBlue;
}

+ (UIColor*) gold {
	static UIColor *sGold = nil;
	if(!sGold) sGold = [[UIColor colorWithHex:0xFFD800] retain];
	return sGold;
}

+ (UIColor*) orange {
	static UIColor *sOrange = nil;
	if(!sOrange) sOrange = [[UIColor colorWithHex:0xE86850] retain];
	return sOrange;
}

+ (UIColor*) black {
	static UIColor *sBlack = nil;
	if(!sBlack) sBlack = [[UIColor colorWithHex:0x000000] retain];
	return sBlack;
}



@end
