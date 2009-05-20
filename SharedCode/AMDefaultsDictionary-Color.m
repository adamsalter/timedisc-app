//
//  AMDefaultsDictionary-Color.m
//  TimeDisc
//
//  Created by Andreas on Thu Nov 07 2002.
//  Copyright (c) 2002 Andreas Mayer. All rights reserved.
//

#import "AMDefaultsDictionary-Color.h"


@implementation AMDefaultsDictionary (Color)

- (NSColor *)colorForKey:(NSString *)defaultName
{
	id object;
	if (userDefaultsProxy) {
		return [NSUnarchiver unarchiveObjectWithData:[userDefaults dataForKey:defaultName]]; }
	else {
		object = [dictionary objectForKey:defaultName];
		if ([object isKindOfClass:[NSData class]]) {
			return [NSUnarchiver unarchiveObjectWithData:(NSData *)object];
		}
		else {
			return nil;
		}
	}
}

- (void)setColor:(NSColor *)value forKey:(NSString *)defaultName
{
	if (userDefaultsProxy)
		[userDefaults setObject:[NSArchiver archivedDataWithRootObject:value] forKey:defaultName];
	else
		[[self dictionary] setObject:[NSArchiver archivedDataWithRootObject:value] forKey:defaultName];
	[self update];
}

@end
