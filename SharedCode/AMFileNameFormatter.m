//
//  AMFileNameFormatter.m
//  TimeDisc
//
//  Created by Andreas on Thu Feb 06 2003.
//  Copyright (c) 2003 Andreas Mayer. All rights reserved.
//

#import "AMFileNameFormatter.h"


@implementation AMFileNameFormatter

- (NSString *)stringForObjectValue:(id)anObject
{
	return (NSString *)anObject;
}

- (BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error
{
	(*anObject) = [[string copy] autorelease];
	return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error
{
	BOOL result = NO;
	NSRange illegalCharacters = [partialString rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"/:"]];
	if (illegalCharacters.location == NSNotFound) {
		result = YES;
	} else {
		(*newString) = nil;
		NSBeep();
	}
	return result;
}

@end
