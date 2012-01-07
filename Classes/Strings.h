//
//  Strings.h
//  todo.txt-touch-ios
//
//  Created by Charles Jones on 12/29/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Strings : NSObject

+ (NSString*) insertPaddedString:(NSString *)s atRange:(NSRange)insertAt withString:(NSString *)stringToInsert;
+ (NSRange) calculateSelectedRange:(NSRange)oldRange oldText:(NSString*)oldText newText:(NSString*)newText;

@end
