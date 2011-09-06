//
//  Color.h
//  todo.txt-touch-ios
//
//  Created by Charles Jones on 8/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor(HexValues)

+ (UIColor*) colorWithHex:(NSUInteger)hexValue;

@end

@interface Color : NSObject {
    
}

+ (UIColor*) green;
+ (UIColor*) blue;
+ (UIColor*) gold;
+ (UIColor*) orange;
+ (UIColor*) black;

@end
