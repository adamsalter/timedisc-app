//
//  AMDefaultsDictionary-Color.h
//  TimeDisc
//
//  Created by Andreas on Thu Nov 07 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMDefaultsDictionary.h"


@interface AMDefaultsDictionary (Color)

- (NSColor *)colorForKey:(NSString *)defaultName;

- (void)setColor:(NSColor *)value forKey:(NSString *)defaultName;

@end
