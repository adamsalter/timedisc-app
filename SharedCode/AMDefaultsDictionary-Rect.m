//
//  AMDefaultsDictionary-Rect.m
//  TimeDisc
//
//  Created by Andreas on Thu Nov 07 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import "AMDefaultsDictionary-Rect.h"


@implementation AMDefaultsDictionary (Rect)

- (NSRect)rectForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy)
		return NSRectFromString([userDefaults objectForKey:defaultName]);
	else {
		object = [dictionary objectForKey:defaultName];
		if ([object isKindOfClass:[NSString class]])
			return NSRectFromString(object);
		else
			return NSMakeRect(0,0,0,0);
	}
}

- (void)setRect:(NSRect)value forKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		[userDefaults setObject:NSStringFromRect(value) forKey:defaultName];
	else
		[[self dictionary] setObject:NSStringFromRect(value) forKey:defaultName];
	[self update];
}

@end
